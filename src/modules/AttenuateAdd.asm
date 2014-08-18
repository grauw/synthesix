;
; Attenuate and add a value
;
AttenuateAdd: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	multiplicand:
		dw Constants_instance + 127
	multiplier:
		dw Constants_instance + 127
	addend:
		dw Constants_instance + 0
	inputsEnd:
	labels: equ AttenuateAdd_labels
	_size:
	ENDM

	dw AttenuateAdd._size
AttenuateAdd_class: AttenuateAdd

; ix, de <- new object
AttenuateAdd_New:
	ld iy,AttenuateAdd_class
	call Class_New
	call AttenuateAdd_Constructor
	ret

; ix = this
; ix, de <- this
AttenuateAdd_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,AttenuateAdd_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
AttenuateAdd_Update: PROC
	ld l,(ix + AttenuateAdd.multiplicand)
	ld h,(ix + AttenuateAdd.multiplicand + 1)
	ld a,(hl)
	ld l,(ix + AttenuateAdd.multiplier)
	ld h,(ix + AttenuateAdd.multiplier + 1)
	ld l,(hl)
	call Math_Multiply127x127Signed
	ld l,(ix + AttenuateAdd.addend)
	ld h,(ix + AttenuateAdd.addend + 1)
	add a,(hl)
	ld (ix + AttenuateAdd.value),a
	ret po
	bit 7,(hl)
	ld (ix + AttenuateAdd.value),127
	ret z
	ld (ix + AttenuateAdd.value),128
	ret
	ENDP

;
AttenuateAdd_labels:
	db "Attenu-add",0
	db "Value",0
	db "Multiplicand",0
	db "Multiplier",0
	db "Addend",0
