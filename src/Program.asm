Program_LoadDefault:
	ld ix,Channel_channels.0
	call SCCPatch_New
	push ix
	pop hl
	ld ix,Channel_channels.0
	call Channel_AddPatch
	ret
