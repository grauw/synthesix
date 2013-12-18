Synthesix_Main:
	call INITXT
	ld hl,Synthesix_helloMessage
	call System_Print

	call System_EnableROMInPage2
	call RAM_Init

	call Keys_Init
	call PSG_Init
	call SCC_Init
	call Channel_New
	ld (Synthesix_channel1),ix

	call Math_UnitTest

	call Synthesix_MainLoop
	ret

Synthesix_MainLoop:
	halt
	call Keys_Scan
	call Synthesix_UpdateLiveIndicator
	jp Synthesix_MainLoop

Synthesix_UpdateLiveIndicator:
	ld hl,Synthesix_liveIndicator1
	ld a,(JIFFY)
	bit 5,a
	jp z,System_Print
	ld hl,Synthesix_liveIndicator2
	jp System_Print

Synthesix_helloMessage:
	db "Synthesix\r\n\nMIDI synthesizer for MSX\r\n", 0

Synthesix_liveIndicator1:
	db "_\r",0
Synthesix_liveIndicator2:
	db " \r",0
