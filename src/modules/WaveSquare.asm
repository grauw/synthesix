;
; A square waveform
;
WaveSquare: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveSquare_labels
	_size:
	ENDM

	dw WaveSquare._size
WaveSquare_class: WaveSquare

; ix, de <- new object
WaveSquare_New:
	ld iy,WaveSquare_class
	call Class_New
	call WaveSquare_Constructor
	ret

; ix = this
; ix, de <- this
WaveSquare_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,WaveSquare_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
WaveSquare_Update: PROC
	ld l,(ix + WaveSquare.phase)
	ld h,(ix + WaveSquare.phase + 1)
	ld a,(hl)
	and a
	jp m,Low
	ld (ix + WaveSquare.value),127
	ret
Low:
	ld (ix + WaveSquare.value),0
	ret
	ENDP

;
WaveSquare_labels:
	db 250,251," Wave",0
	db "Value",0
	db "Phase",0
