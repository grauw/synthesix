Synthesix_Main:
	call INITXT
	ld hl,Synthesix_helloMessage
	call Utils_Print

	call RAM_Init
	call Keys_Init
	call PSG_Init
	call SCC_Init

	ld hl,SCC_sawWave
	call SCC_LoadWaveform

Synthesix_MainLoop:
	halt
	call Keys_Scan
	jp Synthesix_MainLoop

RAM_Init:
	ld hl,RAM_dataStart
	ld de,RAM_dataStartAddress
	ld bc,RAM_dataSize
	ldir
	ret

Synthesix_helloMessage:
	db "Synthesix\r\n\nMIDI synthesizer for MSX\r\n", 0

RAM_dataStart:
	include "ram.symbol"
	incbin "ram.bin"
RAM_dataSize: equ $ - RAM_dataStart
