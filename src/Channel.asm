Channel_NoteOn:
	ld ix,SCC_voice1
	call SCCVoice_NoteOn
	ret

Channel_NoteOff:
	ld ix,SCC_voice1
	call SCCVoice_NoteOff
	ret
