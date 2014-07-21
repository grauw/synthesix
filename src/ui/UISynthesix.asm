;
;
;
UISynthesix: MACRO
	super: UINode UISynthesix_Update
	title:
		dw 0
	program:
		dw 0
	keyboard:
		dw 0
	size:
	ENDM

	dw UISynthesix.size
UISynthesix_class: UISynthesix

; ix = this
UISynthesix_Constructor:
	ld bc,UISynthesix_template_size
	push ix
	ld ix,Heap_heap
	call Heap_Allocate
	pop ix
	ld (ix + UISynthesix.super.buffer),e
	ld (ix + UISynthesix.super.buffer + 1),d
	ld hl,UISynthesix_template
	ldir

	push ix
	ld de,001EH
	ld hl,UISynthesix_titleText
	call UIText_New_DE
	pop ix
	ld (ix + UISynthesix.title),e
	ld (ix + UISynthesix.title + 1),d

	push ix
	ld hl,(Synthesix_program)
	ld de,0100H
	call UIProgram_New_DE
	pop ix
	ld (ix + UISynthesix.program),e
	ld (ix + UISynthesix.program + 1),d

	push ix
	ld hl,Channel_channels.0
	ld de,1900H
	call UIKeyboard_New_DE
	pop ix
	ld (ix + UISynthesix.keyboard),e
	ld (ix + UISynthesix.keyboard + 1),d
	ret

UISynthesix_Update:
	call UISynthesix_UpdateLiveIndicator

	ld e,(ix + UISynthesix.program)
	ld d,(ix + UISynthesix.program + 1)
	call UINode_Update_DE

	ld e,(ix + UISynthesix.keyboard)
	ld d,(ix + UISynthesix.keyboard + 1)
	call UINode_Update_DE

	call UINode_GetBuffer

	push hl
	ld a,0
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1300H
	call UINode_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	push hl
	ld a,1
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1310H
	call UINode_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	push hl
	ld a,2
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1320H
	call UINode_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	push hl
	ld a,3
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1330H
	call UINode_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	call UISynthesix_Draw
	ret

UISynthesix_UpdateLiveIndicator:
	ld de,002FH
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
	ds 80,23
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
	db "                                                                                "
UISynthesix_template_size: equ $ - UISynthesix_template
