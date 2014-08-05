;
; A logical or
;
; A value between 0 and 63 is considered false. Short-circuits.
;
Or: MACRO
	outputs:
	value:
		Value 0
	outputsEnd:
	inputs:
	term1:
		dw Value_values.0
	term2:
		dw Value_values.0
	inputsEnd:
	_size:
	ENDM

	dw Or._size
Or_class: Or

; ix, de <- new object
Or_New:
	ld iy,Or_class
	call Class_New
	call Or_Constructor
	ret

; ix = this
; ix, de <- this
Or_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60Hz
	ld hl,Or_Update
	call Clock_AddListener
	pop ix
	ret

; ix = this
Or_Update: PROC
	ld l,(ix + Or.term1)
	ld h,(ix + Or.term1 + 1)
	ld a,(hl)
	cp 40H
	jr nc,Set
	ld l,(ix + Or.term2)
	ld h,(ix + Or.term2 + 1)
	ld a,(hl)
Set:
	ld (ix + Or.value),a
	ret
	ENDP
