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

; ix = voice
Patch_InitVoice:
	call Patch_AddSCCVoice

	call Patch_AddAREnvelope

	call Patch_AddAftertouchVibrato
	call Patch_AddPitchBend

	call Patch_AddPWControl
;	call Patch_AddPWM
	ret

; ix = voice
; ix <- scc voice
; iy <- voice
Patch_AddSCCVoice:
	push ix
	call SCC_GetFreeVoice
	pop hl
	push hl

	ld bc,Voice.key
	add hl,bc
	ld (ix + SCCVoice.note),l
	ld (ix + SCCVoice.note + 1),h

	ld bc,Voice.gate - Voice.key
	add hl,bc
	ld (ix + SCCVoice.amplitude),l
	ld (ix + SCCVoice.amplitude + 1),h
	pop iy
	ret

; ix = scc voice
; iy = voice
Patch_AddAREnvelope:
	push iy
	push ix
	ld a,93
	call Patch_GetController
	ld (hl),32
	push hl
	ld a,94
	call Patch_GetController
	ld (hl),8
	push hl
	call AREnvelope_New
	pop hl
	pop de
	ld (ix + AREnvelope.attack),e
	ld (ix + AREnvelope.attack + 1),d
	ld (ix + AREnvelope.release),l
	ld (ix + AREnvelope.release + 1),h
	ld e,ixl
	ld d,ixh
	pop iy
	pop hl  ; hl = voice
	push hl
	push iy
	push de
	ld bc,Voice.trigger
	add hl,bc
	ld (ix + AREnvelope.trigger),l
	ld (ix + AREnvelope.trigger + 1),h
	ld bc,Voice.gate - Voice.trigger
	add hl,bc
	push ix
	push hl
	call Sustain_New
	pop hl
	ld (ix + Sustain.gate),l
	ld (ix + Sustain.gate + 1),h
	ld a,64
	call Patch_GetController
	ld (ix + Sustain.hold),l
	ld (ix + Sustain.hold + 1),h
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + AREnvelope.gate),e
	ld (ix + AREnvelope.gate + 1),d
	pop de
	pop ix
	ld (ix + SCCVoice.amplitude),e
	ld (ix + SCCVoice.amplitude + 1),d
	pop iy
	ret

; ix = scc voice
; iy = voice
Patch_AddAftertouchVibrato:
	push iy
	push ix
	call SignedTriangleLFO_New
	push ix
	call Multiply_New
	pop de
	ld (ix + Multiply.multiplicand),e
	ld (ix + Multiply.multiplicand + 1),d
	ld de,Channel_channels.0 + Channel.channelPressure
	ld (ix + Multiply.multiplier),e
	ld (ix + Multiply.multiplier + 1),d
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice.detune),e
	ld (ix + SCCVoice.detune + 1),d
	pop iy
	ret

; ix = scc voice
; iy = voice
Patch_AddPitchBend:
	push iy
	push ix
	call PitchBend_New
	ld hl,Channel_channels.0
	ld bc,Channel.pitchBendFine
	add hl,bc
	ld (ix + PitchBend.pitchFine),l
	ld (ix + PitchBend.pitchFine + 1),h
	ld bc,Channel.pitchBendCoarse - Channel.pitchBendFine
	add hl,bc
	ld (ix + PitchBend.pitchCoarse),l
	ld (ix + PitchBend.pitchCoarse + 1),h
	push ix
	call AddPitch_New
	pop hl
	ld bc,PitchBend.note
	add hl,bc
	ld (ix + AddPitch.augendNote),l
	ld (ix + AddPitch.augendNote + 1),h
	ld bc,PitchBend.detune - PitchBend.note
	add hl,bc
	ld (ix + AddPitch.augendDetune),l
	ld (ix + AddPitch.augendDetune + 1),h
	pop iy
	ld l,(iy + SCCVoice.note)
	ld h,(iy + SCCVoice.note + 1)
	ld (ix + AddPitch.addendNote),l
	ld (ix + AddPitch.addendNote + 1),h
	ld l,(iy + SCCVoice.detune)
	ld h,(iy + SCCVoice.detune + 1)
	ld (ix + AddPitch.addendDetune),l
	ld (ix + AddPitch.addendDetune + 1),h
	push iy
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice.note),e
	ld (ix + SCCVoice.note + 1),d
	inc de
	ld (ix + SCCVoice.detune),e
	ld (ix + SCCVoice.detune + 1),d
	pop iy
	ret

Patch_GetController:
	push ix
	ld ix,Channel_channels.0
	call Channel_GetController
	pop ix
	ret

; ix = scc voice
; iy = voice
Patch_AddPWControl:
	ld a,7
	call Patch_GetController
	ld (ix + SCCVoice.wave),l
	ld (ix + SCCVoice.wave + 1),h
	ret

; ix = scc voice
; iy = voice
Patch_AddPWM:
	push iy
	push ix
	call TriangleLFO_New
	push ix
	call MultiplyAdd_New
	pop hl
	ld (ix + MultiplyAdd.multiplicand),l
	ld (ix + MultiplyAdd.multiplicand + 1),h
	ld hl,Value_values.50
	ld (ix + MultiplyAdd.multiplier),l
	ld (ix + MultiplyAdd.multiplier + 1),h
	ld hl,Value_values.64
	ld (ix + MultiplyAdd.addend),l
	ld (ix + MultiplyAdd.addend + 1),h
	ex (sp),ix
	pop hl
	ld (ix + SCCVoice.wave),l
	ld (ix + SCCVoice.wave + 1),h
	pop iy
	ret
