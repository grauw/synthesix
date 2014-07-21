;
; Display a program
;
UIProgram: MACRO
	super: UINode UIProgram_Update
	program:
		dw 0
	size:
	ENDM

	dw UIProgram.size
UIProgram_class: UIProgram

; ix = parent
; de = y / x coordinate
; hl = program
; ix <- instance
UIProgram_New:
	push ix
	push hl
	push de
	ld iy,UIProgram_class
	call Class_New
	pop de
	pop hl
	pop iy
	call UIProgram_Constructor
	ret

; ix = parent
; de = y / x coordinate
; hl = program
; de <- instance
UIProgram_New_DE:
	call UIProgram_New
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; hl = program
UIProgram_Constructor:
	ld (ix + UIProgram.program),l
	ld (ix + UIProgram.program + 1),h
	push hl
	call UINode_SetBuffer
	pop iy
	ret

; ix = this
UIProgram_Update:
	call UINode_GetBuffer

	ld e,(ix + UIProgram.program)
	ld d,(ix + UIProgram.program + 1)
	ld iyl,e
	ld iyh,d

	push hl
	push iy
	ld e,(iy + Program.channel)
	ld d,(iy + Program.channel + 1)
	ld iyl,e
	ld iyh,d
	ld de,0000H
	call UINode_GetRelativePosition
	call UIChannel_Paint
	pop iy
	pop hl

	push hl
	push iy
	ld e,(iy + Program.channel)
	ld d,(iy + Program.channel + 1)
	ld iyl,e
	ld iyh,d
	ld e,(iy + Channel.controllers)
	ld d,(iy + Channel.controllers + 1)
	ld iyl,e
	ld iyh,d
	ld de,0010H
	call UINode_GetRelativePosition
	call UIControllerBank_Paint
	pop iy
	pop hl

	push hl
	push iy
	ld e,(iy + Program.channel)
	ld d,(iy + Program.channel + 1)
	ld iyl,e
	ld iyh,d
	ld e,(iy + Channel.notePools)
	ld d,(iy + Channel.notePools + 1)
	ld iyl,e
	ld iyh,d
	ld e,(iy + NotePool.notes + KeyNotePair.note)
	ld d,(iy + NotePool.notes + KeyNotePair.note + 1)
	ld iyl,e
	ld iyh,d
	ld de,0020H
	call UINode_GetRelativePosition
	call UINote_Paint
	pop iy
	pop hl
	ret
