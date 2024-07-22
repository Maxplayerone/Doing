package main

import "core:strings"

import rl "vendor:raylib"

input_panel :: proc(header: string, buf: ^[dynamic]rl.KeyboardKey) -> (string, bool){
    clicked_enter := false

    rl.DrawRectangleRec({0.0, 0.0, Width, Height}, {0.0, 0.0, 0.0, 200})
    title_rect := rl.Rectangle{Width / 2 - 300.0, 50.0, 800.0, 100.0}
    footer_rect := rl.Rectangle{Width / 2 - 400.0, Height - 150.0, 800.0, 100.0}

    rl.DrawRectangleRec(title_rect, rl.BLACK)
    adjust_and_draw_text(header, title_rect, {0.0, 0.0}, 80.0)
    adjust_and_draw_text("type [ENTER] to confirm", footer_rect, {0.0, 0.0})

    text_rect := rl.Rectangle{Width / 2 - 400.0, Height / 2 - 200.0, 800.0, 400.0}
    str_buf := strings.builder_make(context.temp_allocator)

    if key := rl.GetKeyPressed(); key != .KEY_NULL{
        if key == .BACKSPACE && len(buf) != 0{
            pop(buf)
        }
        else if key == .ENTER{
            clicked_enter = true
        }
        else if key == .LEFT_SHIFT{
            //ignore
        }
        else{
            append(buf, key)
        }
    }

    for letter in buf{
        strings.write_rune(&str_buf, rune(letter))
    }
    adjust_and_draw_text(strings.to_string(str_buf), text_rect, {0.0, 0.0})
    return strings.to_string(str_buf), clicked_enter
}