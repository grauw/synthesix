;
; A multiply
;
Multiply: MACRO
	super: Value 0
	multiplicand:
		dw Value_values.127
	multiplier:
		dw Value_values.127
	size:
	ENDM

	dw Multiply.size
Multiply_class: Multiply

; ix <- new class
Multiply_New:
	ld iy,Multiply_class
	call Class_New
	call Multiply_Constructor
	ret

; ix = this
Multiply_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,Multiply_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
Multiply_Update: PROC
	ld l,(ix + Multiply.multiplicand)
	ld h,(ix + Multiply.multiplicand + 1)
	ld a,(hl)
	ld l,(ix + Multiply.multiplier)
	ld h,(ix + Multiply.multiplier + 1)
	ld l,(hl)
	call Math_Multiply127x127Signed
	ld (ix + Multiply.super.value),a
	ret
	ENDP
