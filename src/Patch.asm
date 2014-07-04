;
; A patch
;
Patch: MACRO
	polyphony:
		db 4
	voicePool:
		dw 0
	moduleLists:
		REPT VoicePool.MAX_VOICES
		dw 0
		ENDM
	size:
	ENDM

	dw Patch.size
Patch_class: Patch

; ix <- new class
Patch_New:
	ld iy,Patch_class
	call Class_New
	jp Patch_Constructor

; ix = this
; ix <- this
Patch_Constructor: PROC
	push ix
	call VoicePool_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + Patch.voicePool),e
	ld (ix + Patch.voicePool + 1),d
	push ix
	call Patch_InitModuleLists
	pop ix
	ld hl,Patch_ValuesFactory
	call Patch_AddModule                ; module 0
	ld hl,Patch_ChannelFactory
	call Patch_AddModule                ; module 1
	ld hl,Patch_ControllerBankFactory
	call Patch_AddModule                ; module 2
	ld hl,Patch_VoiceFactory
	call Patch_AddModule                ; module 3
	ld hl,Patch_SCCVoiceFactory
	call Patch_AddModule                ; module 4
	ld hl,4 << 8 | SCCVoice.note
	ld de,3 << 8 | Voice.key
	call Patch_AddLink
	ld hl,4 << 8 | SCCVoice.amplitude
	ld de,3 << 8 | Voice.gate
	call Patch_AddLink
	; AR envelope
	ld hl,Patch_AREnvelopeFactory
	call Patch_AddModule                ; module 5
	ld hl,Patch_SustainFactory
	call Patch_AddModule                ; module 6
	ld a,93
	call Patch_GetController
	ld (hl),32
	ld a,94
	call Patch_GetController
	ld (hl),8
	ld hl,5 << 8 | AREnvelope.attack
	ld de,2 << 8 | 93
	call Patch_AddLink
	ld hl,5 << 8 | AREnvelope.release
	ld de,2 << 8 | 94
	call Patch_AddLink
	ld hl,5 << 8 | AREnvelope.trigger
	ld de,3 << 8 | Voice.trigger
	call Patch_AddLink
	ld hl,6 << 8 | Sustain.gate
	ld de,3 << 8 | Voice.gate
	call Patch_AddLink
	ld hl,6 << 8 | Sustain.hold
	ld de,2 << 8 | 64
	call Patch_AddLink
	ld hl,5 << 8 | AREnvelope.gate
	ld de,6 << 8 | Sustain.value
	call Patch_AddLink
	ld hl,4 << 8 | SCCVoice.amplitude
	ld de,5 << 8 | AREnvelope.value
	call Patch_AddLink
	; After touch vibrato
	ld hl,Patch_SignedTriangleLFOFactory
	call Patch_AddModule                ; module 7
	ld hl,Patch_MultiplyFactory
	call Patch_AddModule                ; module 8
	ld hl,8 << 8 | Multiply.multiplicand
	ld de,7 << 8 | SignedTriangleLFO.value
	call Patch_AddLink
	ld hl,8 << 8 | Multiply.multiplier
	ld de,1 << 8 | Channel.channelPressure
	call Patch_AddLink
	ld hl,4 << 8 | SCCVoice.detune
	ld de,8 << 8 | Multiply.value
	call Patch_AddLink
	; Pitch bend
	ld hl,Patch_PitchBendFactory
	call Patch_AddModule                ; module 9
	ld hl,Patch_AddPitchFactory
	call Patch_AddModule                ; module 10
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
	ld de,3 << 8 | Voice.key
	call Patch_AddLink
	ld hl,10 << 8 | AddPitch.addendDetune
	ld de,0 << 8 | 0
	call Patch_AddLink
	ld hl,4 << 8 | SCCVoice.note
	ld de,10 << 8 | AddPitch.note
	call Patch_AddLink
	ld hl,4 << 8 | SCCVoice.detune
	ld de,10 << 8 | AddPitch.detune
	call Patch_AddLink
	; Pulse width modulation
	ld hl,Patch_TriangleLFOFactory
	call Patch_AddModule                ; module 11
	ld hl,Patch_MultiplyAddFactory
	call Patch_AddModule                ; module 12
	ld hl,12 << 8 | MultiplyAdd.multiplicand
	ld de,11 << 8 | TriangleLFO.value
	call Patch_AddLink
	ld hl,12 << 8 | MultiplyAdd.multiplier
	ld de,0 << 8 | 50
	call Patch_AddLink
	ld hl,12 << 8 | MultiplyAdd.addend
	ld de,0 << 8 | 64
	call Patch_AddLink
	ld hl,4 << 8 | SCCVoice.wave
	ld de,12 << 8 | MultiplyAdd.value
	call Patch_AddLink
	; Pulse width control
;	ld hl,4 << 8 | SCCVoice.wave
;	ld de,2 << 8 | 7
;	call Patch_AddLink
	ret
	ENDP

; ix = this
Patch_GetVoicePool:
	ld e,(ix + Patch.voicePool)
	ld d,(ix + Patch.voicePool + 1)
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
	pop iy
	ld b,(ix + Patch.polyphony)
Loop:
	push bc
	push hl
	push ix
	push iy
	call Patch_CallModuleFactory
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

; hl = module factory
Patch_CallModuleFactory:
	jp hl

; hl <- controller
Patch_GetController:
	push ix
	ld ix,Channel_channels.0
	call Channel_GetController
	pop ix
	ret

; ix = this
Patch_ValuesFactory:
	ld ix,Value_values
	ret

; ix = this
Patch_ChannelFactory:
	ld ix,Channel_channels.0
	ret

; ix = this
Patch_ControllerBankFactory:
	ld ix,Channel_channels.0
	call Channel_GetControllerBank
	ret

; ix = this
Patch_VoiceFactory:
	ld l,(ix + Patch.voicePool)
	ld h,(ix + Patch.voicePool + 1)
	push hl
	call Voice_New
	ex (sp),ix
	pop hl
	push hl
	call VoicePool_AddVoice
	pop ix
	ret

; ix = this
Patch_SCCVoiceFactory:
	call SCC_GetFreeVoice
	ret

; ix = this
Patch_AREnvelopeFactory:
	call AREnvelope_New
	ret

; ix = this
Patch_SustainFactory:
	call Sustain_New
	ret

; ix = this
Patch_SignedTriangleLFOFactory:
	call SignedTriangleLFO_New
	ret

; ix = this
Patch_MultiplyFactory:
	call Multiply_New
	ret

; ix = this
Patch_PitchBendFactory:
	call PitchBend_New
	ret

; ix = this
Patch_AddPitchFactory:
	call AddPitch_New
	ret

; ix = this
Patch_TriangleLFOFactory:
	call TriangleLFO_New
	ret

; ix = this
Patch_MultiplyAddFactory:
	call MultiplyAdd_New
	ret
