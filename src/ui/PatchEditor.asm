;
; Patch editor
;
PatchEditor: MACRO
	module:
		db 0
	port:
		dw 0
	_size:
	ENDM

	dw PatchEditor._size
PatchEditor_class: PatchEditor

; ix, de <- new object
PatchEditor_New:
	ld iy,PatchEditor_class
	call Class_New
	call PatchEditor_Constructor
	ret

; ix = this
; ix, de <- this
PatchEditor_Constructor:
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; iy = patch
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
	push iy
	pop ix
	call Patch_GetModuleCount
	pop ix
	ld a,c
	neg
	ld b,a

	push iy
	ld iy,KeyMidi_instance
	ld a,(ix + PatchEditor.module)
	sub (iy + KeyMidi.left)
	ld (iy + KeyMidi.left),0
	jr nc,NoWrapLeft
	sub b
NoWrapLeft:
	add a,(iy + KeyMidi.right)
	ld (iy + KeyMidi.right),0
	add a,b
	jr c,WrapRight
	sub b
WrapRight:
	ld (ix + PatchEditor.module),a
	pop iy

	ld c,a
	ld b,0
	push ix
	push iy
	pop ix
	call Patch_GetModuleType
	ld a,(ix + ModuleType.outputCount)
	add a,(ix + ModuleType.inputCount)
	pop ix
	ld c,a
	neg
	ld b,a

	push iy
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
	sub (iy + KeyMidi.up)
	ld (iy + KeyMidi.up),0
	jr nc,NoWrapTop
	sub b
NoWrapTop:
	add a,(iy + KeyMidi.down)
	ld (iy + KeyMidi.down),0
	add a,b
	jr c,WrapBottom
	sub b
WrapBottom:
	ld (ix + PatchEditor.port),a
	pop iy
	ret
	ENDP

; a = port
; c = module
; iy = patch
; hl <- module port address
; Modifies: af, bc, de, hl, ix
PatchEditor_GetPort: PROC
	push iy
	pop ix
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
