;
; Display a patch editor’s modules
;
PatchEditorModulesView_MODULES_COLUMNS: equ 4
PatchEditorModulesView_MODULES_ROWS: equ 6
PatchEditorModulesView_PORTS: equ 1
PatchEditorModulesView_MODULE_HEIGHT: equ PatchEditorModulesView_PORTS + 2
PatchEditorModulesView_WIDTH: equ PatchEditorModulesView_MODULES_COLUMNS * ModuleView_WIDTH
PatchEditorModulesView_HEIGHT: equ PatchEditorModulesView_MODULES_ROWS * PatchEditorModulesView_MODULE_HEIGHT

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModulesView_Paint:
	bit 0,(iy + UIBuffer.repaint)
	call nz,PatchEditorModulesView_PaintBackground
	call PatchEditorModulesView_PaintUpdate
	ret

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModulesView_PaintBackground:
	push hl
	call PatchEditorModulesView_ClearBackground
	pop hl
	ret

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModulesView_PaintUpdate:
	call PatchEditorModulesView_PaintPatch
	ret

; hl = buffer position
PatchEditorModulesView_ClearBackground:
	ld a," "
	ld bc,PatchEditorModulesView_HEIGHT << 8 | PatchEditorModulesView_WIDTH
	call UIBuffer_Fill
	ret

; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorModulesView_PaintPatch: PROC
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	pop ix
	ld a,c
	ld bc,0
	ld d,PatchEditorModulesView_MODULES_COLUMNS
Loop:
	push af
	push bc
	push de
	push hl
	push ix
	push hl
	ld a,(ix + PatchEditor.module)
	cp c
	push af
	ld a,0
	call PatchEditor_GetPatch
	call Patch_GetModule
	pop af
	pop hl
	call z,ModuleView_PaintFocus
	ld bc,PatchEditorModulesView_PORTS << 8 | 0
	call ModuleView_Paint
	pop ix
	pop hl
	pop de
	ld bc,ModuleView_WIDTH
	add hl,bc
	dec d
	jr nz,NoNewRow
	ld d,PatchEditorModulesView_MODULES_COLUMNS
	ld bc,PatchEditorModulesView_MODULE_HEIGHT * UIBuffer.WIDTH - PatchEditorModulesView_WIDTH
	add hl,bc
NoNewRow:
	pop bc
	pop af
	inc bc
	dec a
	jp nz,Loop
	ret
	ENDP
