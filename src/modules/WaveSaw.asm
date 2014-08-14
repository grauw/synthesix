;
; A sawtooth waveform
;
WaveSaw: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveSaw_labels
	_size:
	ENDM

	dw WaveSaw._size
WaveSaw_class: WaveSaw

; ix, de <- new object
WaveSaw_New:
	ld iy,WaveSaw_class
	call Class_New
	call WaveSaw_Constructor
	ret

; ix = this
; ix, de <- this
WaveSaw_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,WaveSaw_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
WaveSaw_Update: PROC
	ld l,(ix + WaveSaw.phase)
	ld h,(ix + WaveSaw.phase + 1)
	ld a,(hl)
	srl a
	ld (ix + WaveSaw.value),a
	ret
	ENDP

;
WaveSaw_labels:
	db 252,253," Wave",0
	db "Value",0
	db "Phase",0
