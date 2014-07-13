;
; Display a virtual keyboard
;
UIKeyboard: MACRO
	super: UINode UIKeyboard_Update
	channel:
		dw 0
	pitchBend:
		dw 0
	size:
	ENDM

	dw UIKeyboard.size
UIKeyboard_class: UIKeyboard

; ix = parent
; de = x / y coordinate
; hl = channel
; ix <- instance
UIKeyboard_New:
	push ix
	push hl
	push de
	ld iy,UIKeyboard_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIKeyboard_Constructor
	ret

; ix = parent
; de = x / y coordinate
; hl = channel
; de <- instance
UIKeyboard_New_DE:
	call UIKeyboard_New
	push iy
	ex (sp),ix
	pop de
	ret

; ix = this
; hl = channel
UIKeyboard_Constructor:
	ld (ix + UIKeyboard.channel),l
	ld (ix + UIKeyboard.channel + 1),h
	push hl
	call UINode_SetBuffer
	pop hl

	push hl
	ld hl,UIKeyboard_background
	ld de,0000H
	ld bc,5002H
	call UINode_CopyToBuffer
	pop hl

	push ix
	push hl
	ld bc,Channel.pitchBendCoarse
	add hl,bc
	ld de,0100H
	call UIValue_New_DE
	pop hl
	pop ix
	ld (ix + UIKeyboard.pitchBend),e
	ld (ix + UIKeyboard.pitchBend + 1),d
	ret

UIKeyboard_Update:
	ld e,(ix + UIKeyboard.pitchBend)
	ld d,(ix + UIKeyboard.pitchBend + 1)
	call UINode_Update_DE
	ret

;
UIKeyboard_background:
	db "Bend ",10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14
	db 10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,12,12,14,10,12,14,10,14
	db "     ",8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
