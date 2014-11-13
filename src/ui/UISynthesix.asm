;
;
;
UISynthesix: MACRO
	buffer:
		dw 0
	patchEditor:
		dw 0
	_size:
	ENDM

	dw UISynthesix._size
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
	push ix
	ld ix,(Synthesix_instance.program)
	ld e,(ix + Program.patch)
	ld d,(ix + Program.patch + 1)
	call PatchEditor_New
	pop ix
	ld (ix + UISynthesix.patchEditor),e
	ld (ix + UISynthesix.patchEditor + 1),d
	ld e,ixl
	ld d,ixh
	ret

UISynthesix_Update:
	push ix
	ld e,(ix + UISynthesix.patchEditor)
	ld d,(ix + UISynthesix.patchEditor + 1)
	ld ixl,e
	ld ixh,d
	call PatchEditor_Update
	pop ix

	push ix
	ld e,(ix + UISynthesix.buffer)
	ld d,(ix + UISynthesix.buffer + 1)
	ld iyl,e
	ld iyh,d
	call UIBuffer_ClearBlinkBuffer
	call UIBuffer_GetBuffer
	push iy
	call UISynthesix_Paint
	pop iy
	call UIBuffer_Draw
	pop ix
	ret

; ix = this
; iy = buffer
; hl = buffer address
UISynthesix_Paint:
	push hl
	ex de,hl
	ld hl,UISynthesix_template
	ld bc,0150H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,004CH
	add hl,de
	ld de,(Synthesix_instance.lastSpeedMeasurement)
	call UIBuffer_PrintHexDE
	pop hl

	push hl
	ld de,0030H
	call UIBuffer_GetRelativePosition
	call UISynthesix_PaintLiveIndicator
	pop hl

	push hl
	ld e,(ix + UISynthesix.patchEditor)
	ld d,(ix + UISynthesix.patchEditor + 1)
	ld ixl,e
	ld ixh,d
	ld de,0100H
	call UIBuffer_GetRelativePosition
	call PatchEditorView_Paint
	pop hl

	push hl
	ld ix,Channel_channels.0
	ld de,1900H
	call UIBuffer_GetRelativePosition
	call UIKeyboard_Paint
	pop hl

	push hl
	ld de,1200H
	call UIBuffer_GetRelativePosition
	ld a,0
	ld ix,(Synthesix_instance.scc)
	call SCC_GetVoice
	ld a,0
	ld ix,ModuleType_sccVoice
	call ModuleView_Paint
	pop hl

	push hl
	ld de,1210H
	call UIBuffer_GetRelativePosition
	ld a,1
	ld ix,(Synthesix_instance.scc)
	call SCC_GetVoice
	ld a,0
	ld ix,ModuleType_sccVoice
	call ModuleView_Paint
	pop hl

	push hl
	ld de,1220H
	call UIBuffer_GetRelativePosition
	ld a,2
	ld ix,(Synthesix_instance.scc)
	call SCC_GetVoice
	ld a,0
	ld ix,ModuleType_sccVoice
	call ModuleView_Paint
	pop hl

	push hl
	ld de,1230H
	call UIBuffer_GetRelativePosition
	ld a,3
	ld ix,(Synthesix_instance.scc)
	call SCC_GetVoice
	ld a,0
	ld ix,ModuleType_sccVoice
	call ModuleView_Paint
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
	ds 31,23
	db " S y n t h e s i x "
	ds 25,23
	db " ----"
