;
; A program
;
Program: MACRO
	channel:
		dw 0
	patch:
		dw 0
	size:
	ENDM

	dw Program.size
Program_class: Program

; hl = channel
; ix <- new object
Program_New:
	push hl
	ld iy,Program_class
	call Class_New
	pop hl
	jp Program_Constructor

; ix = this
; hl = channel
; ix <- this
Program_Constructor:
	ld (ix + Program.channel),l
	ld (ix + Program.channel + 1),h
	push hl
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
	pop ix
	ex (sp),ix
	call Channel_AddNotePool
	pop ix
	ret
