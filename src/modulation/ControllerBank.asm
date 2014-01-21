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

; de = this
; hl <- controller value address
ControllerBank_GetController:
	add a,a
	ld l,a
	ld h,0
	add hl,de
	ex de,hl
	ret
