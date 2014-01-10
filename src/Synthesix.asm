Synthesix_Main:
	call System_EnableROMInPage2
	call RAM_Init

	call UI_Init
	call Keys_Init
	call PSG_Init
	call SCC_Init
	call Channel_New
	ld (Channel_channels + 0),ix

	call Math_UnitTest

	call setmidi

	ld hl,Synthesix_Interrupt
	call System_InstallTIMIHook

	ld a,(JIFFY)
	ld (Synthesix_lastJiffy),a

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
	call Synthesix_UpdateChannels

	ld a,0F4H
	ld b,7
	call VDP_SetRegister
	ret

Synthesix_UpdateChannels:
	ld a,(Synthesix_lastJiffy)
	ld b,a
	ld a,(JIFFY)
	ld (Synthesix_lastJiffy),a
	sub b
	ret z
	ld b,a
	ld ix,(Channel_channels + 0)
	jp Channel_Update

;
; Variables in RAM
;
	SECTION RAM

Synthesix_lastJiffy:
	db 0

	ENDS
