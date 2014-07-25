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
	size:
	ENDM

	dw Patch.size
Patch_class: Patch

; ix <- new object
Patch_New:
	ld iy,Patch_class
	call Class_New
	jp Patch_Constructor

; ix = this
; ix <- this
Patch_Constructor:
	ld bc,Patch.MAX_MODULES
	push ix
	call ArrayList_New
	pop ix
	ld (ix + Patch.modules),e
	ld (ix + Patch.modules + 1),d
	call Patch_Load
	ret

; ix = this
; ix <- this
Patch_Load: PROC
	push ix
	call NotePool_New
	pop ix
	ld (ix + Patch.notePool),e
	ld (ix + Patch.notePool + 1),d
	push ix
	call Patch_InitModuleLists
	pop ix
	ld hl,Module_values
	call Patch_AddModule                ; module 0
	ld hl,Module_channel
	call Patch_AddModule                ; module 1
	ld hl,Module_controllerBank
	call Patch_AddModule                ; module 2
	ld hl,Module_note
	call Patch_AddModule                ; module 3
	ld hl,Module_envelopeAD
	call Patch_AddModule                ; module 4
	ld hl,Module_envelopeAR
	call Patch_AddModule                ; module 5
	ld hl,Module_sustain
	call Patch_AddModule                ; module 6
	ld hl,Module_lfoTriangleSigned
	call Patch_AddModule                ; module 7
	ld hl,Module_attenuate
	call Patch_AddModule                ; module 8
	ld hl,Module_pitchBend
	call Patch_AddModule                ; module 9
	ld hl,Module_addPitch
	call Patch_AddModule                ; module 10
	ld hl,Module_lfoTriangle
	call Patch_AddModule                ; module 11
	ld hl,Module_attenuateAdd
	call Patch_AddModule                ; module 12
	ld hl,Module_sccVoice
	call Patch_AddModule                ; module 13
	ld hl,13 << 8 | SCCVoice.note
	ld de,3 << 8 | Note.key
	call Patch_AddLink
	ld hl,13 << 8 | SCCVoice.amplitude
	ld de,3 << 8 | Note.gate
	call Patch_AddLink
	; AR envelope
	ld a,93
	call Patch_GetController
	ld (hl),32
	ld a,94
	call Patch_GetController
	ld (hl),8
	ld hl,5 << 8 | EnvelopeAR.attack
	ld de,2 << 8 | 93
	call Patch_AddLink
	ld hl,5 << 8 | EnvelopeAR.release
	ld de,2 << 8 | 94
	call Patch_AddLink
	ld hl,5 << 8 | EnvelopeAR.trigger
	ld de,3 << 8 | Note.trigger
	call Patch_AddLink
	ld hl,6 << 8 | Sustain.gate
	ld de,3 << 8 | Note.gate
	call Patch_AddLink
	ld hl,6 << 8 | Sustain.hold
	ld de,2 << 8 | 64
	call Patch_AddLink
	ld hl,5 << 8 | EnvelopeAR.gate
	ld de,6 << 8 | Sustain.value
	call Patch_AddLink
	ld hl,13 << 8 | SCCVoice.amplitude
	ld de,5 << 8 | EnvelopeAR.value
	call Patch_AddLink
	; After touch vibrato
	ld hl,8 << 8 | Attenuate.multiplicand
	ld de,7 << 8 | LFOTriangleSigned.value
	call Patch_AddLink
	ld hl,8 << 8 | Attenuate.multiplier
	ld de,2 << 8 | 1
	call Patch_AddLink
	ld hl,13 << 8 | SCCVoice.detune
	ld de,8 << 8 | Attenuate.value
	call Patch_AddLink
	; Pitch bend
	ld hl,9 << 8 | PitchBend.pitchFine
	ld de,1 << 8 | Channel.pitchBendFine
	call Patch_AddLink
	ld hl,9 << 8 | PitchBend.pitchCoarse
	ld de,1 << 8 | Channel.pitchBendCoarse
	call Patch_AddLink
	ld hl,10 << 8 | AddPitch.augendNote
	ld de,9 << 8 | PitchBend.note
	call Patch_AddLink
	ld hl,10 << 8 | AddPitch.augendDetune
	ld de,9 << 8 | PitchBend.detune
	call Patch_AddLink
	ld hl,10 << 8 | AddPitch.addendNote
	ld de,3 << 8 | Note.key
	call Patch_AddLink
	ld hl,10 << 8 | AddPitch.addendDetune
	ld de,8 << 8 | Attenuate.value
	call Patch_AddLink
	ld hl,13 << 8 | SCCVoice.note
	ld de,10 << 8 | AddPitch.note
	call Patch_AddLink
	ld hl,13 << 8 | SCCVoice.detune
	ld de,10 << 8 | AddPitch.detune
	call Patch_AddLink
	; Pulse width modulation
	ld hl,12 << 8 | AttenuateAdd.multiplicand
	ld de,11 << 8 | LFOTriangle.value
	call Patch_AddLink
	ld hl,12 << 8 | AttenuateAdd.multiplier
	ld de,0 << 8 | 50
	call Patch_AddLink
	ld hl,12 << 8 | AttenuateAdd.addend
	ld de,0 << 8 | 64
	call Patch_AddLink
	ld hl,13 << 8 | SCCVoice.wave
	ld de,12 << 8 | AttenuateAdd.value
	call Patch_AddLink
	; Pulse width control
;	ld hl,13 << 8 | SCCVoice.wave
;	ld de,2 << 8 | 7
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

; ix = this
Patch_InitModuleLists: PROC
	ld b,(ix + Patch.polyphony)
Loop:
	push bc
	push ix
	call PatchModules_New
	ex (sp),ix
	pop bc
	ld (ix + Patch.moduleLists),c
	ld (ix + Patch.moduleLists + 1),b
	inc ix
	inc ix
	pop bc
	djnz Loop
	ret
	ENDP

; ix = this
; hl = module factory
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
	push ix
	pop iy
	ld b,(ix + Patch.polyphony)
Loop:
	push bc
	push hl
	push ix
	push iy
	call Module_Acquire_HL
	pop iy
	push iy
	ld l,(iy + Patch.moduleLists)
	ld h,(iy + Patch.moduleLists + 1)
	push hl
	ex (sp),ix
	pop hl
	call PatchModules_AddModule
	pop iy
	pop ix
	pop hl
	pop bc
	inc iy
	inc iy
	djnz Loop
	ret
	ENDP

; ix = this
; hl = link source (h: module, l: offset)
; de = link destination (d: module, e: offset)
Patch_AddLink: PROC
	push ix
	ld b,(ix + Patch.polyphony)
Loop:
	push bc
	push de
	push hl
	push ix
	ld c,(ix + Patch.moduleLists)
	ld b,(ix + Patch.moduleLists + 1)
	ld ixl,c
	ld ixh,b
	call PatchModules_AddLink
	pop ix
	pop hl
	pop de
	pop bc
	inc ix
	inc ix
	djnz Loop
	pop ix
	ret
	ENDP

; hl <- controller
Patch_GetController:
	push ix
	ld ix,Channel_channels.0
	call Channel_GetController
	pop ix
	ret
