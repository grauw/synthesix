ControllerBank: MACRO
	outputs:
	controllers:
		Value 0  ; 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 100
		Value 0  ; 8
		Value 0
		Value 64
		Value 127
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 16
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 24
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 32
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 40
		Value 0
		Value 0
		Value 127
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 48
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 56
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 64
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 72
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 80
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 88
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 96
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 104
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0  ; 112
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
		Value 0
	outputsEnd:
	inputs:
	inputsEnd:
	labels: equ ControllerBank_labels
	_size:
	ENDM

	dw ControllerBank._size
ControllerBank_class: ControllerBank

; ix, de <- new object
ControllerBank_New:
	ld iy,ControllerBank_class
	call Class_New
	jp ControllerBank_Constructor

; ix = this
; ix, de <- this
ControllerBank_Constructor:
	ld e,ixl
	ld d,ixh
	ret

; de = this
; hl <- controller value address
ControllerBank_GetController:
	ld l,a
	ld h,0
	add hl,de
	ret

;
ControllerBank_labels:
	db "Controllers",0
	db "Bank C",0
	db "Mod",0
	db "Breath",0
	db "Undefined",0
	db "Foot",0
	db "P.Time",0
	db "Data C",0
	db "Volume",0
	db "Balance",0
	db "Undefined",0
	db "Pan",0
	db "Expression",0
	db "Fx 1",0
	db "Fx 2",0
