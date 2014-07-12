;
;
;
UISynthesix: MACRO
	super: UINode UISynthesix_Update
	title:
		dw 0
	voice1:
		dw 0
	voice2:
		dw 0
	voice3:
		dw 0
	voice4:
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

	ld de,001EH
	ld hl,UISynthesix_titleText
	call UIText_New_DE
	ld (ix + UISynthesix.title),e
	ld (ix + UISynthesix.title + 1),d

	ld de,1300H
	ld hl,(SCC_voices)
	push ix
	call UISCCVoice_New_DE
	pop ix
	ld (ix + UISynthesix.voice1),e
	ld (ix + UISynthesix.voice1 + 1),d

	ld de,1310H
	ld hl,(SCC_voices + 2)
	push ix
	call UISCCVoice_New_DE
	pop ix
	ld (ix + UISynthesix.voice2),e
	ld (ix + UISynthesix.voice2 + 1),d

	ld de,1320H
	ld hl,(SCC_voices + 4)
	push ix
	call UISCCVoice_New_DE
	pop ix
	ld (ix + UISynthesix.voice3),e
	ld (ix + UISynthesix.voice3 + 1),d

	ld de,1330H
	ld hl,(SCC_voices + 6)
	push ix
	call UISCCVoice_New_DE
	pop ix
	ld (ix + UISynthesix.voice4),e
	ld (ix + UISynthesix.voice4 + 1),d
	ret

UISynthesix_Update:
	call UISynthesix_UpdateLiveIndicator

	ld e,(ix + UISynthesix.voice1)
	ld d,(ix + UISynthesix.voice1 + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix

	ld e,(ix + UISynthesix.voice2)
	ld d,(ix + UISynthesix.voice2 + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix

	ld e,(ix + UISynthesix.voice3)
	ld d,(ix + UISynthesix.voice3 + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix

	ld e,(ix + UISynthesix.voice4)
	ld d,(ix + UISynthesix.voice4 + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call UINode_Update
	pop ix

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
	db " ",10,11,12,10,11,11,12,10,11,12,10,11,11,12,10,11,12,10,11,11,12,10,11,12,10,11,11,12,10,11,12,10,11,11,12,10,11,12,10
	db 11,11,12,10,11,12,10,11,11,12,10,11,12,10,11,11,12,10,11,12,10,11,11,12,10,11,12,10,11,11,12,10,11,12,10,11,11,12,13," "
	db " ",8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8," "
UISynthesix_template_size: equ $ - UISynthesix_template
