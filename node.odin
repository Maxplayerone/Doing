package main

import rl "vendor:raylib"

import "core:strings"
import "core:fmt"

Element :: struct{
    element_rect: rl.Rectangle,
    checkbox_rect: rl.Rectangle,
    task_rect: rl.Rectangle,
    task: string,
}

add_element :: proc(node: ^Node, name: string){
    element: Element

    element_height := node.body_rect.height / 10
    element_rect_with_outline := rl.Rectangle{node.body_rect.x, node.body_rect.y + f32(len(node.elements)) * element_height,node.body_rect.width, element_height}
    element.element_rect = rect_without_outline(element_rect_with_outline)
    element.checkbox_rect, element.task_rect = slice_rect(element.element_rect, 0.1)
    element.task = name
    append(&node.elements, element)
}

regenerate_element_rects :: proc(body_rect: rl.Rectangle, element: ^Element, i: int){
    element_height := body_rect.height / 10
    element_rect_with_outline := rl.Rectangle{body_rect.x, body_rect.y + f32(i) * element_height, body_rect.width, element_height}
    element.element_rect = rect_without_outline(element_rect_with_outline)
    element.checkbox_rect, element.task_rect = slice_rect(element.element_rect, 0.1)
}

Node :: struct{
    rect: rl.Rectangle,
    bg_color: rl.Color,

    title: string,
    header_rect: rl.Rectangle,
    header_color: rl.Color,

    body_rect: rl.Rectangle,
    elements: [dynamic]Element,
    writing_task: bool,

    footer_rect: rl.Rectangle,
    add_icon: rl.Texture2D,
    add_icon_rect: rl.Rectangle,
    add_icon_color: rl.Color,
}

node_update :: proc(node: ^Node){
    if collission_mouse_rect(node.add_icon_rect){
        node.add_icon_color = rl.GRAY

        if rl.IsMouseButtonPressed(.LEFT){
            if len(node.elements) < 10{
                node.writing_task = true
            }
        }
    }
    else{
        node.add_icon_color = rl.WHITE
    }

    regenerate_rects := false
    for element, i in node.elements{
        if collission_mouse_rect(element.checkbox_rect){
            if rl.IsMouseButtonPressed(.LEFT){
                delete(element.task)
                ordered_remove(&node.elements, i)
                regenerate_rects = true
            }
        }
    }
    if regenerate_rects{
        for &element, i in node.elements{
            regenerate_element_rects(node.body_rect, &element, i)
        }
    }

}

node_render :: proc(node: Node){
    rl.DrawRectangleRec(rect_with_outline(node.rect, 8.0), rl.WHITE)
    rl.DrawRectangleRec(node.rect, node.bg_color)

    rl.DrawRectangleRec(node.header_rect, node.header_color)
    header_padding := rl.Vector2{node.header_rect.width / 4, node.header_rect.height / 4}
    adjust_and_draw_text(node.title, node.header_rect, header_padding)

    rl.DrawRectangleRec(node.body_rect, node.header_color)
    for element in node.elements{
        rl.DrawRectangleRec(element.checkbox_rect, rl.ORANGE)
        rl.DrawRectangleRec(element.task_rect, rl.LIME)


        padding := rl.Vector2{10.0, 10.0}
        adjust_and_draw_text(element.task, element.task_rect, padding, 30.0)
    }

    rl.DrawRectangleRec(node.footer_rect, node.header_color)
    draw_texture_on_rect(node.add_icon_rect, node.add_icon, node.add_icon_color)
}