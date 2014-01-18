;
; An fixed value
;
Value: MACRO
	super:
		Modulation Value_NoteOn, Value_NoteOff, Value_Update
	value:
		db 127
	size:
	ENDM

	dw Value.size
Value_class: Value

; ix <- new class
Value_New:
	ld iy,Value_class
	call Class_New
	ret

Value_NoteOn:
	ret

Value_NoteOff:
	ret

Value_Update:
	ld a,(ix + Value.value)
	ret
