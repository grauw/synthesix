;
; A triangle waveform
;
WaveTriangle: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveTriangle_labels
	_size:
	ENDM

	dw WaveTriangle._size
WaveTriangle_class: WaveTriangle

; ix, de <- new object
WaveTriangle_New:
	ld iy,WaveTriangle_class
	call Class_New
	call WaveTriangle_Constructor
	ret

; ix = this
; ix, de <- this
WaveTriangle_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,WaveTriangle_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
WaveTriangle_Update: PROC
	ld l,(ix + WaveTriangle.phase)
	ld h,(ix + WaveTriangle.phase + 1)
	ld a,(hl)
	and a
	jp p,Down
	cpl
Down:
	ld (ix + WaveTriangle.value),a
	ret
	ENDP

;
WaveTriangle_labels:
	db 254,255," Wave",0
	db "Value",0
	db "Phase",0
