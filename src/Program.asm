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
	call Program_CreateAREnvelope
	call AREnvelope_SetKeyTrigger
	ld (ix + SCCVoice.amplitude),e
	ld (ix + SCCVoice.amplitude + 1),d

	call Program_SignedTriangleLFO
	ld (ix + SCCVoice.detune),e
	ld (ix + SCCVoice.detune + 1),d

;	call Program_GetController1
	call Program_CreateSquareWaveLFO
	ld (ix + SCCVoice.wave),e
	ld (ix + SCCVoice.wave + 1),d
	ret
	ENDP

Program_CreateAREnvelope:
	push ix
	call AREnvelope_New
	ld e,ixl
	ld d,ixh
	pop ix
	ret

Program_SignedTriangleLFO:
	push ix
	call SignedTriangleLFO_New
	ld e,ixl
	ld d,ixh
	pop ix
	ret

Program_GetController1:
	push ix
	ld a,1
	ld ix,Channel_channels.0
	call Channel_GetController
	pop ix
	ret

Program_CreateSquareWaveLFO:
	push ix
	call TriangleLFO_New
	push ix
	call MultiplyAdd_New
	pop de
	ld (ix + MultiplyAdd.multiplicand),e
	ld (ix + MultiplyAdd.multiplicand + 1),d
	ld de,Value_values.50
	ld (ix + MultiplyAdd.multiplier),e
	ld (ix + MultiplyAdd.multiplier + 1),d
	ld de,Value_values.64
	ld (ix + MultiplyAdd.addend),e
	ld (ix + MultiplyAdd.addend + 1),d
	ld e,ixl
	ld d,ixh
	pop ix
	ret
