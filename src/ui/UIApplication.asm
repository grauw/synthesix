;
;
;
UIApplication: MACRO
	buffer:
		dw 0
	patchEditor:
		dw 0
	_size:
	ENDM

	dw UIApplication._size
UIApplication_class: UIApplication

; ix, de <- new object
UIApplication_New:
	ld iy,UIApplication_class
	call Class_New
	jp UIApplication_Constructor

; ix = this
; ix, de <- this
UIApplication_Constructor:
	push ix
	call UIBuffer_New
	pop ix
	ld (ix + UIApplication.buffer),e
	ld (ix + UIApplication.buffer + 1),d
	push ix
	ld ix,(Application_instance.program)
	ld e,(ix + Program.patch)
	ld d,(ix + Program.patch + 1)
	call PatchEditor_New
	pop ix
	ld (ix + UIApplication.patchEditor),e
	ld (ix + UIApplication.patchEditor + 1),d
	ld e,ixl
	ld d,ixh
	ret

UIApplication_Update:
	push ix
	ld e,(ix + UIApplication.patchEditor)
	ld d,(ix + UIApplication.patchEditor + 1)
	ld ixl,e
	ld ixh,d
	call PatchEditor_Update
	pop ix

	push ix
	ld e,(ix + UIApplication.buffer)
	ld d,(ix + UIApplication.buffer + 1)
	ld iyl,e
	ld iyh,d
	call UIBuffer_ClearBlinkBuffer
	call UIBuffer_GetBuffer
	push iy
	call UIApplication_Paint
	pop iy
	call UIBuffer_Draw
	pop ix
	ret

; ix = this
; iy = buffer
; hl = buffer address
UIApplication_Paint:
	push hl
	ex de,hl
	ld hl,UIApplication_template
	ld bc,0150H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,004CH
	add hl,de
	ld de,(Application_instance.lastSpeedMeasurement)
	call UIBuffer_PrintHexDE
	pop hl

	push hl
	push ix
	ld e,(ix + UIApplication.patchEditor)
	ld d,(ix + UIApplication.patchEditor + 1)
	ld ixl,e
	ld ixh,d
	ld de,0100H
	call UIBuffer_GetRelativePosition
	call PatchEditorView_Paint
	pop ix
	pop hl

	push hl
	ld ix,Channel_channels.0
	ld de,1900H
	call UIBuffer_GetRelativePosition
	call UIKeyboard_Paint
	pop hl

	push hl
	ld de,1300H
	call UIBuffer_GetRelativePosition
	ld a,0
	ld ix,(Application_instance.sccVoiceBank)
	call ModuleBank_GetModule
	ld bc,4 << 8 | 0
	call ModuleView_Paint
	pop hl

	push hl
	ld de,1310H
	call UIBuffer_GetRelativePosition
	ld a,1
	ld ix,(Application_instance.sccVoiceBank)
	call ModuleBank_GetModule
	ld bc,4 << 8 | 0
	call ModuleView_Paint
	pop hl

	push hl
	ld de,1320H
	call UIBuffer_GetRelativePosition
	ld a,2
	ld ix,(Application_instance.sccVoiceBank)
	call ModuleBank_GetModule
	ld bc,4 << 8 | 0
	call ModuleView_Paint
	pop hl

	push hl
	ld de,1330H
	call UIBuffer_GetRelativePosition
	ld a,3
	ld ix,(Application_instance.sccVoiceBank)
	call ModuleBank_GetModule
	ld bc,4 << 8 | 0
	call ModuleView_Paint
	pop hl
	ret

;
UIApplication_template:
	ds 29," "
	db 168,169,32,160,32,161,32,162,32,163,32,164,32,165,32,160,32,166,32,167,32,170,171
	ds 23," "
	db " ----"
