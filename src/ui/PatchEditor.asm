;
; Patch editor
;
PatchEditor: MACRO
	patch:
		dw 0
	module:
		db 0
	port:
		dw 0
	_size:
	ENDM

	dw PatchEditor._size
PatchEditor_class: PatchEditor

; de = patch
; ix, de <- new object
PatchEditor_New:
	push de
	ld iy,PatchEditor_class
	call Class_New
	pop de
	call PatchEditor_Constructor
	ret

; de = patch
; ix = this
; ix, de <- this
PatchEditor_Constructor:
	ld (ix + PatchEditor.patch),e
	ld (ix + PatchEditor.patch + 1),d
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; ix <- patch
PatchEditor_GetPatch:
	ld e,(ix + PatchEditor.patch)
	ld d,(ix + PatchEditor.patch + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
PatchEditor_Update: PROC
	call PatchEditor_UpdateSelection
	ld c,(ix + PatchEditor.module)
	ld a,(ix + PatchEditor.port)
	push ix
	call PatchEditor_GetPort
	pop ix
	ld (UIFocus_instance.target),hl
	ret
	ENDP

; ix = this
PatchEditor_UpdateSelection: PROC
Loop:
	push ix
	ld ix,KeyMidi_instance
	call KeyMidi_ReadKeyCode
	pop ix
	ret z
	cp 29
	jp z,KeyLeft
	cp 28
	jp z,KeyRight
	cp 30
	jp z,KeyUp
	cp 31
	jp z,KeyDown
	jp Loop
KeyLeft:
	ld a,(ix + PatchEditor.module)
	and a
	call z,PatchEditor_GetModuleCount
	dec a
	ld (ix + PatchEditor.module),a
	jp ClampAndLoop
KeyRight:
	call PatchEditor_GetModuleCount
	inc (ix + PatchEditor.module)
	cp (ix + PatchEditor.module)
	jp nz,ClampAndLoop
	ld (ix + PatchEditor.module),0
	jp ClampAndLoop
KeyUp:
	ld a,(ix + PatchEditor.port)
	and a
	call z,PatchEditor_GetPortCount
	dec a
	ld (ix + PatchEditor.port),a
	jp Loop
KeyDown:
	call PatchEditor_GetPortCount
	inc (ix + PatchEditor.port)
	cp (ix + PatchEditor.port)
	jp nz,Loop
	ld (ix + PatchEditor.port),0
	jp Loop
ClampAndLoop:
	call PatchEditor_GetPortCount
	dec a
	cp (ix + PatchEditor.port)
	jp nc,Loop
	ld (ix + PatchEditor.port),a
	jp Loop
	ENDP

; ix = this
; a <- module count
PatchEditor_GetModuleCount:
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	pop ix
	ld a,c
	ret

; ix = this
; a <- port count
PatchEditor_GetPortCount:
	ld c,(ix + PatchEditor.module)
	ld b,0
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleType
	ld a,(ix + ModuleType.outputCount)
	add a,(ix + ModuleType.inputCount)
	pop ix
	ret

; a = port
; c = module
; ix = this
; hl <- module port address
; Modifies: af, bc, de, hl, ix
PatchEditor_GetPort: PROC
	call PatchEditor_GetPatch
	push af
	ld a,0
	ld b,0
	call Patch_GetModule
	pop af
	bit 0,(ix + ModuleType.outputCount + 1)
	jp nz,ModuleType_GetOutput
	ld c,(ix + ModuleType.outputCount)
	sub c
	jp nc,ModuleType_GetInput
	add a,c
	jp ModuleType_GetOutput
	ENDP
