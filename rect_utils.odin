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
