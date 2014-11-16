;
; Display a patch editor
;
PatchEditorView_MODULES: equ 1
PatchEditorView_PORTS: equ 14
PatchEditorView_WIDTH: equ ModuleView_WIDTH * PatchEditorView_MODULES
PatchEditorView_HEIGHT: equ PatchEditorView_PORTS + 2
PatchEditorView_SELECTCOLOR: equ 0F8H
PatchEditorView_ASSIGNCOLOR: equ 0F2H
PatchEditorView_INVALIDCOLOR: equ 0FEH

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_Paint: PROC
	ld a,(iy + UIBuffer.repaint)
	push af
	ld bc,PatchEditorView_MODULES << 8 | PatchEditorView_PORTS
	call PatchEditor_UpdateScrollPosition
	ld c,(ix + PatchEditor.moduleScrollPosition)
	ld b,0
	ld a,(ix + PatchEditor.moduleScrollPositionMoved)
	or (ix + PatchEditor.portScrollPositionMoved)
	jp z,NoRepaint
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
PatchEditorView_PaintProgressBar: PROC
	push ix
	push bc
	push hl
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	ld hl,-PatchEditorView_MODULES
	add hl,bc
	jr c,NonNegative
	ld hl,0
NonNegative:
	ex de,hl
	pop hl
	ld bc,PatchEditorView_HEIGHT * UIBuffer.WIDTH
	add hl,bc
	pop bc
	ld a,PatchEditorView_WIDTH
	call HorizontalScrollBarView_Paint
	pop ix
	ret
	ENDP

; c = position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_PaintUpdate:
	call PatchEditorView_PaintFocus
	call PatchEditorView_PaintPatch
	ret

; c = scroll position
; ix = patch editor
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
	sub (ix + PatchEditor.portScrollPosition)
	call c,System_ThrowException  ; port should be within scroll position bounds
	cp PatchEditorView_PORTS
	call nc,System_ThrowException
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
	ld a," "
	ld bc,PatchEditorView_HEIGHT << 8 | PatchEditorView_WIDTH
	call UIBuffer_Fill
	ret

; c = scroll position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_PaintPatch: PROC
	push bc
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	pop ix
	ld a,c
	pop bc
	cp PatchEditorView_MODULES
	jr c,Loop
	ld a,PatchEditorView_MODULES
Loop:
	push af
	push bc
	push de
	push hl
	push ix
	push bc
	push hl
	ld a,0
	call PatchEditor_GetPatch
	call Patch_GetModule
	pop hl
	pop bc
	ex (sp),ix
	ld a,(ix + PatchEditor.module)
	cp c
	ld bc,PatchEditorView_PORTS << 8 | 0
	jr nz,NotThisModule
	ld c,(ix + PatchEditor.portScrollPosition)
NotThisModule:
	ex (sp),ix
	call ModuleView_Paint
	pop ix
	pop hl
	ld bc,ModuleView_WIDTH
	add hl,bc
	pop de
	pop bc
	pop af
	inc bc
	dec a
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
