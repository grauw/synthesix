;
; Display a patch editor
;
PatchEditorView_SELECTCOLOR: equ 0F8H
PatchEditorView_ASSIGNCOLOR: equ 0F2H
PatchEditorView_INVALIDCOLOR: equ 0FEH

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_Paint: PROC
	ld a,(iy + UIBuffer.repaint)
	push af
	ld b,5
	call PatchEditor_GetScrollPosition
	jp nc,NoRepaint
	ld (iy + UIBuffer.repaint),-1
NoRepaint:
	bit 0,(iy + UIBuffer.repaint)
	push bc
	call nz,PatchEditorView_PaintBackground
	pop bc
	call PatchEditorView_PaintUpdate
	pop af
	ld (iy + UIBuffer.repaint),a
	ret
	ENDP

; bc = position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_PaintBackground:
	push hl
	call PatchEditorView_PaintProgressBar
	pop hl
	push hl
	call PatchEditorView_ClearBackground
	pop hl
	ret

; bc = position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_PaintProgressBar:
	push bc
	push hl
	ld bc,16 * UIBuffer.WIDTH
	add hl,bc
	ld (hl),140
	ld e,l
	ld d,h
	inc de
	ld bc,UIBuffer.WIDTH - 1
	call System_LDIR
	pop hl
	pop bc

	push hl
	ld a,79
	call Math_Multiply8x16
	push hl
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	ld e,c
	ld d,b
	pop ix
	pop bc
	ld hl,-5
	add hl,de
	ex de,hl
	pop hl
	ret nc
	ld a,d
	or e
	ret z

	push hl
	call Math_Divide16
	pop hl

	push hl
	add hl,bc
	ld bc,16 * UIBuffer.WIDTH
	add hl,bc
	ld (hl),141
	pop hl
	ret

; c = position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_PaintUpdate:
	call PatchEditorView_PaintFocus
	ld e,(ix + PatchEditor.patch)
	ld d,(ix + PatchEditor.patch + 1)
	ld ixl,e
	ld ixh,d
	call PatchEditorView_PaintPatch
	ret

; c = scroll position
; ix = this
; iy = buffer
PatchEditorView_PaintFocus: PROC
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
	ld a,(ix + PatchEditor.mode)
	and a
	ld (iy + UIBuffer.blinkColor),PatchEditorView_SELECTCOLOR
	ret z
	push bc
	push hl
	call PatchEditor_IsValidSelection
	pop hl
	pop bc
	jr c,Invalid
	ld (iy + UIBuffer.blinkColor),PatchEditorView_ASSIGNCOLOR
	ret
Invalid:
	ld (iy + UIBuffer.blinkColor),PatchEditorView_INVALIDCOLOR
	ret
	ENDP

; hl = buffer position
PatchEditorView_ClearBackground:
	ld e,l
	ld d,h
	inc de
	ld (hl)," "
	ld bc,UIBuffer.WIDTH * 16 - 1
	call System_LDIR
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
