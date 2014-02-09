Program_LoadDefault:
	call Patch_New
	call Patch_GetVoicePool
	push ix
	pop hl
	ld ix,Channel_channels.0
	call Channel_AddVoicePool
	ret
