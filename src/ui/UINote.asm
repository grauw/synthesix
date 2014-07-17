;
; Display a virtual keyboard
;
UINote: MACRO
	super: UINode UINote_Update
	note:
		dw 0
	size:
	ENDM

	dw UINote.size
UINote_class: UINote

; ix = parent
; de = y / x coordinate
; hl = note
; ix <- instance
UINote_New:
	push ix
	push hl
	push de
	ld iy,UINote_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UINote_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = note
; de <- instance
UINote_New_DE:
	call UINote_New
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; hl = note
UINote_Constructor:
	ld (ix + UINote.note),l
	ld (ix + UINote.note + 1),h
	push hl
	call UINode_SetBuffer
	pop hl

	push hl
	ld hl,UINote_background
	ld de,0000H
	ld bc,0610H
	call UINode_CopyToBuffer
	pop hl
	ret

; ix = this
UINote_Update:
	ld e,(ix + UINote.note)
	ld d,(ix + UINote.note + 1)
	ld iyl,e
	ld iyh,d

	ld de,010AH
	call UINode_GetBufferPosition
	ld a,(iy + Note.key)
	call UIValue_Paint

	ld de,020AH
	call UINode_GetBufferPosition
	ld a,(iy + Note.velocity)
	call UIValue_Paint

	ld de,030AH
	call UINode_GetBufferPosition
	ld a,(iy + Note.trigger)
	call UIValue_Paint

	ld de,040AH
	call UINode_GetBufferPosition
	ld a,(iy + Note.gate)
	call UIValue_Paint
	ret

;
UINote_background:
	db 24,23,23,23,23," Note ",23,23,23,23,25
	db 22," Key     0000 ",28
	db 22," Velocit 0000 ",28
	db 22," Trigger 0000 ",28
	db 22," Gate    0000 ",28
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
