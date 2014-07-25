;
; A fixed value
;
Value: MACRO ?value
	value:
		db ?value
	size:
	ENDM

	dw Value.size
Value_class: Value 0

; ix <- new object
Value_New:
	ld iy,Value_class
	call Class_New
	ret

;
Value_values: REPT 256, ?value
	Value ?value
	ENDM
