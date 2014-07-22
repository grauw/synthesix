;
;
;
UISynthesix: MACRO
	buffer:
		dw 0
	size:
	ENDM

	dw UISynthesix.size
UISynthesix_class: UISynthesix

; ix = this
UISynthesix_Constructor:
	ld bc,27 * 80
	push ix
	ld ix,Heap_heap
	call Heap_Allocate
	pop ix
	ld (ix + UISynthesix.buffer),e
	ld (ix + UISynthesix.buffer + 1),d
	ld l,e
	ld h,d
	ld (hl)," "
	inc hl
	dec bc
	ldir
	ret

UISynthesix_Update:
	ld l,(ix + UISynthesix.buffer)
	ld h,(ix + UISynthesix.buffer + 1)
	call UISynthesix_Paint
	ret

UISynthesix_Paint:
	push hl
	ex de,hl
	ld hl,UISynthesix_template
	ld bc,0150H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,002FH
	call UIBuffer_GetRelativePosition
	call UISynthesix_PaintLiveIndicator
	pop hl

	push hl
	ld iy,(Synthesix_program)
	ld de,0100H
	call UIBuffer_GetRelativePosition
	call UIProgram_Paint
	pop hl

	push hl
	ld iy,Channel_channels.0
	ld de,1900H
	call UIBuffer_GetRelativePosition
	call UIKeyboard_Paint
	pop hl

	push hl
	ld a,0
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1300H
	call UIBuffer_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	push hl
	ld a,1
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1310H
	call UIBuffer_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	push hl
	ld a,2
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1320H
	call UIBuffer_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	push hl
	ld a,3
	ld iy,(Synthesix_scc)
	call SCC_GetVoice_IY
	ld de,1330H
	call UIBuffer_GetRelativePosition
	call UISCCVoice_Paint
	pop hl

	call UISynthesix_Draw
	ret

UISynthesix_PaintLiveIndicator:
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
	ld l,(ix + UISynthesix.buffer)
	ld h,(ix + UISynthesix.buffer + 1)
	ld bc,27 * 80
	call VDP_Write
	ret

;
UISynthesix_template:
	ds 30,23
	db " S y n t h e s i x "
	ds 29,23
