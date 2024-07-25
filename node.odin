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

Element :: struct {
	rect: rl.Rectangle,
	task: string,
}

add_element :: proc(node: ^Node, str: string) {
	rect: rl.Rectangle
	rect.x = node.body.x
	// TODO: gonna have to change it when we allow more than 10 elements
	rect.y = f32(len(node.elements)) * ElementHeight + node.body.y
	rect.width = node.body.width
	rect.height = ElementHeight
	e := Element{rect, str}
	append(&node.elements, e)
}

Node :: struct {
	//rects (and title)
	bg:               ColoredRect,
	title:            string,
	header:           rl.Rectangle,
	body:             rl.Rectangle,
	footer:           rl.Rectangle,
	color:            rl.Color,
	add_icon:         ColoredTexturedRect,
	select_task:      ColoredRect,
	select_batch:     ColoredRect,
	//other
	elements:         [dynamic]Element,
	writing_task:     bool,
	adding_batch:     bool,
	clicked_add_icon: bool,
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

		if collission_mouse_rect(node.select_batch.rect) {
			node.select_batch.color = rl.Color{229, 191, 255, 255}

			if rl.IsMouseButtonPressed(.LEFT) {
				node.adding_batch = true
			}
		} else {
			node.select_batch.color = rl.PURPLE
		}
	}

}

node_render :: proc(node: Node) {
	rl.DrawRectangleRec(rect_with_outline(node.bg.rect, 8.0), rl.WHITE)
	rl.DrawRectangleRec(node.bg.rect, node.bg.color)

	rl.DrawRectangleRec(node.header, node.color)
	header_padding := rl.Vector2{node.header.width / 4, node.header.height / 4}
	adjust_and_draw_text(node.title, node.header, header_padding)

	rl.DrawRectangleRec(node.body, node.color)
	for element in node.elements {
		//rl.DrawRectangleRec(element.checkbox.rect, rl.ORANGE)
		//rl.DrawRectangleRec(element.task.rect, rl.LIME)


		//padding := rl.Vector2{10.0, 10.0}
		//adjust_and_draw_text(element.task, element.task_rect, padding, 30.0)
		rl.DrawRectangleRec(rect_without_outline(element.rect), rl.ORANGE)
	}


	rl.DrawRectangleRec(node.footer, node.color)
	draw_texture_on_rect(node.add_icon.rect, node.add_icon.texture, node.add_icon.color)

	if node.clicked_add_icon {
		rl.DrawRectangleRec(node.select_task.rect, node.select_task.color)
		adjust_and_draw_text("Add task", node.select_task.rect, {10.0, 10.0})
		rl.DrawRectangleRec(node.select_batch.rect, node.select_batch.color)
		adjust_and_draw_text("Add batch", node.select_batch.rect, {10.0, 10.0})
	}
}
