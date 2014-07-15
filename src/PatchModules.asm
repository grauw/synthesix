;
; A list of modules in a patch.
;
PatchModules: MACRO
	MAX_MODULES: equ 128
	modules:
		REPT MAX_MODULES
		ModulePair
		ENDM
	size:
	ENDM

ModulePair: MACRO
	module:
		dw 0
	meta:
		dw 0
	size:
	ENDM

	dw PatchModules.size
PatchModules_class: PatchModules

; ix <- new class
PatchModules_New:
	ld iy,PatchModules_class
	call Class_New
	jp PatchModules_Constructor

; ix = this
; ix <- this
PatchModules_Constructor:
	ret

; ix = this
; de = meta module to add
; hl = module to add
; a <- module index
PatchModules_AddModule: PROC
	push de
	ld b,PatchModules.MAX_MODULES
	ld de,ModulePair.size
Loop:
	ld a,(ix + PatchModules.modules + ModulePair.module)
	or (ix + PatchModules.modules + ModulePair.module + 1)
	jr z,EntryFound
	add ix,de
	djnz Loop
	call System_ThrowException
EntryFound:
	pop de
	ld (ix + PatchModules.modules + ModulePair.module),l
	ld (ix + PatchModules.modules + ModulePair.module + 1),h
	ld (ix + PatchModules.modules + ModulePair.meta),e
	ld (ix + PatchModules.modules + ModulePair.meta + 1),d
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
	IF PatchModules.MAX_MODULES > 128 || ModulePair.size != 4
		ERROR "Assertion failed."
	ENDIF
	ld c,h
	ld b,0
	sla c
	sla c
	rl b
	add ix,bc
	ld c,(ix + PatchModules.modules + ModulePair.module)
	ld b,(ix + PatchModules.modules + ModulePair.module + 1)
	ld h,0
	add hl,bc
	ret
