package main

import "core:fmt"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

Width :: 1280
Height :: 960

generate_5_elements :: proc(node: ^Node) {
	add_element(node, generate_task_type("1"))
	add_element(node, generate_task_type("2"))
	add_element(node, generate_batch_type("3"))
	add_element(node, generate_task_type("4"))
	add_element(node, generate_batch_type("5"))
}

main :: proc() {
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.InitWindow(Width, Height, "doing")
	rl.SetWindowPosition(10, 30)
	rl.SetTargetFPS(60)

	node := Node {
		bg               = {
			rl.Rectangle{Width / 2 - 300, Height / 2 - 450, 600, 900},
			rl.Color{38, 38, 38, 255},
		},
		color            = rl.Color{65, 65, 65, 255},
		title            = "default node",
		held_element_idx = -1,
		owner            = -1,
	}
	header_rel_size := f32(0.15)
	body_rel_size := f32(0.75)
	footer_rel_size := f32(0.1)
	node.header = rect_without_outline(slice_rect_ver(node.bg.rect, header_rel_size, 0.0))
	node.body = rect_without_outline(slice_rect_ver(node.bg.rect, body_rel_size, header_rel_size))
	node.footer = rect_without_outline(
		slice_rect_ver(node.bg.rect, footer_rel_size, header_rel_size + body_rel_size),
	)
	node.add_icon = {
		rect    = {node.footer.x + 16.0, node.footer.y + node.footer.height - 72.0, 64.0, 64.0},
		texture = rl.LoadTexture("res/add_icon.png"),
		color   = rl.WHITE,
	}


	footer_rect_no_icon := rl.Rectangle {
		node.footer.x + 80.0,
		node.footer.y,
		node.footer.width - 80.0,
		node.footer.height,
	}
	select_task_outline, select_batch_outline := split_rect(footer_rect_no_icon, 0.5)
	node.select_task.rect = rect_without_outline(select_task_outline, 10.0)
	node.select_batch.rect = rect_without_outline(select_batch_outline, 10.0)

	ElementHeight = node.body.height / f32(MaxElementDisplay)

	buf: [dynamic]rl.KeyboardKey
	if ElementHeight == 0 {
		assert(false, "forgor to setup ElementHeight or BatchHeight")
	}

	generate_5_elements(&node)

	for !rl.WindowShouldClose() {

		node_update(&node)
		if rl.IsKeyPressed(.N) &&
		   len(node.elements) < 10 &&
		   !node.writing_task &&
		   !node.adding_batch {
			node.writing_task = true
			_ = rl.GetKeyPressed()
		}
		if rl.IsKeyPressed(.B) &&
		   !node.adding_batch &&
		   !node.writing_task &&
		   len(node.elements) < 10 {
			node.adding_batch = true
			_ = rl.GetKeyPressed()
		}


		rl.BeginDrawing()
		rl.ClearBackground(rl.Color{214, 214, 214, 255})

		node_render(node)

		//it is in render because the input panel has to render over the node
		if node.writing_task {
			if str, ok := input_panel("Write a task", &buf); ok {
				add_element(&node, generate_task_type(strings.clone(str)))

				node.writing_task = false
				clear(&buf)
			}
		}
		if node.adding_batch {
			if str, ok := input_panel("What's the batch name?", &buf); ok {
				add_element(&node, generate_batch_type(strings.clone(str)))

				node.adding_batch = false
				clear(&buf)
			}
		}

		rl.EndDrawing()

		free_all(context.temp_allocator)
	}
	delete(buf)

	for element in node.elements {
		switch t in element.type {
		case Task:
			delete(t.task)
		case Batch:
			delete(t.name)
		}
	}
	delete(node.elements)

	rl.CloseWindow()

	for key, value in tracking_allocator.allocation_map {
		fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
	}
}
