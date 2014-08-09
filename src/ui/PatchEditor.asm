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
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleCount
	pop ix
	ld a,c
	neg
	ld b,a

	ld iy,KeyMidi_instance
	ld a,(ix + PatchEditor.module)
	di
	sub (iy + KeyMidi.left)
	ei
	ld (iy + KeyMidi.left),0
	jr nc,NoWrapLeft
	sub b
NoWrapLeft:
	di
	add a,(iy + KeyMidi.right)
	ei
	ld (iy + KeyMidi.right),0
	add a,b
	jr c,WrapRight
	sub b
WrapRight:
	ld (ix + PatchEditor.module),a

	ld c,a
	ld b,0
	push ix
	call PatchEditor_GetPatch
	call Patch_GetModuleType
	ld a,(ix + ModuleType.outputCount)
	add a,(ix + ModuleType.inputCount)
	pop ix
	ld c,a
	neg
	ld b,a

	ld iy,KeyMidi_instance
	ld a,(ix + PatchEditor.port)
	add a,b
	jp c,ClampBottom
	sub b
	jp NoClampBottom
ClampBottom:
	ld a,c
	dec a
NoClampBottom:
	di
	sub (iy + KeyMidi.up)
	ei
	ld (iy + KeyMidi.up),0
	jr nc,NoWrapTop
	sub b
NoWrapTop:
	di
	add a,(iy + KeyMidi.down)
	ei
	ld (iy + KeyMidi.down),0
	add a,b
	jr c,WrapBottom
	sub b
WrapBottom:
	ld (ix + PatchEditor.port),a
	ret
	ENDP

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
