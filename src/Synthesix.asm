Synthesix_Main:
	call System_EnableROMInPage2
	call RAM_Init

	call UI_Init
	call Keys_Init
	call PSG_Init
	call SCC_Init
	call Channel_New
	ld (Synthesix_channel1),ix

	call Math_UnitTest

	call setmidi

	ld a,(JIFFY)
	ld (Synthesix_lastJiffy),a

	call Synthesix_MainLoop
	ret

Synthesix_MainLoop:
	halt
	call Keys_Scan
	call Synthesix_UpdateChannels
	call Synthesix_UpdateLiveIndicator
	jp Synthesix_MainLoop

Synthesix_UpdateChannels:
	ld a,(Synthesix_lastJiffy)
	ld b,a
	ld a,(JIFFY)
	ld (Synthesix_lastJiffy),a
	sub b
	ret z
	ld b,a
	ld ix,(Synthesix_channel1)
	jp Channel_Update

Synthesix_UpdateLiveIndicator:
	ld hl,Synthesix_liveIndicator1
	ld a,(JIFFY)
	bit 5,a
	jp z,System_Print
	ld hl,Synthesix_liveIndicator2
	jp System_Print

Synthesix_liveIndicator1:
	db "_\r",0
Synthesix_liveIndicator2:
	db " \r",0
