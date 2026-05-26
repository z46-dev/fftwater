package ocean

import "math"

// Fast Fourier Transform (FFT) is an algorithm to compute the Discrete Fourier Transform (DFT) efficiently.
// This means that we can transform a signal from the time domain to the frequency domain
// (and vice versa) in O(n log n) time, which is much faster than the naive O(n^2) approach.

// fft1D performs the Fast Fourier Transform (FFT) on a 1D slice of complex numbers.
// If inverse is true, it computes the inverse FFT.
// We use complex numbers because the FFT can produce complex results, even if the input is real.
func fft1D(a []complex128, inverse bool) {
	var n, j int = len(a), 0

	// Bit-reversal permutation
	for i := 1; i < n; i++ {
		var bit int = n >> 1
		for ; j&bit != 0; bit >>= 1 {
			j ^= bit
		}

		if j ^= bit; i < j {
			a[i], a[j] = a[j], a[i]
		}
	}

	// Cooley-Tukey FFT
	for length := 2; length <= n; length <<= 1 {
		var angle float64 = 2 * math.Pi / float64(length)
		if !inverse {
			angle = -angle
		}

		var (
			wLen complex128 = complex(math.Cos(angle), math.Sin(angle))
			half int        = length >> 1
		)

		for i := 0; i < n; i += length {
			var w complex128 = complex(1, 0)
			for k := range half {
				var u, v = a[i+k], a[i+k+half] * w

				a[i+k] = u + v
				a[i+k+half] = u - v
				w *= wLen
			}
		}
	}

	// If it's an inverse FFT, we need to divide each element by n to get the correct result.
	if inverse {
		var invN complex128 = complex(1/float64(n), 0)
		for i := range a {
			a[i] *= invN
		}
	}
}

// fft2D performs the 2D Fast Fourier Transform (FFT) on a 2D slice of complex numbers.
// The data is stored in a 1D slice, but we treat it as a 2D array of size n x n.
// If inverse is true, it computes the inverse FFT.
func fft2D(data []complex128, n int, inverse bool) {
	var row, col []complex128 = make([]complex128, n), make([]complex128, n)

	// Perform FFT on each row
	for y := range n {
		copy(row, data[y*n:(y+1)*n])
		fft1D(row, inverse)
		copy(data[y*n:(y+1)*n], row)
	}

	// Perform FFT on each column
	for x := range n {
		for y := range n {
			col[y] = data[y*n+x]
		}

		fft1D(col, inverse)
		for y := range n {
			data[y*n+x] = col[y]
		}
	}
}

func isPowerOfTwo(n int) bool {
	return n > 0 && (n&(n-1)) == 0
}
