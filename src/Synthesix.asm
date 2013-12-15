Synthesix_Main:
	call INITXT
	ld hl,Synthesix_helloMessage
	call Utils_Print

	call RAM_Init
	call Keys_Init
	call PSG_Init
	call SCC_Init

	ld hl,SCC_sawWave
	ld ix,SCC_voice1
	call SCCVoice_LoadWave

	call Synthesix_MainLoop
	ret

Synthesix_MainLoop:
	halt
	call Keys_Scan
	jp Synthesix_MainLoop

Synthesix_helloMessage:
	db "Synthesix\r\n\nMIDI synthesizer for MSX\r\n", 0
