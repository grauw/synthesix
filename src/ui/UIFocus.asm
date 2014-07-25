;
; Show focus highlight on the current focused element
;
UIFocus: MACRO
	target:
		dw Channel_channels.0 + Channel.program
	size:
	ENDM

; ix = this
UIFocus_Constructor:
	ret

; ix = buffer
; bc = value reference
; hl = buffer address
; Modifies: af, de
UIFocus_Paint: PROC
	ld a,(UIFocus_instance.target)
	cp c
	ret nz
	ld a,(UIFocus_instance.target + 1)
	cp b
	ret nz
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
	ret
	ENDP

;
UIFocus_instance: UIFocus
