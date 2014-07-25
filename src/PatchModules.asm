;
; A list of modules in a patch.
;
PatchModules: MACRO
	MAX_MODULES: equ 128
	modules:
		REPT MAX_MODULES
		dw 0
		ENDM
	size:
	ENDM

	dw PatchModules.size
PatchModules_class: PatchModules

; ix, de <- new object
PatchModules_New:
	ld iy,PatchModules_class
	call Class_New
	jp PatchModules_Constructor

; ix = this
; ix, de <- this
PatchModules_Constructor:
	ld e,ixl
	ld d,ixh
	ret

; ix = this
; hl = module to add
; a <- module index
PatchModules_AddModule: PROC
	ld b,PatchModules.MAX_MODULES
Loop:
	ld a,(ix + PatchModules.modules)
	or (ix + PatchModules.modules + 1)
	jr z,EntryFound
	inc ix
	inc ix
	djnz Loop
	call System_ThrowException
EntryFound:
	ld (ix + PatchModules.modules),l
	ld (ix + PatchModules.modules + 1),h
	ld a,128
	sub b
	ret
	ENDP

; ix = this
; hl = link source (h: module, l: offset)
; de = link destination (d: module, e: offset)
PatchModules_AddLink:
	push ix
	ex de,hl
	call PatchModules_GetModuleJack
	ex de,hl
	pop ix
	call PatchModules_GetModuleJack
	ld (hl),e
	inc hl
	ld (hl),d
	ret

; ix = this
; h = module index
; l = module offset
; hl <- module jack point
PatchModules_GetModuleJack:
	ld c,h
	ld b,0
	sla c
	add ix,bc
	ld c,(ix + PatchModules.modules)
	ld b,(ix + PatchModules.modules + 1)
	ld h,0
	add hl,bc
	ret
