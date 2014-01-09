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
	call System_OldTimiHook
	ld a,(Synthesix_inInterrupt)
	and a
	ret nz
	dec a
	ld (Synthesix_inInterrupt),a
	ld a,0F5H
	out (VDP_PORT_1),a
	ld a,VDP_REGISTER | 7
	out (VDP_PORT_1),a
	ei

	call Keys_Scan
	call Synthesix_UpdateChannels

	di
	ld a,0F4H
	out (VDP_PORT_1),a
	ld a,VDP_REGISTER | 7
	out (VDP_PORT_1),a
	xor a
	ld (Synthesix_inInterrupt),a
	ret

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

;
; Variables in RAM
;
	SECTION RAM

Synthesix_lastJiffy:
	db 0

Synthesix_channel1:
	dw 0

Synthesix_inInterrupt:
	db 0

	ENDS
