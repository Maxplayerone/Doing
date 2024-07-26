package main

sign :: proc(v: f32) -> f32 {
	if v > 0.0 {
		return v
	} else {
		return v * -1.0
	}
}
