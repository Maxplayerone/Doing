package main

import rl "vendor:raylib"

slice_rect_ver :: proc(rect: rl.Rectangle, slice_percentage: f32, offset_percentage: f32) -> rl.Rectangle{
    return rl.Rectangle{rect.x, rect.y + rect.height * offset_percentage, rect.width, rect.height * slice_percentage}
}

rect_without_outline :: proc(rect: rl.Rectangle, offset: f32 = 5.0) -> rl.Rectangle{
    return {rect.x + offset, rect.y + offset, rect.width - 2 * offset, rect.height - 2 * offset}
}

rect_with_outline :: proc(rect: rl.Rectangle, offset: f32 = 5.0) -> rl.Rectangle{
    return {rect.x - offset, rect.y - offset, rect.width + 2 * offset, rect.height + 2 * offset}
}

collission_mouse_rect :: proc(rect: rl.Rectangle) -> bool{
    pos := rl.GetMousePosition()
    if pos.x > rect.x && pos.x < rect.x + rect.width && pos.y > rect.y && pos.y < rect.y + rect.height{
        return true
    }
    return false
}

draw_texture_on_rect :: proc(rect: rl.Rectangle, tex: rl.Texture2D, color: rl.Color){
    scale_x := rect.width / f32(tex.width)
    scale_y := rect.height / f32(tex.height)

    if scale_y < scale_x{
        x := rect.x + (rect.width / 2.0 - f32(tex.width) * scale_y * 0.5)
        rl.DrawTextureEx(tex, {x, rect.y}, 0.0, scale_y, color)
    }
    else{
        y := rect.y + (rect.height / 2.0 - f32(tex.height) * scale_x * 0.5)
        rl.DrawTextureEx(tex, {rect.x, y}, 0.0, scale_x, color)
    }
}