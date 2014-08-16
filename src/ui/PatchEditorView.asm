;
; Display a patch editor
;
PatchEditorView_SELECTCOLOR: equ 0F8H
PatchEditorView_ASSIGNCOLOR: equ 0F2H

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_Paint:
	ld a,(iy + UIBuffer.repaint)
	push af
	ld b,5
	call PatchEditor_GetScrollPosition
	call c,PatchEditorView_ClearBackground
	call PatchEditorView_PaintFocus
	ld e,(ix + PatchEditor.patch)
	ld d,(ix + PatchEditor.patch + 1)
	ld ixl,e
	ld ixh,d
	call PatchEditorView_PaintPatch
	pop af
	ld (iy + UIBuffer.repaint),a
	ret

; c = scroll position
; ix = this
; iy = buffer
PatchEditorView_PaintFocus:
	ld a,(ix + PatchEditor.module)
	sub c
	add a,a
	add a,a
	add a,a
	add a,a
	ld e,a
	ld a,(ix + PatchEditor.port)
	cp 14
	ret nc
	inc a
	ld d,a
	push bc
	push hl
	call UIBuffer_GetRelativePosition
	call UIBuffer_GetBlinkByBuffer
	ld (hl),01111111B
	inc hl
	ld (hl),11111110B
	pop hl
	pop bc
	ld a,(ix + PatchEditor.assign)
	and a
	ld (iy + UIBuffer.blinkColor),PatchEditorView_SELECTCOLOR
	ret z
	ld (iy + UIBuffer.blinkColor),PatchEditorView_ASSIGNCOLOR
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
	call System_LDIR
	pop hl
	pop bc
	ret

; c = scroll position
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
	call ModuleView_Paint
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
