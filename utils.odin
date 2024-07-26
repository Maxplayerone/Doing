package main

sign :: proc(v: f32) -> f32 {
	if v > 0.0 {
		return 1.0
	} else {
		return -1.0
	}
}

abs :: proc(v: int) -> int {
	if v > 0 {
		return v
	} else {
		return v * -1
	}
}
