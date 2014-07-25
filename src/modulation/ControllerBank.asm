ControllerBank: MACRO
	controllers: REPT 128
		Value 0
		ENDM
	size:
	ENDM

	dw ControllerBank.size
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

; hl = this
; hl <- controller value address
ControllerBank_GetController:
	ld e,a
	ld d,0
	add hl,de
	ret
