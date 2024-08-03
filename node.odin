package main

import rl "vendor:raylib"

import "core:fmt"
import "core:strings"

MaxElementDisplay :: 10
ElementHeight := f32(0.0) //setting up at the start of the program

ColoredRect :: struct {
	rect:  rl.Rectangle,
	color: rl.Color,
}

ColoredTexturedRect :: struct {
	rect:    rl.Rectangle,
	color:   rl.Color,
	texture: rl.Texture2D,
}

ElementType :: union {
	Task,
	Batch,
}

Task :: struct {
	task:             string,
	color:            rl.Color,
	left_color:       rl.Color,
	ver_split_per:    f32,

	//checkbox stuff
	checkbox_color:   rl.Color,
	delete_color:     rl.Color,

	//fast interaction
	fast_inter_panel: rl.Rectangle,
}

generate_task_type :: proc(str: string) -> Task {
	return Task {
		task = str,
		color = rl.PINK,
		ver_split_per = 0.2,
		left_color = rl.Color{209, 109, 167, 255},
		fast_inter_panel = {0.0, 0.0, 125.0, 175.0},
	}
}

BatchColor :: rl.PURPLE
Batch :: struct {
	name:  string,
	color: rl.Color,
}

generate_batch_type :: proc(str: string) -> Batch {
	return Batch{name = str, color = BatchColor}
}

Element :: struct {
	rect: rl.Rectangle,
	type: ElementType,
}


add_element :: proc(node: ^Node, type: ElementType) {
	rect: rl.Rectangle
	rect.x = node.body.x
	// TODO: gonna have to change it when we allow more than 10 elements
	rect.y = f32(len(node.elements)) * ElementHeight + node.body.y
	rect.width = node.body.width
	rect.height = ElementHeight
	e := Element {
		rect = rect_without_outline(rect),
		type = type,
	}
	append(&node.elements, e)
}

Node :: struct {
	//rects (and title)
	bg:                   ColoredRect,
	title:                string,
	header:               rl.Rectangle,
	body:                 rl.Rectangle,
	footer:               rl.Rectangle,
	color:                rl.Color,
	add_icon:             ColoredTexturedRect,
	select_task:          ColoredRect,
	select_batch:         ColoredRect,
	//other
	elements:             [dynamic]Element,
	writing_task:         bool,
	adding_batch:         bool,
	clicked_add_icon:     bool,
	//moving elements around
	held_element_idx:     int,
	held_element_offset:  int,
	held_element_copy:    Element,
	in_between_rect:      rl.Rectangle,

	//for rendering batch contents
	owner:                int,
	fast_inter_panel_idx: int,
}

swap_elements :: proc(node: ^Node, idx1, idx2: int) {
	tmp := node.elements[idx1]
	node.elements[idx1] = node.elements[idx2]
	node.elements[idx2] = tmp
}

node_update :: proc(node: ^Node) {
	//----------------ADD rect thingies-----------------
	if collission_mouse_rect(node.add_icon.rect) {
		node.add_icon.color = rl.GRAY

		if rl.IsMouseButtonPressed(.LEFT) {
			node.clicked_add_icon = !node.clicked_add_icon
		}
	} else {
		node.add_icon.color = rl.WHITE
	}

	if node.clicked_add_icon {
		if collission_mouse_rect(node.select_task.rect) && len(node.elements) < 10 {
			node.select_task.color = rl.Color{247, 166, 213, 255}

			if rl.IsMouseButtonPressed(.LEFT) {
				node.writing_task = true
			}
		} else if len(node.elements) == 10 {
			node.select_task.color = rl.Color{181, 161, 173, 255}
		} else {
			node.select_task.color = rl.PINK
		}

		if collission_mouse_rect(node.select_batch.rect) && len(node.elements) < 10 {
			node.select_batch.color = rl.Color{229, 191, 255, 255}

			if rl.IsMouseButtonPressed(.LEFT) {
				node.adding_batch = true
			}
		} else if len(node.elements) == 10 {
			node.select_batch.color = rl.Color{181, 161, 173, 255}
		} else {
			node.select_batch.color = rl.PURPLE
		}
	}

	//----------------updating elements based on their type----------------------
	for &element, i in node.elements {

		switch &t in element.type {
		case Task:
			left, content := split_rect(element.rect, t.ver_split_per)

			//checkbox and delete
			checkbox, delete := split_rect(left, 0.5)

			if collission_mouse_rect(checkbox) {
				t.checkbox_color = rl.Color{155, 242, 128, 255}

				if rl.IsMouseButtonPressed(.LEFT) {
					// NOTE: deleting an element here. Very important
					ordered_remove(&node.elements, i)
					for j in i ..< len(node.elements) {
						node.elements[j].rect.y -= ElementHeight
					}
					if i < node.owner {
						node.owner -= 1
					}

					node.fast_inter_panel_idx = -1
				}
			} else {
				t.checkbox_color = rl.WHITE
			}

			if collission_mouse_rect(delete) {
				t.delete_color = rl.Color{242, 139, 128, 255}

				if rl.IsMouseButtonPressed(.LEFT) {
					// NOTE: deleting an element here. Very important
					ordered_remove(&node.elements, i)
					for j in i ..< len(node.elements) {
						node.elements[j].rect.y -= ElementHeight
					}
					if i < node.owner {
						node.owner -= 1
					}

					node.fast_inter_panel_idx = -1
				}
			} else {
				t.delete_color = rl.WHITE
			}

			//content
			if collission_mouse_rect(content) &&
			   rl.IsMouseButtonDown(.LEFT) &&
			   node.held_element_idx == -1 {
				node.held_element_copy = element

				node.held_element_idx = i

				node.fast_inter_panel_idx = -1
			}

			//the whole rect (opening more fast interaction mode via right click)
			if collission_mouse_rect(element.rect) && rl.IsMouseButtonPressed(.RIGHT) {
				if node.fast_inter_panel_idx == i {
					node.fast_inter_panel_idx = -1
				} else {
					node.fast_inter_panel_idx = i
				}

				t.fast_inter_panel.x = rl.GetMousePosition().x
				t.fast_inter_panel.y = rl.GetMousePosition().y
			}

		case Batch:
			if collission_mouse_rect(element.rect) &&
			   rl.IsMouseButtonDown(.LEFT) &&
			   node.held_element_idx == -1 {
				node.held_element_copy = element

				node.held_element_idx = i

				node.fast_inter_panel_idx = -1
			}

			if collission_mouse_rect(element.rect) && rl.IsMouseButtonPressed(.RIGHT) {
				node.owner = i

				node.fast_inter_panel_idx = -1
			}
		}
	}


	if rl.IsMouseButtonReleased(.LEFT) {
		//some element is picked and we have to let it go
		if node.held_element_idx != -1 {
			collided_elements := abs(node.held_element_offset) + node.held_element_idx

			for i in 0 ..< (-abs(node.held_element_offset)) {
				swap_elements(node, collided_elements + i, node.held_element_idx)
			}

			node.held_element_offset = 0
		}


		node.held_element_idx = -1
	}

	if node.held_element_idx != -1 {
		node.held_element_copy.rect.y += rl.GetMouseDelta().y
		//collission with vertical body rect walls
		if node.held_element_copy.rect.y < node.body.y {
			node.held_element_copy.rect.y = node.body.y
		}
		if node.held_element_copy.rect.y + node.held_element_copy.rect.height >
		   node.body.y + node.body.height {
			node.held_element_copy.rect.y =
				node.body.y + node.body.height - node.held_element_copy.rect.height
		}

		for element, i in node.elements {
			picked_rect := node.elements[node.held_element_idx].rect
			if same_rect(picked_rect, element.rect) {
				continue
			}

			if rl.CheckCollisionPointRec(rl.GetMousePosition(), element.rect) {
				diff_y := sign(node.elements[node.held_element_idx].rect.y - element.rect.y)

				node.elements[i].rect.y += ElementHeight * diff_y
				node.elements[node.held_element_idx].rect.y -= ElementHeight * diff_y
				node.held_element_offset += int(diff_y)

				break
			}

		}
	}
}

node_render :: proc(node: Node) {
	rl.DrawRectangleRec(rect_with_outline(node.bg.rect, 8.0), rl.WHITE)
	rl.DrawRectangleRec(node.bg.rect, node.bg.color)

	rl.DrawRectangleRec(node.header, node.color)
	header_padding := rl.Vector2{node.header.width / 4, node.header.height / 4}
	if node.owner == -1 {
		adjust_and_draw_text(node.title, node.header, header_padding)
	} else {
		adjust_and_draw_text(
			node.elements[node.owner].type.(Batch).name,
			node.header,
			header_padding,
		)
	}

	rl.DrawRectangleRec(node.body, node.color)
	for element, i in node.elements {
		if i == node.held_element_idx {
			continue
		}


		switch t in element.type {
		case Task:
			left, content := split_rect(element.rect, t.ver_split_per)

			//task util buttons
			//background color
			rl.DrawRectangleRec(left, t.left_color)

			//checkbox and delete buttons
			checkbox, delete := split_rect(left, 0.5)
			rl.DrawRectangleRec(rect_without_outline(checkbox, 8.0), t.checkbox_color)
			rl.DrawRectangleRec(rect_without_outline(delete, 8.0), t.delete_color)

			//content
			rl.DrawRectangleRec(content, t.color)

			padding := rl.Vector2{10.0, 10.0}
			adjust_and_draw_text(t.task, content, padding, 30.0)

		case Batch:
			rl.DrawRectangleRec(element.rect, t.color)

			padding := rl.Vector2{10.0, 10.0}
			adjust_and_draw_text(t.name, element.rect, padding, 30.0)

		}
	}


	rl.DrawRectangleRec(node.footer, node.color)
	draw_texture_on_rect(node.add_icon.rect, node.add_icon.texture, node.add_icon.color)

	if node.clicked_add_icon {
		rl.DrawRectangleRec(node.select_task.rect, node.select_task.color)
		adjust_and_draw_text("Add task", node.select_task.rect, {10.0, 10.0})
		rl.DrawRectangleRec(node.select_batch.rect, node.select_batch.color)
		adjust_and_draw_text("Add batch", node.select_batch.rect, {10.0, 10.0})
	}

	rl.DrawRectangleRec(node.in_between_rect, rl.PINK)

	if node.held_element_idx != -1 {

		copy := node.held_element_copy
		switch t in copy.type {
		case Task:
			rl.DrawRectangleRec(copy.rect, {t.color.r, t.color.g, t.color.b, 125})

			padding := rl.Vector2{10.0, 10.0}
			adjust_and_draw_text(t.task, copy.rect, padding, 30.0)
		case Batch:
			rl.DrawRectangleRec(copy.rect, {t.color.r, t.color.g, t.color.b, 125})

			padding := rl.Vector2{10.0, 10.0}
			adjust_and_draw_text(t.name, copy.rect, padding, 30.0)

		}
	}

	//fast interaction panel
	if node.fast_inter_panel_idx != -1 {
		for element, i in node.elements {
			if node.fast_inter_panel_idx == i {
				rl.DrawRectangleRec(
					rect_with_outline(element.type.(Task).fast_inter_panel),
					rl.WHITE,
				)
				rl.DrawRectangleRec(element.type.(Task).fast_inter_panel, node.color)
			}
		}
	}
}
