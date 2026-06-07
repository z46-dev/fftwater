package m3

func Lerp(a, b, t float32) (v float32) {
	v = a + (b-a)*t
	return
}

func Clamp(v, lo, hi float32) (c float32) {
	if v < lo {
		c = lo
		return
	}

	if v > hi {
		c = hi
		return
	}

	c = v
	return
}
