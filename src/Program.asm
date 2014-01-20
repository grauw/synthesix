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
	push ix
	call AREnvelope_New
	ld e,ixl
	ld d,ixh
	pop ix
	call AREnvelope_SetKeyTrigger
	ld (ix + SCCVoice.amplitude + 0),e
	ld (ix + SCCVoice.amplitude + 1),d
	push ix
	call SignedTriangleLFO_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice.pitch + 0),e
	ld (ix + SCCVoice.pitch + 1),d
	push ix
	ld a,1
	ld ix,Channel_channels.0
	call Channel_GetController
	pop ix
	ld (ix + SCCVoice.wave + 0),e
	ld (ix + SCCVoice.wave + 1),d
	ret
	ENDP
