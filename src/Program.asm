Program_LoadDefault: PROC
	ld ix,Channel_channels.0
	call SCCPatch_New
	push ix
	ld hl,Voice
	call SCCPatch_ForEach
	pop hl
	ld ix,Channel_channels.0
	call Channel_AddPatch
	ret
Voice:
	call Program_CreateAREnvelope
	call AREnvelope_SetKeyTrigger
	ld (ix + SCCVoice.amplitude + 0),e
	ld (ix + SCCVoice.amplitude + 1),d

	call Program_SignedTriangleLFO
	ld (ix + SCCVoice.pitch + 0),e
	ld (ix + SCCVoice.pitch + 1),d

	call Program_GetController1
	ld (ix + SCCVoice.wave + 0),e
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
