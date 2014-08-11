;
; Attenuate a value
;
Attenuate: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	multiplicand:
		dw Constants_instance + 127
	multiplier:
		dw Constants_instance + 127
	inputsEnd:
	labels: equ Attenuate_labels
	_size:
	ENDM

	dw Attenuate._size
Attenuate_class: Attenuate

; ix, de <- new object
Attenuate_New:
	ld iy,Attenuate_class
	call Class_New
	call Attenuate_Constructor
	ret

; ix = this
; ix, de <- this
Attenuate_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,Attenuate_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
Attenuate_Update: PROC
	ld l,(ix + Attenuate.multiplicand)
	ld h,(ix + Attenuate.multiplicand + 1)
	ld a,(hl)
	ld l,(ix + Attenuate.multiplier)
	ld h,(ix + Attenuate.multiplier + 1)
	ld l,(hl)
	call Math_Multiply127x127Signed
	ld (ix + Attenuate.value),a
	ret
	ENDP

;
Attenuate_labels:
	db "Attenuate",0
	db "Value",0
	db "Multiplicand",0
	db "Multiplier",0
