;
; A bipolar sawtooth waveform
;
WaveSawBipolar: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveSawBipolar_labels
	_size:
	ENDM

	dw WaveSawBipolar._size
WaveSawBipolar_class: WaveSawBipolar

; ix, de <- new object
WaveSawBipolar_New:
	ld iy,WaveSawBipolar_class
	call Class_New
	call WaveSawBipolar_Constructor
	ret

; ix = this
; ix, de <- this
WaveSawBipolar_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,WaveSawBipolar_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
WaveSawBipolar_Update: PROC
	ld l,(ix + WaveSawBipolar.phase)
	ld h,(ix + WaveSawBipolar.phase + 1)
	ld a,(hl)
	ld (ix + WaveSawBipolar.value),a
	ret
	ENDP

;
WaveSawBipolar_labels:
	db 244,245," Wave bipolar",0
	db "Value",0
	db "Phase",0
