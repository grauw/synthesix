;
; A pulse waveform
;
WavePulse: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	pulseWidth:
		dw Constants_instance + 64
	inputsEnd:
	labels: equ WavePulse_labels
	_size:
	ENDM

	dw WavePulse._size
WavePulse_class: WavePulse

; ix, de <- new object
WavePulse_New:
	ld iy,WavePulse_class
	call Class_New
	call WavePulse_Constructor
	ret

; ix = this
; ix, de <- this
WavePulse_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,WavePulse_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
WavePulse_Update: PROC
	ld l,(ix + WavePulse.phase)
	ld h,(ix + WavePulse.phase + 1)
	ld a,(hl)
	ld l,(ix + WavePulse.pulseWidth)
	ld h,(ix + WavePulse.pulseWidth + 1)
	cp (hl)
	jp nc,Low
	ld (ix + WavePulse.value),127
	ret
Low:
	ld (ix + WavePulse.value),0
	ret
	ENDP

;
WavePulse_labels:
	db 241,251," Wave",0
	db "Value",0
	db "Phase",0
	db "Width",0
