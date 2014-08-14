;
; A bipolar pulse waveform
;
WavePulseBipolar: MACRO
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
	labels: equ WavePulseBipolar_labels
	_size:
	ENDM

	dw WavePulseBipolar._size
WavePulseBipolar_class: WavePulseBipolar

; ix, de <- new object
WavePulseBipolar_New:
	ld iy,WavePulseBipolar_class
	call Class_New
	call WavePulseBipolar_Constructor
	ret

; ix = this
; ix, de <- this
WavePulseBipolar_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,WavePulseBipolar_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
WavePulseBipolar_Update: PROC
	ld l,(ix + WavePulseBipolar.phase)
	ld h,(ix + WavePulseBipolar.phase + 1)
	ld a,(hl)
	ld l,(ix + WavePulseBipolar.pulseWidth)
	ld h,(ix + WavePulseBipolar.pulseWidth + 1)
	cp (hl)
	jp nc,Low
	ld (ix + WavePulseBipolar.value),127
	ret
Low:
	ld (ix + WavePulseBipolar.value),-128
	ret
	ENDP

;
WavePulseBipolar_labels:
	db 240,243," Wave Bipolar",0
	db "Value",0
	db "Phase",0
	db "Width",0
