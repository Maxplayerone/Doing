package main

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

Width :: 1280 
Height :: 960 

main :: proc(){
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.InitWindow(Width, Height, "doing")
    rl.SetTargetFPS(60)

    node := Node{
        rect = rl.Rectangle{Width / 2 - 300, Height / 2 - 450, 600, 900},
        bg_color = rl.Color{38, 38, 38, 255},
        header_color = rl.Color{65, 65, 65, 255},
        title = "deault node",
    }
    header_rel_size := f32(0.15)
    body_rel_size := f32(0.75)
    footer_rel_size := f32(0.1)
    node.header_rect = rect_without_outline(slice_rect_ver(node.rect, header_rel_size, 0.0))
    node.body_rect = rect_without_outline(slice_rect_ver(node.rect, body_rel_size, header_rel_size))
    node.footer_rect = rect_without_outline(slice_rect_ver(node.rect, footer_rel_size, header_rel_size + body_rel_size))

    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        rl.ClearBackground(rl.Color{214, 214, 214, 255})

        node_render(node)

        rl.EndDrawing()

        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}