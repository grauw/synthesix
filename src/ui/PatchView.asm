;
; Display a patch
;
; ix = patch
; iy = buffer
; hl = buffer address
PatchView_Paint: PROC
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
	ld bc,0
Loop:
	push bc
	push de
	push hl
	push ix
	push hl
	xor a
	call Patch_GetModule
	pop hl
	call PatchView_PaintModule
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
PatchView_PaintModule:
	push de
	ex (sp),ix
	pop de

	ld bc,ModuleType_channel
	call PatchView_CheckType
	jp z,ChannelView_Paint

	ld bc,ModuleType_controllerBank
	call PatchView_CheckType
	jp z,ControllerBankView_Paint

	ld bc,ModuleType_note
	call PatchView_CheckType
	jp z,NoteView_Paint
	ret

; bc = module type to compare with
; de = module type
; f <- z: match
; Modifies: af
PatchView_CheckType:
	ld a,e
	cp c
	ret nz
	ld a,d
	cp b
	ret
