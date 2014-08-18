;
; A bipolar triangle waveform
;
WaveTriangleBipolar: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	phaseFine:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveTriangleBipolar_labels
	_size:
	ENDM

	dw WaveTriangleBipolar._size
WaveTriangleBipolar_class: WaveTriangleBipolar

; ix, de <- new object
WaveTriangleBipolar_New:
	ld iy,WaveTriangleBipolar_class
	call Class_New
	call WaveTriangleBipolar_Constructor
	ret

; ix = this
; ix, de <- this
WaveTriangleBipolar_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,WaveTriangleBipolar_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
WaveTriangleBipolar_Update: PROC
	ld l,(ix + WaveTriangleBipolar.phaseFine)
	ld h,(ix + WaveTriangleBipolar.phaseFine + 1)
	ld a,(hl)
	rla
	ld l,(ix + WaveTriangleBipolar.phase)
	ld h,(ix + WaveTriangleBipolar.phase + 1)
	ld a,(hl)
	adc a,a
	jr c,Negative
	jp p,PositiveUp
	cpl
PositiveUp:
	ld (ix + WaveTriangleBipolar.value),a
	ret
Negative:
	jp m,NegativeUp
	cpl
NegativeUp:
	ld (ix + WaveTriangleBipolar.value),a
	ret
	ENDP

;
WaveTriangleBipolar_labels:
	db 246,247," Wave Bipolar",0
	db "Value",0
	db "Phase",0
	db "Phase Fine",0
