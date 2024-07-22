package main

import rl "vendor:raylib"
import "core:fmt"
import "core:mem"
import "core:strings"

Width :: 1280 
Height :: 960 

main :: proc(){
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    //rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.InitWindow(Width, Height, "doing")
    rl.SetTargetFPS(60)

    node := Node{
        rect = rl.Rectangle{Width / 2 - 300, Height / 2 - 450, 600, 900},
        bg_color = rl.Color{38, 38, 38, 255},
        header_color = rl.Color{65, 65, 65, 255},
        title = "default node",
        add_icon = rl.LoadTexture("res/add_icon.png"),
        add_icon_color = rl.WHITE
    }
    header_rel_size := f32(0.15)
    body_rel_size := f32(0.75)
    footer_rel_size := f32(0.1)
    node.header_rect = rect_without_outline(slice_rect_ver(node.rect, header_rel_size, 0.0))
    node.body_rect = rect_without_outline(slice_rect_ver(node.rect, body_rel_size, header_rel_size))
    node.footer_rect = rect_without_outline(slice_rect_ver(node.rect, footer_rel_size, header_rel_size + body_rel_size))
    node.add_icon_rect = {node.footer_rect.x + 16.0, node.footer_rect.y + node.footer_rect.height  - 72.0, 64.0, 64.0}

    footer_rect_no_icon := rl.Rectangle{node.footer_rect.x + 80.0, node.footer_rect.y, node.footer_rect.width - 80.0, node.footer_rect.height}
    select_task_outline, select_batch_outline := slice_rect(footer_rect_no_icon, 0.5)
    node.select_task_rect = rect_without_outline(select_task_outline, 10.0)
    node.select_batch_rect = rect_without_outline(select_batch_outline, 10.0)

    buf: [dynamic]rl.KeyboardKey
    //generate_10_random_tasks(&node)
    for !rl.WindowShouldClose(){

        node_update(&node)
        if rl.IsKeyPressed(.N) && len(node.elements) < 10 && !node.writing_task{
            node.writing_task = true 
            _ = rl.GetKeyPressed()
        }
        if rl.IsKeyPressed(.B) && !node.adding_batch{
            node.adding_batch = true
            _ = rl.GetKeyPressed()
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.Color{214, 214, 214, 255})

        node_render(node)

        //it is in render because the input panel has to render over the node
        if node.writing_task{
            if str, ok := input_panel("Write a task", &buf); ok{
                add_element(&node, strings.clone(str))

                node.writing_task = false
                clear(&buf)
            }
        }
        if node.adding_batch{
            if str, ok := input_panel("What's the batch name?", &buf); ok{
                //add_element(&node, strings.clone(str))

                node.adding_batch = false
                clear(&buf)
            }
        }

        rl.EndDrawing()

        free_all(context.temp_allocator)
    }
    delete(buf)
    for element in node.elements{
        delete(element.task)
    }
    delete(node.elements)

    rl.CloseWindow()

    for key, value in tracking_allocator.allocation_map{
        fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
    }
}