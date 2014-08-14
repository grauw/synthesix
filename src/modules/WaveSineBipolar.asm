;
; A bipolar sine waveform
;
WaveSineBipolar: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveSineBipolar_labels
	_size:
	ENDM

	dw WaveSineBipolar._size
WaveSineBipolar_class: WaveSineBipolar

; ix, de <- new object
WaveSineBipolar_New:
	ld iy,WaveSineBipolar_class
	call Class_New
	call WaveSineBipolar_Constructor
	ret

; ix = this
; ix, de <- this
WaveSineBipolar_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,WaveSineBipolar_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
WaveSineBipolar_Update: PROC
	ld l,(ix + WaveSineBipolar.phase)
	ld h,(ix + WaveSineBipolar.phase + 1)
	ld l,(hl)
	ld h,WaveSineBipolar_table >> 8
	ld a,(hl)
	ld (ix + WaveSineBipolar.value),a
	ret
	ENDP

;
	SECTION ROM_TABLES

	ALIGN 100H
WaveSineBipolar_table:
	db 0, 3, 6, 9, 12, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 46
	db 49, 51, 54, 57, 60, 63, 65, 68, 71, 73, 76, 78, 81, 83, 85, 88
	db 90, 92, 94, 96, 98, 100, 102, 104, 106, 107, 109, 111, 112, 113, 115, 116
	db 117, 118, 120, 121, 122, 122, 123, 124, 125, 125, 126, 126, 126, 127, 127, 127
	db 127, 127, 127, 127, 126, 126, 126, 125, 125, 124, 123, 122, 122, 121, 120, 118
	db 117, 116, 115, 113, 112, 111, 109, 107, 106, 104, 102, 100, 98, 96, 94, 92
	db 90, 88, 85, 83, 81, 78, 76, 73, 71, 68, 65, 63, 60, 57, 54, 51
	db 49, 46, 43, 40, 37, 34, 31, 28, 25, 22, 19, 16, 12, 9, 6, 3
	db -1, -4, -7, -10, -13, -17, -20, -23, -26, -29, -32, -35, -38, -41, -44, -47
	db -50, -52, -55, -58, -61, -64, -66, -69, -72, -74, -77, -79, -82, -84, -86, -89
	db -91, -93, -95, -97, -99, -101, -103, -105, -107, -108, -110, -112, -113, -114, -116, -117
	db -118, -119, -121, -122, -123, -123, -124, -125, -126, -126, -127, -127, -127, -128, -128, -128
	db -128, -128, -128, -128, -127, -127, -127, -126, -126, -125, -124, -123, -123, -122, -121, -119
	db -118, -117, -116, -114, -113, -112, -110, -108, -107, -105, -103, -101, -99, -97, -95, -93
	db -91, -89, -86, -84, -82, -79, -77, -74, -72, -69, -66, -64, -61, -58, -55, -52
	db -50, -47, -44, -41, -38, -35, -32, -29, -26, -23, -20, -17, -13, -10, -7, -4

	ENDS

;
WaveSineBipolar_labels:
	db 248,249," Wave Bipolar",0
	db "Value",0
	db "Phase",0
