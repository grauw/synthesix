;
; An fixed value
;
Value: MACRO
	super: Modulation Value_NoteOn, Value_NoteOff
	size:
	ENDM

	dw Value.size
Value_class: Value

; ix <- new class
Value_New:
	ld iy,Value_class
	call Class_New
	ld (ix + Value.super.value),0
	ret

Value_NoteOn:
	ret

Value_NoteOff:
	ret
