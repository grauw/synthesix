;
; A program
;
Program: MACRO
	patch:
		dw 0
	size:
	ENDM

	dw Program.size
Program_class: Program

; ix <- new class
Program_New:
	ld iy,Program_class
	call Class_New
	jp Program_Constructor

; ix = this
; ix <- this
Program_Constructor:
	push ix
	call Patch_New
	pop iy
	push iy
	ld e,ixl
	ld d,ixh
	ld (iy + Program.patch),e
	ld (iy + Program.patch + 1),d
	call Patch_GetNotePool
	push ix
	pop hl
	ld ix,Channel_channels.0
	call Channel_AddNotePool
	pop ix
	ret
