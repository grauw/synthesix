;
; Display a patch editor
;
; ix = patch editor
; iy = buffer
; hl = buffer address
PatchEditorView_Paint:
	push hl
	push ix
	call PatchEditorGridView_Paint
	pop ix
	pop hl

	push hl
	push ix
	ld de,PatchEditorGridView_WIDTH
	call UIBuffer_GetRelativePosition
	call PatchEditorModuleView_Paint
	pop ix
	pop hl
	ret
