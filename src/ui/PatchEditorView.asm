;
; Display a patch editor
;
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_Paint:
	ld a,(iy + UIBuffer.repaint)
	push af
	call PatchEditorView_SetFocusColor
	ld b,5
	call PatchEditor_GetScrollPosition
	call c,PatchEditorView_ClearBackground
	ld e,(ix + PatchEditor.patch)
	ld d,(ix + PatchEditor.patch + 1)
	ld ixl,e
	ld ixh,d
	call PatchEditorView_PaintPatch
	pop af
	ld (iy + UIBuffer.repaint),a
	ret

; ix = this
; iy = buffer
PatchEditorView_SetFocusColor:
	ld a,(ix + PatchEditor.assign)
	and a
	ld (iy + UIBuffer.blinkColor),UIFocus.SELECTCOLOR
	ret z
	ld (iy + UIBuffer.blinkColor),UIFocus.ASSIGNCOLOR
	ret

; hl = buffer position
PatchEditorView_ClearBackground:
	ld (iy + UIBuffer.repaint),-1
	push bc
	push hl
	ld e,l
	ld d,h
	inc de
	ld (hl)," "
	ld bc,UIBuffer.WIDTH * 16 - 1
	ldir
	pop hl
	pop bc
	ret

; ix = patch
; iy = buffer
; hl = buffer address
PatchEditorView_PaintPatch: PROC
	push bc
	push ix
	call Patch_GetModuleCount
	pop ix
	ld a,c
	cp 5
	jp c,NoMax
	ld a,5
NoMax:
	ld e,a
	ld d,0
	pop bc
Loop:
	push bc
	push de
	push hl
	push ix
	push hl
	xor a
	call Patch_GetModule
	pop hl
	call PatchEditorView_PaintModule
	pop ix
	pop hl
	ld bc,16
	add hl,bc
	pop de
	pop bc
	inc bc
	dec de
	ld a,d
	or e
	jp nz,Loop
	ret
	ENDP

; de = module
; ix = module type
; iy = buffer
; hl = buffer address
PatchEditorView_PaintModule:
	push de
	ex (sp),ix
	pop de

	ld bc,ModuleType_constants
	call PatchEditorView_CheckType
	jp z,ConstantsView_Paint

	ld bc,ModuleType_channel
	call PatchEditorView_CheckType
	jp z,ChannelView_Paint

	ld bc,ModuleType_controllerBank
	call PatchEditorView_CheckType
	jp z,ControllerBankView_Paint

	ld bc,ModuleType_note
	call PatchEditorView_CheckType
	jp z,NoteView_Paint

	ld bc,ModuleType_sccVoice
	call PatchEditorView_CheckType
	jp z,SCCVoiceView_Paint
	ret

; bc = module type to compare with
; de = module type
; f <- z: match
; Modifies: af
PatchEditorView_CheckType:
	ld a,e
	cp c
	ret nz
	ld a,d
	cp b
	ret
