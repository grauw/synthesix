Synthesix_Main:
	call System_EnableROMInPage2
	call RAM_Init

	call UI_Init
	call Keys_Init
	call PSG_Init
	call SCC_Init
	ld ix,Channel_channels.0
	call Channel_Constructor

	call Math_UnitTest

	call setmidi

	ld hl,Synthesix_Interrupt
	call System_InstallTIMIHook

	call Synthesix_MainLoop

	call System_RestoreTIMIHook
	call KILBUF
	ret

Synthesix_MainLoop:
	call UI_Update
	ld a,(Keys_escape)
	and a
	jp z,Synthesix_MainLoop
	ret

Synthesix_Interrupt:
	ld a,0F5H
	ld b,7
	call VDP_SetRegister

	call Keys_Scan
	call MidiIn_ProcessMessages
	call Synthesix_UpdateChannels

	ld a,0F4H
	ld b,7
	call VDP_SetRegister
	ret

Synthesix_UpdateChannels:
	ld ix,Channel_channels.0
	call Channel_Update
	ret
