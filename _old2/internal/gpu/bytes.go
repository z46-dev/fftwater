package gpu

import "unsafe"

// Float32Bytes returns a byte slice that shares the same underlying memory as the input float32 slice.
func Float32Bytes(values []float32) []byte {
	if len(values) == 0 {
		return nil
	}

	return unsafe.Slice((*byte)(unsafe.Pointer(&values[0])), len(values)*4)
}

// Uint32Bytes returns a byte slice that shares the same underlying memory as the input uint32 slice.
func Uint32Bytes(values []uint32) []byte {
	if len(values) == 0 {
		return nil
	}

	return unsafe.Slice((*byte)(unsafe.Pointer(&values[0])), len(values)*4)
}
