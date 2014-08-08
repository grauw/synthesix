;
; Display a program
;
; ix = program
; iy = buffer
; hl = buffer address
ProgramView_Paint:
	push hl
	push ix
	ld e,(ix + Program.channel)
	ld d,(ix + Program.channel + 1)
	ld ixl,e
	ld ixh,d
	ld de,0000H
	call UIBuffer_GetRelativePosition
	call ChannelView_Paint
	pop ix
	pop hl

	push hl
	push ix
	ld e,(ix + Program.channel)
	ld d,(ix + Program.channel + 1)
	ld ixl,e
	ld ixh,d
	ld e,(ix + Channel.controllers)
	ld d,(ix + Channel.controllers + 1)
	ld ixl,e
	ld ixh,d
	ld de,0010H
	call UIBuffer_GetRelativePosition
	call ControllerBankView_Paint
	pop ix
	pop hl

	push hl
	push ix
	ld e,(ix + Program.channel)
	ld d,(ix + Program.channel + 1)
	ld ixl,e
	ld ixh,d
	ld e,(ix + Channel.notePools)
	ld d,(ix + Channel.notePools + 1)
	ld ixl,e
	ld ixh,d
	ld e,(ix + NotePool.notes + KeyNotePair.note)
	ld d,(ix + NotePool.notes + KeyNotePair.note + 1)
	ld ixl,e
	ld ixh,d
	ld de,0020H
	call UIBuffer_GetRelativePosition
	call NoteView_Paint
	pop ix
	pop hl
	ret
