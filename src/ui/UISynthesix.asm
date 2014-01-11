;
;
;
UISynthesix: MACRO
	super: UINode UISynthesix_Update
	title:
		dw 0
	size:
	ENDM

	dw UISynthesix.size
UISynthesix_class: UISynthesix

; ix = this
UISynthesix_Constructor:
	ld bc,UISynthesix_template_size
	call Heap_Allocate
	ld (ix + UISynthesix.super.buffer),e
	ld (ix + UISynthesix.super.buffer + 1),d
	ld hl,UISynthesix_template
	ldir

	ld bc,001EH
	ld hl,UISynthesix_titleText
	call UIText_New_DE
	ld (ix + UISynthesix.title),e
	ld (ix + UISynthesix.title + 1),d
	ret

UISynthesix_Update:
	call UISynthesix_UpdateLiveIndicator
	call UISynthesix_Draw
	ret

UISynthesix_UpdateLiveIndicator:
	ld bc,002FH
	call UINode_GetBufferPosition
	ld a,(JIFFY)
	bit 5,a
	ld (hl),'x'
	ret z
	ld (hl),'X'
	ret

UISynthesix_Draw:
	ld a,0
	ld hl,0
	call VDP_SetWriteAddress
	ld l,(ix + UISynthesix.super.buffer)
	ld h,(ix + UISynthesix.super.buffer + 1)
	ld bc,UISynthesix_template_size
	call VDP_Write
	ret

;
UISynthesix_titleText:
	db " S y n t h e s i x ",0

UISynthesix_template:
	db 24,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
	db 23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,25
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 20,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
	db 23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,19
	db 22,"                                                                              ",22
	db 22,"                                                                              ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23
	db 23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
UISynthesix_template_size: equ $ - UISynthesix_template
