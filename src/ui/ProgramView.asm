;
; Display a program
;
; ix = program
; iy = buffer
; hl = buffer address
ProgramView_Paint:
	ld e,(ix + Program.patch)
	ld d,(ix + Program.patch + 1)
	ld ixl,e
	ld ixh,d
	ld de,0000H
	call UIBuffer_GetRelativePosition
	call PatchView_Paint
	ret
