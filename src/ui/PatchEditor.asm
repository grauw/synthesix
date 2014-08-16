;
; Patch editor
;
PatchEditor: MACRO
	patch:
		dw 0
	mode:
		db 0  ; 0 = select, 1 = assign
	module:
		db 0
	port:
		db 0
	assignModule:
		db 0
	assignPort:
		db 0
	scrollPosition:
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
; b = width
; bc <- position
; f <- c: position moved
PatchEditor_GetScrollPosition: PROC
	ld c,(ix + PatchEditor.scrollPosition)
	ld a,(ix + PatchEditor.module)
	cp c
	jr c,MoveLeft
	sub b
	jr c,NoChange
	cp c
	jr nc,MoveRight
NoChange:
	ld b,0
	and a
	ret
MoveRight:
	inc a
MoveLeft:
	ld (ix + PatchEditor.scrollPosition),a
	ld c,a
	ld b,0
	scf
	ret
	ENDP

; ix = this
PatchEditor_Update: PROC
	call PatchEditor_UpdateSelection
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
	bit 0,(ix + PatchEditor.mode)
	jp nz,Assign
	ld e,(ix + PatchEditor.module)
	ld d,(ix + PatchEditor.port)
	ld (ix + PatchEditor.assignModule),e
	ld (ix + PatchEditor.assignPort),d
	ld (ix + PatchEditor.mode),1
	call PatchEditor_IsOutputSelected
	ret c
	call PatchEditor_GetInputTarget
	ld (ix + PatchEditor.module),c
	ld (ix + PatchEditor.port),a
	ret
Assign:
	ld b,(ix + PatchEditor.assignModule)
	ld c,(ix + PatchEditor.assignPort)
	ld (ix + PatchEditor.module),b
	ld (ix + PatchEditor.port),c
	ld (ix + PatchEditor.mode),0
	ret
Cancel:
	bit 0,(ix + PatchEditor.mode)
	ret z
	ld b,(ix + PatchEditor.assignModule)
	ld c,(ix + PatchEditor.assignPort)
	ld (ix + PatchEditor.module),b
	ld (ix + PatchEditor.port),c
	ld (ix + PatchEditor.mode),0
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

; ix = this
; f <- c: selected port is output
PatchEditor_IsOutputSelected: PROC
	push ix
	ld c,(ix + PatchEditor.module)
	ld b,0
	call PatchEditor_GetPatch
	call Patch_GetModuleType
	bit 0,(ix + ModuleType.outputCount + 1)
	jp nz,Output
	ld b,(ix + ModuleType.outputCount)
	pop ix
	ld a,(ix + PatchEditor.port)
	cp b
	ret
Output:
	pop ix
	scf
	ret
	ENDP

;
; Return the output port the selected input port points to.
;
; ix = this
; bc <- module
; a <- port
PatchEditor_GetInputTarget:
	push ix
	ld c,(ix + PatchEditor.module)
	ld a,(ix + PatchEditor.port)
	call PatchEditor_GetPort
	pop ix
	push ix
	call PatchEditor_GetPatch
	ld e,(hl)
	inc hl
	ld d,(hl)
	call Patch_FindModuleOutputPort
	pop ix
	ret
