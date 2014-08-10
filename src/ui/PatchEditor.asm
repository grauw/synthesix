;
; Patch editor
;
PatchEditor: MACRO
	patch:
		dw 0
	module:
		db 0
	port:
		db 0
	assign:
		db 0
	assignModule:
		db 0
	assignPort:
		db 0
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
	call ProcessKey
	jp Loop
ProcessKey:
	cp 29
	jp z,KeyLeft
	cp 28
	jp z,KeyRight
	cp 30
	jp z,KeyUp
	cp 31
	jp z,KeyDown
	cp 13
	jp z,Select
	cp 27
	jp z,Cancel
	ret
Select:
	bit 0,(ix + PatchEditor.assign)
	jp nz,Assign
	ld b,(ix + PatchEditor.module)
	ld c,(ix + PatchEditor.port)
	ld (ix + PatchEditor.assignModule),b
	ld (ix + PatchEditor.assignPort),c
	ld (ix + PatchEditor.assign),-1
	ret
Assign:
	ld b,(ix + PatchEditor.assignModule)
	ld c,(ix + PatchEditor.assignPort)
	ld (ix + PatchEditor.module),b
	ld (ix + PatchEditor.port),c
	ld (ix + PatchEditor.assign),0
	ret
Cancel:
	bit 0,(ix + PatchEditor.assign)
	ret z
	ld b,(ix + PatchEditor.assignModule)
	ld c,(ix + PatchEditor.assignPort)
	ld (ix + PatchEditor.module),b
	ld (ix + PatchEditor.port),c
	ld (ix + PatchEditor.assign),0
	ret
KeyLeft:
	ld a,(ix + PatchEditor.module)
	and a
	call z,PatchEditor_GetModuleCount
	dec a
	ld (ix + PatchEditor.module),a
	jp Clamp
KeyRight:
	call PatchEditor_GetModuleCount
	inc (ix + PatchEditor.module)
	cp (ix + PatchEditor.module)
	jp nz,Clamp
	ld (ix + PatchEditor.module),0
	jp Clamp
KeyUp:
	ld a,(ix + PatchEditor.port)
	and a
	call z,PatchEditor_GetPortCount
	dec a
	ld (ix + PatchEditor.port),a
	ret
KeyDown:
	call PatchEditor_GetPortCount
	inc (ix + PatchEditor.port)
	cp (ix + PatchEditor.port)
	ret nz
	ld (ix + PatchEditor.port),0
	ret
Clamp:
	call PatchEditor_GetPortCount
	dec a
	cp (ix + PatchEditor.port)
	ret nc
	ld (ix + PatchEditor.port),a
	ret
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
