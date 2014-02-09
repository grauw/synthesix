Program_LoadDefault:
	call SCCPatch_New
	call SCCPatch_GetVoicePool
	push ix
	pop hl
	ld ix,Channel_channels.0
	call Channel_AddVoicePool
	ret
