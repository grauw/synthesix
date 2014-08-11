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
	labels: equ Constants_labels
	_size:
	ENDM

;
Constants_instance: Constants

;
Constants_labels:
	db "Constants",0
	db "0",0
	db "1",0
	db "2",0
	db "3",0
	db "4",0
	db "5",0
	db "6",0
	db "7",0
	db "8",0
	db "9",0
	db "10",0
	db "11",0
	db "12",0
	db "13",0
