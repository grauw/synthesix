;
; A poly array of modules of a specified type.
;
ModuleBank: MACRO
	MAX_POLYPHONY: equ 16
	polyphony:
		db 0
	type:
		dw 0
	modules:
		REPT MAX_POLYPHONY
		dw 0
		ENDM
	_size:
	ENDM

	dw ModuleBank._size
ModuleBank_class: ModuleBank

; a = polyphony
; hl = module type
; iy = patch
; ix <- new object
ModuleBank_New:
	push af
	push hl
	push iy
	ld iy,ModuleBank_class
	call Class_New
	pop iy
	pop hl
	pop af
	jp ModuleBank_Constructor

; hl = module type
; ix = this
; iy = patch
; ix <- this
ModuleBank_Constructor: PROC
	push ix
	cp ModuleBank.MAX_POLYPHONY
	call nc,System_ThrowException
	ld (ix + ModuleBank.polyphony),a
	ld (ix + ModuleBank.type),l
	ld (ix + ModuleBank.type + 1),h
	ld b,a
Loop:
	push bc
	push hl
	push ix
	push iy
	call ModuleType_Acquire_HL
	ld e,ixl
	ld d,ixh
	pop iy
	pop ix
	ld (ix + ModuleBank.modules),e
	ld (ix + ModuleBank.modules + 1),d
	inc ix
	inc ix
	pop hl
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

; ix = this
; ix <- module type
; Modifies: af
ModuleBank_GetModuleType:
	ld e,(ix + ModuleBank.type)
	ld d,(ix + ModuleBank.type + 1)
	ret

; a = polyphony index
; ix = this
; de <- module
; ix <- module type
; Modifies: af
ModuleBank_GetModule:
	cp (ix + ModuleBank.polyphony)
	call nc,System_ThrowException
	ld e,(ix + ModuleBank.type)
	ld d,(ix + ModuleBank.type + 1)
	push de
	add a,a
	ld e,a
	ld d,0
	add ix,de
	ld e,(ix + ModuleBank.modules)
	ld d,(ix + ModuleBank.modules + 1)
	pop ix
	ret

; a = polyphony index
; ix = this
; iy = other
; de <- this module
; hl <- other module
; ix <- this module type
; iy <- other module type
; Modifies: af
ModuleBank_GetModulePair:
	cp (ix + ModuleBank.polyphony)
	call nc,System_ThrowException
	cp (iy + ModuleBank.polyphony)
	call nc,System_ThrowException
	ld e,(ix + ModuleBank.type)
	ld d,(ix + ModuleBank.type + 1)
	push de
	ld l,(iy + ModuleBank.type)
	ld h,(iy + ModuleBank.type + 1)
	push hl
	add a,a
	ld e,a
	ld d,0
	add ix,de
	add iy,de
	ld e,(ix + ModuleBank.modules)
	ld d,(ix + ModuleBank.modules + 1)
	ld l,(iy + ModuleBank.modules)
	ld h,(iy + ModuleBank.modules + 1)
	pop iy
	pop ix
	ret

; a = polyphony index
; de = address somewhere inside the module
; ix = this
; f <- c: found
; hl <- module offset (if found)
; ix <- module type
; Modifies: af
ModuleBank_IsInModule:
	ex de,hl
	call ModuleBank_GetModule
	and a
	sbc hl,de
	ccf
	ret nc
	ld e,(ix + ModuleType.size)
	ld d,(ix + ModuleType.size + 1)
	and a
	sbc hl,de
	add hl,de
	ret

;
; Link an input port of this bank’s modules to the output port of another bank
;
; b = this bank input port
; c = other bank output port
; ix = this bank (source)
; iy = other bank (destination)
ModuleBank_Link: PROC
	ld a,0
Loop:
	push af
	push bc
	push ix
	push iy
	call ModuleBank_GetModulePair
	call ModuleType_Link
	pop iy
	pop ix
	pop bc
	pop af
	inc a
	cp (ix + ModuleBank.polyphony)
	jp c,Loop
	ret
	ENDP
