;
; Show focus highlight on the current focused element
;
UIFocus: MACRO
	target:
		dw 0
	_size:
	ENDM

; ix = this
UIFocus_Constructor:
	ret

; bc = value reference
; iy = buffer
; hl = buffer address
; Modifies: af, de
UIFocus_Paint: PROC
	ld a,(UIFocus_instance.target)
	cp c
	ret nz
	ld a,(UIFocus_instance.target + 1)
	cp b
	ret nz
	push iy
	ex (sp),ix
	push bc
	push hl
	ld b,4
Loop:
	push hl
	call UIBuffer_SetBlinkBit
	pop hl
	inc hl
	djnz Loop
	pop hl
	pop bc
	pop ix
	ret
	ENDP

;
	SECTION RAM

UIFocus_instance: UIFocus

	ENDS
