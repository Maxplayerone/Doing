package main

import rl "vendor:raylib"
import "core:fmt"
import "core:mem"

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
    node.add_icon_rect = {node.footer_rect.x + node.footer_rect.width - 72.0, node.footer_rect.y + node.footer_rect.height  - 72.0, 64.0, 64.0}

    for !rl.WindowShouldClose(){

        node_update(&node)
        if rl.IsKeyPressed(.B) && node.elements < 10{
            node.elements += 1
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.Color{214, 214, 214, 255})

        node_render(node)

        rl.EndDrawing()

        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}