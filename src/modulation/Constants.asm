;
; A constant value
;
Constants: MACRO
	outputs:
		REPT 256, ?value
		Value ?value
		ENDM
	outputsEnd:
	inputs:
	inputsEnd:
	_size:
	ENDM

;
Constants_instance: Constants
