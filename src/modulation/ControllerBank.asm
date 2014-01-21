ControllerBank: MACRO
	controllers: REPT 128
		Value 0
		ENDM
	size:
	ENDM

	dw ControllerBank.size
ControllerBank_class: ControllerBank

ControllerBank_New:
	ld iy,ControllerBank_class
	call Class_New
	ret

; hl = this
; hl <- controller value address
ControllerBank_GetController:
	add a,a
	ld e,a
	ld d,0
	add hl,de
	ret
