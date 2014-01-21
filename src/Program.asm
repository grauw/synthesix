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

	call Program_AddVibrato

	call Program_AddPWControl
;	call Program_AddPWM
	ret
	ENDP

Program_AddAREnvelope:
	push ix
	call AREnvelope_New
	ld e,ixl
	ld d,ixh
	pop ix
	call AREnvelope_SetKeyTrigger
	ld (ix + SCCVoice.amplitude),e
	ld (ix + SCCVoice.amplitude + 1),d
	ret

Program_AddVibrato:
	push ix
	call SignedTriangleLFO_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice.detune),e
	ld (ix + SCCVoice.detune + 1),d
	ret

Program_GetController1:
	ld a,1
Program_GetController:
	push ix
	ld ix,Channel_channels.0
	call Channel_GetController
	pop ix
	ret

Program_AddPWControl:
	call Program_GetController1
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
