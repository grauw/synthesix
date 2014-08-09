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

; de = value reference
; iy = buffer
; hl = buffer address
; Modifies: af, bc, de
UIFocus_Paint: PROC
	ld a,(UIFocus_instance.target)
	cp e
	ret nz
	ld a,(UIFocus_instance.target + 1)
	cp d
	ret nz
	push de
	push hl
	ld b,4
Loop:
	push hl
	call UIBuffer_SetBlinkBit
	pop hl
	inc hl
	djnz Loop
	pop hl
	pop de
	ret
	ENDP

;
	SECTION RAM

UIFocus_instance: UIFocus

	ENDS
