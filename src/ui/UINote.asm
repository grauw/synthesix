;
; Display a virtual keyboard
;
UINote: MACRO
	super: UINode UINote_Update
	note:
		dw 0
	key:
		dw 0
	velocity:
		dw 0
	trigger:
		dw 0
	gate:
		dw 0
	size:
	ENDM

	dw UINote.size
UINote_class: UINote

; ix = parent
; de = x / y coordinate
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
; de = x / y coordinate
; hl = note
; de <- instance
UINote_New_DE:
	call UINote_New
	push iy
	ex (sp),ix
	pop de
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
	ld bc,1006H
	call UINode_CopyToBuffer
	pop hl

	push hl
	push ix
	ld bc,Note.key
	add hl,bc
	ld de,010AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UINote.key),e
	ld (ix + UINote.key + 1),d

	push hl
	push ix
	ld bc,Note.velocity
	add hl,bc
	ld de,020AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UINote.velocity),e
	ld (ix + UINote.velocity + 1),d

	push hl
	push ix
	ld bc,Note.trigger
	add hl,bc
	ld de,030AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UINote.trigger),e
	ld (ix + UINote.trigger + 1),d

	push hl
	push ix
	ld bc,Note.gate
	add hl,bc
	ld de,040AH
	call UIValue_New_DE
	pop ix
	pop hl
	ld (ix + UINote.gate),e
	ld (ix + UINote.gate + 1),d
	ret

; ix = this
UINote_Update:
	ld e,(ix + UINote.key)
	ld d,(ix + UINote.key + 1)
	call UINode_Update_DE

	ld e,(ix + UINote.velocity)
	ld d,(ix + UINote.velocity + 1)
	call UINode_Update_DE

	ld e,(ix + UINote.trigger)
	ld d,(ix + UINote.trigger + 1)
	call UINode_Update_DE

	ld e,(ix + UINote.gate)
	ld d,(ix + UINote.gate + 1)
	call UINode_Update_DE
	ret

;
UINote_background:
	db 24,23,23,23,23," Note ",23,23,23,23,25
	db 22," Key     0000 ",22
	db 22," Velocit 0000 ",22
	db 22," Trigger 0000 ",22
	db 22," Gate    0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
