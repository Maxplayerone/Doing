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
    //elements: [dynamic]Element,
    writing_task: bool,
    adding_batch: bool,

    batches: [dynamic][dynamic]Element,

    footer_rect: rl.Rectangle,

    add_icon: rl.Texture2D,
    add_icon_rect: rl.Rectangle,
    add_icon_color: rl.Color,

    select_task_rect: rl.Rectangle,
    select_task_color: rl.Color,
    select_batch_rect: rl.Rectangle,
    select_batch_color: rl.Color,
    clicked_add_icon: bool,
}

node_update :: proc(node: ^Node){
    if collission_mouse_rect(node.add_icon_rect){
        node.add_icon_color = rl.GRAY

        if rl.IsMouseButtonPressed(.LEFT){
            if len(node.batches[0]) < 10{
                //node.writing_task = true
                node.clicked_add_icon = !node.clicked_add_icon 
            }
        }
    }
    else{
        node.add_icon_color = rl.WHITE
    }

    if node.clicked_add_icon{

        if collission_mouse_rect(node.select_task_rect){
            node.select_task_color = rl.Color{247, 166, 213, 255}

            if rl.IsMouseButtonPressed(.LEFT){
                node.writing_task = true
            }
        }
        else{
            node.select_task_color = rl.PINK
        }

        if collission_mouse_rect(node.select_batch_rect){
            node.select_batch_color = rl.Color{229, 191, 255, 255}

            if rl.IsMouseButtonPressed(.LEFT){
                node.adding_batch = true
            }
        }
        else{
            node.select_batch_color = rl.PURPLE
        }
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

    if node.clicked_add_icon{
        rl.DrawRectangleRec(node.select_task_rect, node.select_task_color)
        adjust_and_draw_text("Add task", node.select_task_rect, {10.0, 10.0})
        rl.DrawRectangleRec(node.select_batch_rect, node.select_batch_color)
        adjust_and_draw_text("Add batch", node.select_batch_rect, {10.0, 10.0})
    }
}