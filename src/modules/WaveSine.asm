;
; A sine waveform
;
WaveSine: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveSine_labels
	_size:
	ENDM

	dw WaveSine._size
WaveSine_class: WaveSine

; ix, de <- new object
WaveSine_New:
	ld iy,WaveSine_class
	call Class_New
	call WaveSine_Constructor
	ret

; ix = this
; ix, de <- this
WaveSine_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,WaveSine_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
WaveSine_Update: PROC
	ld l,(ix + WaveSine.phase)
	ld h,(ix + WaveSine.phase + 1)
	ld l,(hl)
	ld h,WaveSineBipolar_table >> 8
	ld a,(hl)
	add a,128
	srl a
	ld (ix + WaveSine.value),a
	ret
	ENDP

;
WaveSine_labels:
	db 248,249," Wave",0
	db "Value",0
	db "Phase",0
