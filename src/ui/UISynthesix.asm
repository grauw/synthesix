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

; ix, de <- new object
UISynthesix_New:
	ld iy,UISynthesix_class
	call Class_New
	jp UISynthesix_Constructor

; ix = this
; ix, de <- this
UISynthesix_Constructor:
	push ix
	call UIBuffer_New
	pop ix
	ld (ix + UISynthesix.buffer),e
	ld (ix + UISynthesix.buffer + 1),d
	ld e,ixl
	ld d,ixh
	ret

UISynthesix_Update:
	push ix
	ld e,(ix + UISynthesix.buffer)
	ld d,(ix + UISynthesix.buffer + 1)
	ld ixl,e
	ld ixh,d
	call UIBuffer_GetBuffer
	call UISynthesix_Paint
	call UIBuffer_Draw
	pop ix
	ret

; hl = buffer
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
	ret

UISynthesix_PaintLiveIndicator:
	ld a,(JIFFY)
	bit 5,a
	ld (hl),'x'
	ret z
	ld (hl),'X'
	ret

;
UISynthesix_template:
	ds 30,23
	db " S y n t h e s i x "
	ds 29,23
