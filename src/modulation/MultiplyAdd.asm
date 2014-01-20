;
; A multiply-add
;
MultiplyAdd: MACRO
	super: Value 0
	multiplicand:
		dw Value_values.127
	multiplier:
		dw Value_values.127
	addend:
		dw Value_values.0
	size:
	ENDM

	dw MultiplyAdd.size
MultiplyAdd_class: MultiplyAdd

; ix <- new class
MultiplyAdd_New:
	ld iy,MultiplyAdd_class
	call Class_New
	call MultiplyAdd_Constructor
	ret

; ix = this
MultiplyAdd_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,MultiplyAdd_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
MultiplyAdd_Update: PROC
	ld l,(iy + MultiplyAdd.multiplicand)
	ld h,(iy + MultiplyAdd.multiplicand + 1)
	ld a,(hl)
	ld l,(iy + MultiplyAdd.multiplier)
	ld h,(iy + MultiplyAdd.multiplier + 1)
	ld l,(hl)
	call Math_Multiply127x127Signed
	ld l,(iy + MultiplyAdd.addend)
	ld h,(iy + MultiplyAdd.addend + 1)
	add a,(hl)
	ld (iy + MultiplyAdd.super.value),a
	ret po
	bit 7,(hl)
	ld (iy + MultiplyAdd.super.value),127
	ret z
	ld (iy + MultiplyAdd.super.value),128
	ret
	ENDP
