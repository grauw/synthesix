Program_LoadDefault: PROC
	call SCCPatch_New
	call SCCPatch_GetVoicePool
	push ix
	ld hl,Voice
	call VoicePool_ForEach
	pop hl
	ld ix,Channel_channels.0
	call Channel_AddVoicePool
	ret
Voice:
	call Program_AddAREnvelope

	call Program_AddAftertouchVibrato
	call Program_AddPitchBend

	call Program_AddPWControl
;	call Program_AddPWM
	ret
	ENDP

Program_AddAREnvelope:
	push ix
	ld a,93
	call Program_GetController
	ld (hl),32
	push hl
	ld a,94
	call Program_GetController
	ld (hl),4
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
	pop ix
	call AREnvelope_SetKeyTrigger
	ld (ix + SCCVoice.amplitude),e
	ld (ix + SCCVoice.amplitude + 1),d
	ret

Program_AddAftertouchVibrato:
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
	ret

Program_AddPitchBend:
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
	ret

Program_GetController:
	push ix
	ld ix,Channel_channels.0
	call Channel_GetController
	pop ix
	ret

Program_AddPWControl:
	ld a,7
	call Program_GetController
	ld (ix + SCCVoice.wave),l
	ld (ix + SCCVoice.wave + 1),h
	ret

Program_AddPWM:
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
	ret
