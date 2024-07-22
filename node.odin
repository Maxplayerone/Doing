package main

import rl "vendor:raylib"

import "core:strings"
import "core:fmt"

MaxElementDisplay :: 10
//settings those two up and the start of the program
ElementHeight := f32(0)
BatchHeight := f32(0)

Element :: struct{
    element_rect: rl.Rectangle,
    checkbox_rect: rl.Rectangle,
    task_rect: rl.Rectangle,
    task: string,
}

add_element :: proc(node: ^Node, name: string){
    element: Element

    element_rect_with_outline := rl.Rectangle{node.body_rect.x, node.body_rect.y + node.horizontal_cursor, node.body_rect.width, ElementHeight}
    node.horizontal_cursor += ElementHeight 
    element.element_rect = rect_without_outline(element_rect_with_outline)
    element.checkbox_rect, element.task_rect = slice_rect(element.element_rect, 0.1)
    element.task = name
    append(&node.elements, element)
}

/*
regenerate_element_rects :: proc(body_rect: rl.Rectangle, element: ^Element, i: int){
    element_rect_with_outline := rl.Rectangle{body_rect.x, body_rect.y + f32(i) * ElementHeight, body_rect.width, ElementHeight}
    element.element_rect = rect_without_outline(element_rect_with_outline)
    element.checkbox_rect, element.task_rect = slice_rect(element.element_rect, 0.1)
}
*/

Batch :: struct{
    indicies: [dynamic]int,
    name: string,
    rect_with_outline: rl.Rectangle,
    rect: rl.Rectangle,
}

add_batch :: proc(node: ^Node, name: string){
    batch: Batch
    batch.name = name
    batch.rect_with_outline = rl.Rectangle{node.body_rect.x, node.body_rect.y + node.horizontal_cursor, node.body_rect.width, BatchHeight} 
    node.horizontal_cursor += BatchHeight
    batch.rect = rect_without_outline(batch.rect_with_outline)

    append(&node.batches, batch)
}

Node :: struct{
    rect: rl.Rectangle,
    bg_color: rl.Color,

    title: string,
    header_rect: rl.Rectangle,
    header_color: rl.Color,

    body_rect: rl.Rectangle,
    horizontal_cursor: f32,
    elements: [dynamic]Element,
    writing_task: bool,
    adding_batch: bool,

    batches: [dynamic]Batch,

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
            node.clicked_add_icon = !node.clicked_add_icon 
        }
    }
    else{
        node.add_icon_color = rl.WHITE
    }

    if node.clicked_add_icon{

        if collission_mouse_rect(node.select_task_rect) && len(node.elements) < 10{
            node.select_task_color = rl.Color{247, 166, 213, 255}

            if rl.IsMouseButtonPressed(.LEFT){
                node.writing_task = true
            }
        }
        else if len(node.elements) == 10{
            node.select_task_color = rl.Color{181, 161, 173, 255}
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
    deleted_element_threshhold := f32(0.0)
    for element, i in node.elements{
        if collission_mouse_rect(element.checkbox_rect){
            if rl.IsMouseButtonPressed(.LEFT){
                deleted_element_threshhold = rect_with_outline(element.element_rect).y
                delete(element.task)
                ordered_remove(&node.elements, i)
                regenerate_rects = true
                break
            }
        }
    }
    if regenerate_rects{
        for &element in node.elements{
            if rect_with_outline(element.element_rect).y > deleted_element_threshhold{
                element.element_rect.y -= ElementHeight
                element.checkbox_rect, element.task_rect = slice_rect(element.element_rect, 0.1)
            }
        }
        for &batch in node.batches{
            if batch.rect_with_outline.y > deleted_element_threshhold{
                batch.rect_with_outline.y -= BatchHeight
                batch.rect.y -= BatchHeight
            }
        }

        node.horizontal_cursor -= ElementHeight
        regenerate_rects = false
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

    for batch in node.batches{
        rl.DrawRectangleRec(batch.rect, rl.WHITE)
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