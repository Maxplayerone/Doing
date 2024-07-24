package main

import "core:fmt"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

Width :: 1280
Height :: 960

main :: proc() {
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.InitWindow(Width, Height, "doing")
	rl.SetWindowPosition(10, 30)
	rl.SetTargetFPS(60)

	target := rl.LoadRenderTexture(Width, Height)
	rl.SetTextureFilter(target.texture, .BILINEAR)

	node := Node {
		rect           = rl.Rectangle{Width / 2 - 300, Height / 2 - 450, 600, 900},
		bg_color       = rl.Color{38, 38, 38, 255},
		header_color   = rl.Color{65, 65, 65, 255},
		title          = "default node",
		add_icon       = rl.LoadTexture("res/add_icon.png"),
		add_icon_color = rl.WHITE,
		held_element   = -1,
	}
	header_rel_size := f32(0.15)
	body_rel_size := f32(0.75)
	footer_rel_size := f32(0.1)
	node.header_rect = rect_without_outline(slice_rect_ver(node.rect, header_rel_size, 0.0))
	node.body_rect = rect_without_outline(
		slice_rect_ver(node.rect, body_rel_size, header_rel_size),
	)
	node.footer_rect = rect_without_outline(
		slice_rect_ver(node.rect, footer_rel_size, header_rel_size + body_rel_size),
	)
	node.add_icon_rect = {
		node.footer_rect.x + 16.0,
		node.footer_rect.y + node.footer_rect.height - 72.0,
		64.0,
		64.0,
	}

	footer_rect_no_icon := rl.Rectangle {
		node.footer_rect.x + 80.0,
		node.footer_rect.y,
		node.footer_rect.width - 80.0,
		node.footer_rect.height,
	}
	select_task_outline, select_batch_outline := split_rect(footer_rect_no_icon, 0.5)
	node.select_task_rect = rect_without_outline(select_task_outline, 10.0)
	node.select_batch_rect = rect_without_outline(select_batch_outline, 10.0)

	ElementHeight = node.body_rect.height / f32(MaxElementDisplay)
	//BatchHeight = node.body_rect.height * 2 / f32(MaxElementDisplay)
	BatchHeight = ElementHeight

	buf: [dynamic]rl.KeyboardKey
	if ElementHeight == 0 || BatchHeight == 0 {
		assert(false, "forgor to setup ElementHeight or BatchHeight")
	}

	for !rl.WindowShouldClose() {
		scale := min(f32(rl.GetScreenWidth()) / Width, f32(rl.GetScreenHeight()) / Height)

		node_update(&node)
		if rl.IsKeyPressed(.N) &&
		   len(node.elements) < 10 &&
		   !node.writing_task &&
		   !node.adding_batch {
			node.writing_task = true
			_ = rl.GetKeyPressed()
		}
		if rl.IsKeyPressed(.B) && !node.adding_batch && !node.writing_task {
			node.adding_batch = true
			_ = rl.GetKeyPressed()
		}

		if rl.IsKeyPressed(.P) && len(node.elements) == 0 {
			generate_10_random_tasks(&node)
		}

		//drawing
		rl.BeginTextureMode(target)
		node_render(node)

		//it is in render because the input panel has to render over the node
		if node.writing_task {
			if str, ok := input_panel("Write a task", &buf); ok {
				add_element(&node, strings.clone(str))

				node.writing_task = false
				clear(&buf)
			}
		}
		if node.adding_batch {
			if str, ok := input_panel("What's the batch name?", &buf); ok {
				add_batch(&node, strings.clone(str))

				node.adding_batch = false
				clear(&buf)
			}
		}

		rl.EndTextureMode()
		//drawing to the texture
		rl.BeginDrawing()
		rl.ClearBackground(rl.Color{214, 214, 214, 255})

		rl.DrawTexturePro(
			target.texture,
			{0.0, 0.0, f32(target.texture.width), -f32(target.texture.height)},
			{
				(f32(rl.GetScreenWidth()) - Width * scale) * 0.5,
				(f32(rl.GetScreenHeight()) - Height * scale) * 0.5,
				Width * scale,
				Height * scale,
			},
			{0.0, 0.0},
			0.0,
			rl.WHITE,
		)

		rl.EndDrawing()

		//cleanup
		//fmt.println(node.held_element)
		fmt.println(Width * scale, Width * scale)

		free_all(context.temp_allocator)
	}

	delete(buf)

	for element in node.elements {
		delete(element.task)
	}
	delete(node.elements)

	for batch in node.batches {
		delete(batch.name)
		delete(batch.indicies)
	}
	delete(node.batches)

	rl.CloseWindow()

	for key, value in tracking_allocator.allocation_map {
		fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
	}
}
