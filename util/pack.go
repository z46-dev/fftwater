package util

import (
	"encoding/binary"
	"math"
)

// Float32Bytes packs float32 values as tightly packed little-endian bytes.
// WebGPU WriteBuffer requires 4-byte alignment, which this always satisfies.
func Float32Bytes(values ...float32) []byte {
	out := make([]byte, len(values)*4)
	for i, v := range values {
		binary.LittleEndian.PutUint32(out[i*4:], math.Float32bits(v))
	}
	return out
}
