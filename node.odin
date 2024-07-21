package main

import rl "vendor:raylib"

import "core:strings"

Node :: struct{
    rect: rl.Rectangle,
    bg_color: rl.Color,

    title: string,
    header_rect: rl.Rectangle,
    header_color: rl.Color,

    body_rect: rl.Rectangle,
    elements: int,

    footer_rect: rl.Rectangle,
    add_icon: rl.Texture2D,
    add_icon_rect: rl.Rectangle,
    add_icon_color: rl.Color,
}

node_update :: proc(node: ^Node){
    if collission_mouse_rect(node.add_icon_rect){
        node.add_icon_color = rl.GRAY

        if rl.IsMouseButtonPressed(.LEFT){
            if node.elements < 10{
                node.elements += 1
            }
        }
    }
    else{
        node.add_icon_color = rl.WHITE
    }
}

node_render :: proc(node: Node){
    rl.DrawRectangleRec(rect_with_outline(node.rect, 8.0), rl.WHITE)
    rl.DrawRectangleRec(node.rect, node.bg_color)

    rl.DrawRectangleRec(node.header_rect, node.header_color)
    header_padding := rl.Vector2{node.header_rect.width / 4, node.header_rect.height / 4}
    adjust_and_draw_text(node.title, node.header_rect, header_padding)

    rl.DrawRectangleRec(node.body_rect, node.header_color)
    for i in 0..<node.elements{
        element_height := node.body_rect.height / 10
        element_rect_with_outline := rl.Rectangle{node.body_rect.x, node.body_rect.y + f32(i) * element_height,node.body_rect.width, element_height}
        element_rect := rect_without_outline(element_rect_with_outline)
        rl.DrawRectangleRec(element_rect, rl.RED)
    }

    rl.DrawRectangleRec(node.footer_rect, node.header_color)
    draw_texture_on_rect(node.add_icon_rect, node.add_icon, node.add_icon_color)
}