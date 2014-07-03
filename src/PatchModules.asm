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
PatchModules_class: Patch

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
