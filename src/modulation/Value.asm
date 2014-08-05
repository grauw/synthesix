;
; A value
;
Value: MACRO ?value
	outputs:
	value:
		db ?value
	outputsEnd:
	inputs:
	inputsEnd:
	_size:
	ENDM

	dw Value._size
Value_class: Value 0

; ix <- new object
Value_New:
	ld iy,Value_class
	call Class_New
	ret
