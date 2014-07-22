;
; Display a program
;
; iy = program
; hl = buffer
UIProgram_Paint:
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
