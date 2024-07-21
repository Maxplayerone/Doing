package main

import rl "vendor:raylib"

import "core:strings"

Node :: struct{
    rect: rl.Rectangle,
    header_rect: rl.Rectangle,
    body_rect: rl.Rectangle,
    footer_rect: rl.Rectangle,
    bg_color: rl.Color,
    header_color: rl.Color,
    title: string,
}

node_render :: proc(node: Node){
    rl.DrawRectangleRec(rect_with_outline(node.rect, 8.0), rl.WHITE)
    rl.DrawRectangleRec(node.rect, node.bg_color)
    rl.DrawRectangleRec(node.header_rect, node.header_color)
    header_padding := rl.Vector2{node.header_rect.width / 4, node.header_rect.height / 4}
    adjust_and_draw_text(node.title, node.header_rect, header_padding)
    rl.DrawRectangleRec(node.body_rect, node.header_color)
    rl.DrawRectangleRec(node.footer_rect, node.header_color)
}