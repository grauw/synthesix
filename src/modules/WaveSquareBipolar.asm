;
; A bipolar square waveform
;
WaveSquareBipolar: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	phase:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ WaveSquareBipolar_labels
	_size:
	ENDM

	dw WaveSquareBipolar._size
WaveSquareBipolar_class: WaveSquareBipolar

; ix, de <- new object
WaveSquareBipolar_New:
	ld iy,WaveSquareBipolar_class
	call Class_New
	call WaveSquareBipolar_Constructor
	ret

; ix = this
; ix, de <- this
WaveSquareBipolar_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,WaveSquareBipolar_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
WaveSquareBipolar_Update: PROC
	ld l,(ix + WaveSquareBipolar.phase)
	ld h,(ix + WaveSquareBipolar.phase + 1)
	ld a,(hl)
	and a
	jp m,Low
	ld (ix + WaveSquareBipolar.value),127
	ret
Low:
	ld (ix + WaveSquareBipolar.value),-128
	ret
	ENDP

;
WaveSquareBipolar_labels:
	db 242,243," Wave Bipolar",0
	db "Value",0
	db "Phase",0
