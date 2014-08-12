;
; A patch
;
Patch: MACRO
	MAX_MODULES: equ 128
	polyphony:
		db 4
	notePool:
		dw 0
	moduleLists:
		REPT NotePool.MAX_NOTES
		dw 0
		ENDM
	modules:
		dw 0
	_size:
	ENDM

	dw Patch._size
Patch_class: Patch

; ix <- new object
Patch_New:
	ld iy,Patch_class
	call Class_New
	jp Patch_Constructor

; ix = this
; ix <- this
Patch_Constructor: PROC
	ld bc,Patch.MAX_MODULES
	push ix
	call ArrayList_New
	pop ix
	ld (ix + Patch.modules),e
	ld (ix + Patch.modules + 1),d
	push ix
	ld b,(ix + Patch.polyphony)
Loop:
	push bc
	push ix
	ld bc,Patch.MAX_MODULES
	call ArrayList_New
	pop ix
	ld (ix + Patch.moduleLists),e
	ld (ix + Patch.moduleLists + 1),d
	inc ix
	inc ix
	pop bc
	djnz Loop
	pop ix
	call Patch_Load
	ret
	ENDP

; ix = this
; ix <- this
Patch_Load: PROC
	push ix
	call NotePool_New
	pop ix
	ld (ix + Patch.notePool),e
	ld (ix + Patch.notePool + 1),d
	ld hl,ModuleType_constants
	call Patch_AddModule                ; module 0
	ld hl,ModuleType_channel
	call Patch_AddModule                ; module 1
	ld hl,ModuleType_controllerBank
	call Patch_AddModule                ; module 2
	ld hl,ModuleType_note
	call Patch_AddModule                ; module 3
	ld hl,ModuleType_envelopeAD
	call Patch_AddModule                ; module 4
	ld hl,ModuleType_envelopeAR
	call Patch_AddModule                ; module 5
	ld hl,ModuleType_sustain
	call Patch_AddModule                ; module 6
	ld hl,ModuleType_lfoTriangleBipolar
	call Patch_AddModule                ; module 7
	ld hl,ModuleType_attenuate
	call Patch_AddModule                ; module 8
	ld hl,ModuleType_pitchBend
	call Patch_AddModule                ; module 9
	ld hl,ModuleType_addPitch
	call Patch_AddModule                ; module 10
	ld hl,ModuleType_lfoTriangle
	call Patch_AddModule                ; module 11
	ld hl,ModuleType_attenuateAdd
	call Patch_AddModule                ; module 12
	ld hl,ModuleType_sccVoice
	call Patch_AddModule                ; module 13
	ld hl,13 << 8 | 0  ; SCCVoice.note
	ld de,3  << 8 | 0  ; Note.key
	call Patch_AddLink
	ld hl,13 << 8 | 2  ; SCCVoice.amplitude
	ld de,3  << 8 | 2  ; Note.gate
	call Patch_AddLink
	; AR envelope
	ld hl,5 << 8 | 0   ; EnvelopeAR.attack
	ld de,0 << 8 | 32  ; Value 32
	call Patch_AddLink
	ld hl,5 << 8 | 1   ; EnvelopeAR.release
	ld de,0 << 8 | 8   ; Value 8
	call Patch_AddLink
	ld hl,5 << 8 | 3  ; EnvelopeAR.trigger
	ld de,3 << 8 | 3  ; Note.trigger
	call Patch_AddLink
	ld hl,6 << 8 | 0  ; Sustain.gate
	ld de,3 << 8 | 2  ; Note.gate
	call Patch_AddLink
	ld hl,6 << 8 | 1   ; Sustain.hold
	ld de,2 << 8 | 64  ; Controller 64
	call Patch_AddLink
	ld hl,5 << 8 | 2  ; EnvelopeAR.gate
	ld de,6 << 8 | 0  ; Sustain.value
	call Patch_AddLink
	ld hl,13 << 8 | 2  ; SCCVoice.amplitude
	ld de,5  << 8 | 0  ; EnvelopeAR.value
	call Patch_AddLink
	; After touch vibrato
	ld hl,8 << 8 | 0  ; Attenuate.multiplicand
	ld de,7 << 8 | 0  ; LFOTriangleBipolar.value
	call Patch_AddLink
	ld hl,8 << 8 | 1  ; Attenuate.multiplier
	ld de,2 << 8 | 1  ; Controller 1
	call Patch_AddLink
	ld hl,13 << 8 | 1  ; SCCVoice.detune
	ld de,8  << 8 | 0  ; Attenuate.value
	call Patch_AddLink
	; Pitch bend
	ld hl,9 << 8 | 0  ; PitchBend.pitchCoarse
	ld de,1 << 8 | 2  ; Channel.pitchBendCoarse
	call Patch_AddLink
	ld hl,9 << 8 | 1  ; PitchBend.pitchFine
	ld de,1 << 8 | 3  ; Channel.pitchBendFine
	call Patch_AddLink
	ld hl,10 << 8 | 0  ; AddPitch.augendNote
	ld de,9  << 8 | 0  ; PitchBend.note
	call Patch_AddLink
	ld hl,10 << 8 | 1  ; AddPitch.augendDetune
	ld de,9  << 8 | 1  ; PitchBend.detune
	call Patch_AddLink
	ld hl,10 << 8 | 2  ; AddPitch.addendNote
	ld de,3  << 8 | 0  ; Note.key
	call Patch_AddLink
	ld hl,10 << 8 | 3  ; AddPitch.addendDetune
	ld de,8  << 8 | 0  ; Attenuate.value
	call Patch_AddLink
	ld hl,13 << 8 | 0  ; SCCVoice.note
	ld de,10 << 8 | 0  ; AddPitch.note
	call Patch_AddLink
	ld hl,13 << 8 | 1  ; SCCVoice.detune
	ld de,10 << 8 | 1  ; AddPitch.detune
	call Patch_AddLink
	; Pulse width modulation
	ld hl,12 << 8 | 0  ; AttenuateAdd.multiplicand
	ld de,11 << 8 | 0  ; LFOTriangle.value
	call Patch_AddLink
	ld hl,12 << 8 | 1   ; AttenuateAdd.multiplier
	ld de,0  << 8 | 50  ; Value 50
	call Patch_AddLink
	ld hl,12 << 8 | 2   ; AttenuateAdd.addend
	ld de,0  << 8 | 64  ; Value 64
	call Patch_AddLink
	ld hl,13 << 8 | 3  ; SCCVoice.wave
	ld de,12 << 8 | 0  ; AttenuateAdd.value
	call Patch_AddLink
	; Pulse width control
;	ld hl,13 << 8 | 3  ; SCCVoice.wave
;	ld de,2  << 8 | 7  ; Controller 7
;	call Patch_AddLink
	ret
	ENDP

; ix = this
; ix <- note pool
Patch_GetNotePool:
	ld e,(ix + Patch.notePool)
	ld d,(ix + Patch.notePool + 1)
	ld ixl,e
	ld ixh,d
	ret

; a = note index
; ix = this
; ix <- module list
; Modifies: af, bc, ix
Patch_GetModuleList:
	cp (ix + Patch.polyphony)
	call nc,System_ThrowException
	add a,a
	ld c,a
	ld b,0
	add ix,bc
	ld c,(ix + Patch.moduleLists)
	ld b,(ix + Patch.moduleLists + 1)
	ld ixl,c
	ld ixh,b
	ret

; ix = this
; bc <- module count
; Modifies: bc, de, ix
Patch_GetModuleCount:
	ld e,(ix + Patch.modules)
	ld d,(ix + Patch.modules + 1)
	ld ixl,e
	ld ixh,d
	call ArrayList_GetSize
	ret

; a = note index
; bc = module index
; ix = this
; de <- module
; ix <- module type
; Modifies: af, bc, de, hl, ix
Patch_GetModule:
	push ix
	ld e,(ix + Patch.modules)
	ld d,(ix + Patch.modules + 1)
	ld ixl,e
	ld ixh,d
	call ArrayList_Get
	pop ix
	push de
	push bc
	call Patch_GetModuleList
	pop bc
	call ArrayList_Get
	pop ix
	ret

; bc = module index
; ix = this
; ix <- module type
; Modifies: f, de, hl
Patch_GetModuleType:
	ld e,(ix + Patch.modules)
	ld d,(ix + Patch.modules + 1)
	ld ixl,e
	ld ixh,d
	call ArrayList_Get
	ld ixl,e
	ld ixh,d
	ret

; ix = this
; hl = module type
Patch_AddModule: PROC
	push ix
	ld e,(ix + Patch.modules)
	ld d,(ix + Patch.modules + 1)
	ld ixl,e
	ld ixh,d
	ex de,hl
	call ArrayList_Add
	ex de,hl
	pop ix
	ld a,0
Loop:
	push af
	push hl
	push ix
	push ix
	call Patch_GetModuleList
	pop iy
	push ix
	call ModuleType_Acquire_HL
	ld e,ixl
	ld d,ixh
	pop ix
	call ArrayList_Add
	pop ix
	pop hl
	pop af
	inc a
	cp (ix + Patch.polyphony)
	jp nz,Loop
	ret
	ENDP

; ix = this
; hl = link source (h: module, l: input port)
; de = link destination (d: module, e: output port)
Patch_AddLink: PROC
	ld a,0
Loop:
	cp (ix + Patch.polyphony)
	ret z
	push af
	push de
	push hl
	push ix
	ld c,e
	ld b,l
	push bc
	push ix
	push hl
	ld b,0
	ld c,d
	push af
	call Patch_GetModule
	pop af
	pop hl
	ex (sp),ix
	push de
	ld b,0
	ld c,h
	call Patch_GetModule
	pop hl
	pop iy
	pop bc
	call ModuleType_Link
	pop ix
	pop hl
	pop de
	pop af
	inc a
	jp Loop
	ENDP
