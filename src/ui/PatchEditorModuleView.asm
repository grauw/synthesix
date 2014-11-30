;
; Display a patch editor’s selected module
;
PatchEditorModuleView_MODULES: equ 1
PatchEditorModuleView_PORTS: equ 16
PatchEditorModuleView_WIDTH: equ ModuleView_WIDTH * PatchEditorModuleView_MODULES
PatchEditorModuleView_HEIGHT: equ PatchEditorModuleView_PORTS + 2
PatchEditorModuleView_SELECTCOLOR: equ 0F8H
PatchEditorModuleView_ASSIGNCOLOR: equ 0F2H
PatchEditorModuleView_INVALIDCOLOR: equ 0FEH

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModuleView_Paint: PROC
	ld a,(iy + UIBuffer.repaint)
	push af
	ld bc,PatchEditorModuleView_MODULES << 8 | PatchEditorModuleView_PORTS
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
	call nz,PatchEditorModuleView_PaintBackground
	pop bc
	call PatchEditorModuleView_PaintUpdate
	pop af
	ld (iy + UIBuffer.repaint),a
	ret
	ENDP

; bc = position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModuleView_PaintBackground:
	IF PatchEditorModuleView_MODULES > 1
	push hl
	call PatchEditorModuleView_PaintProgressBar
	pop hl
	ENDIF
	push hl
	call PatchEditorModuleView_ClearBackground
	pop hl
	ret

; bc = position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModuleView_PaintProgressBar: PROC
	push ix
	push bc
	push hl
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	ld hl,-PatchEditorModuleView_MODULES
	add hl,bc
	jr c,NonNegative
	ld hl,0
NonNegative:
	ex de,hl
	pop hl
	ld bc,PatchEditorModuleView_HEIGHT * UIBuffer.WIDTH
	add hl,bc
	pop bc
	ld a,PatchEditorModuleView_WIDTH
	call HorizontalScrollBarView_Paint
	pop ix
	ret
	ENDP

; c = position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModuleView_PaintUpdate:
	call PatchEditorModuleView_PaintFocus
	call PatchEditorModuleView_PaintPatch
	ret

; c = scroll position
; ix = patch editor
; iy = buffer
PatchEditorModuleView_PaintFocus: PROC
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
	cp PatchEditorModuleView_PORTS
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
	ld (iy + UIBuffer.blinkColor),PatchEditorModuleView_SELECTCOLOR
	ret z
	push bc
	push hl
	call PatchEditor_IsValidSelection
	pop hl
	pop bc
	jr c,Invalid
	ld (iy + UIBuffer.blinkColor),PatchEditorModuleView_ASSIGNCOLOR
	ret
Invalid:
	ld (iy + UIBuffer.blinkColor),PatchEditorModuleView_INVALIDCOLOR
	ret
	ENDP

; hl = buffer position
PatchEditorModuleView_ClearBackground:
	ld a," "
	ld bc,PatchEditorModuleView_HEIGHT << 8 | PatchEditorModuleView_WIDTH
	call UIBuffer_Fill
	ret

; c = scroll position
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModuleView_PaintPatch: PROC
	push bc
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	pop ix
	ld a,c
	pop bc
	cp PatchEditorModuleView_MODULES
	jr c,Loop
	ld a,PatchEditorModuleView_MODULES
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
	ld bc,PatchEditorModuleView_PORTS << 8 | 0
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
PatchEditorModuleView_CheckType:
	ld a,e
	cp c
	ret nz
	ld a,d
	cp b
	ret
