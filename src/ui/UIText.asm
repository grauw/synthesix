;
; A simple text label
;
UIText: MACRO
	super:
		UINode UIText_Update
	size:
	ENDM

	dw UIText.size
UIText_class: UIText

; ix = parent
; de = y / x coordinate
; hl = text (ASCIIZ)
; ix <- instance
UIText_New:
	push ix
	push hl
	push de
	ld iy,UIText_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIText_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = text (ASCIIZ)
; de <- instance
UIText_New_DE:
	call UIText_New
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; iy = parent
; de = y / x coordinate
; hl = text (ASCIIZ)
UIText_Constructor: PROC
	push hl
	call UINode_SetBuffer
	ex de,hl
	pop hl
Loop:
	ldi
	ld a,(hl)
	and a
	jp nz,Loop
	ret
	ENDP

UIText_Update:
	ret
