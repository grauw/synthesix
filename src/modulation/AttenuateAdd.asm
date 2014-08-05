;
; Attenuate and add a value
;
AttenuateAdd: MACRO
	value:
		Value 0
	multiplicand:
		dw Value_values.127
	multiplier:
		dw Value_values.127
	addend:
		dw Value_values.0
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
	ld ix,Clock_60Hz
	ld hl,AttenuateAdd_Update
	call Clock_AddListener
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
