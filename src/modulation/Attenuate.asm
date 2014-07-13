;
; Attenuate a value
;
Attenuate: MACRO
	value:
		Value 0
	multiplicand:
		dw Value_values.127
	multiplier:
		dw Value_values.127
	size:
	ENDM

	dw Attenuate.size
Attenuate_class: Attenuate

; ix <- new class
Attenuate_New:
	ld iy,Attenuate_class
	call Class_New
	call Attenuate_Constructor
	ret

; ix = this
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
