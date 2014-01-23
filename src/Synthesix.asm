Synthesix_Main:
	call System_EnableROMInPage2
	call RAM_Init

	call UI_Init
	ld ix,KeyMidi_instance
	call KeyMidi_Constructor
	call Channels_Init
	call PSG_Init
	call SCC_Init
	call Program_LoadDefault

	call Math_UnitTest

	call System_EnableInterruptHandler
	ld ix,MSXMidi_instance
	call MSXMidi_Install
	ld hl,Synthesix_Interrupt
	call System_InstallTIMIHook

	call Synthesix_MainLoop

	call System_RestoreTIMIHook
	call System_DisableInterruptHandler
	call MSXMidi_Uninstall
	call KILBUF
	ret

Synthesix_MainLoop:
	call UI_Update
	ld ix,KeyMidi_instance
	ld a,(ix + KeyMidi.escape)
	and a
	jp z,Synthesix_MainLoop
	ret

Synthesix_Interrupt:
	ld a,0F5H
	ld b,7
	call VDP_SetRegister

	call MSXMidi_CheckOverrun
	ld ix,KeyMidi_instance
	call KeyMidi_Scan
	call MidiIn_ProcessMessages
	ld ix,MSXMidi_instance
	call MidiIn_ProcessMessages
	ld ix,Clock_60Hz
	call Clock_Update
	call Channels_Update

	ld a,0F4H
	ld b,7
	call VDP_SetRegister
	ret
