ControllerBank: MACRO
	outputs:
	controllers: REPT 120
		Value 0
		ENDM
	outputsEnd:
	inputs:
	inputsEnd:
	labels: equ ControllerBank_labels
	_size:
	ENDM

; ix, de <- new object
ControllerBank_New:
	push ix
	xor a
	ld bc,128
	ld ix,Heap_heap
	call Heap_AllocateClear
	pop ix
	ld ixl,e
	ld ixh,d
	jp ControllerBank_Constructor

; ix = this
; ix, de <- this
ControllerBank_Constructor:
	ld e,ixl
	ld d,ixh
	ret

; hl = this
; hl <- controller value address
ControllerBank_GetController:
	ld e,a
	ld d,0
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
