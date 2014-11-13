;
; Top-level Synthesix program class
;
; Contains references to top-level objects, the main loop and the core ISR.
;
Synthesix: MACRO
	scc:
		dw 0
	program:
		dw 0
	lastSpeedMeasurementStart:
		dw 0
	lastSpeedMeasurement:
		dw 0
	ENDM

;
Synthesix_Main:
	call VDP_GetVersion
	cp 1
	ret c

;	call System_EnableTurbo

	ld ix,Heap_heap
	call Heap_Constructor
	ld ix,Heap_heapUpper
	call Heap_Constructor

	call Memory_UnitTest
	call Heap_UnitTest
	call Math_UnitTest
	call ArrayList_UnitTest

	ld ix,Synthesix_instance
	call Synthesix_Constructor
	call Synthesix_EnterMainLoop

	ld iy,(EXPTBL-1)
	ld ix,KILBUF
	call CALSLT
	ret

; ix = this
; ix <- this
Synthesix_Constructor:
	push ix
	ld ix,KeyMidi_instance
	call KeyMidi_Constructor
	call Channels_Init
	call PSG_Init
	call SCC_New
	ld (Synthesix_instance.scc),ix
	ld hl,Channel_channels.0
	call Program_New
	ld (Synthesix_instance.program),ix

	call UI_Init

	call Interrupt_Init
	pop ix
	ret

; ix = this
Synthesix_EnterMainLoop:
	call Interrupt_EnableInterruptHandler
	ld ix,PhilipsMidi_instance
	call PhilipsMidi_Install
	ld ix,MSXMidi_instance
	call MSXMidi_Install
	ld ix,SFGMidi_instance
	call SFGMidi_Install
	ld hl,Synthesix_Interrupt
	call Interrupt_InstallTIMIHook

	call Synthesix_MainLoop

	ld ix,SFGMidi_instance
	call SFGMidi_Uninstall
	ld ix,MSXMidi_instance
	call MSXMidi_Uninstall
	ld ix,PhilipsMidi_instance
	call PhilipsMidi_Uninstall
	call Interrupt_RestoreTIMIHook
	call Interrupt_DisableInterruptHandler
	ret

Synthesix_MainLoop:
	call UI_Update
	ld ix,KeyMidi_instance
	bit 0,(ix + KeyMidi.quit)
	jp z,Synthesix_MainLoop
	ret

Synthesix_Interrupt:
	call Synthesix_StartSpeedMeasurement

	ld ix,MSXMidi_instance
	call MSXMidi_CheckOverrun
	ld ix,SFGMidi_instance
	call SFGMidi_CheckOverrun
	ld ix,KeyMidi_instance
	call KeyMidi_Scan
	call MidiIn_ProcessMessages
	ld ix,AudioMidi_instance
	call AudioMidi_Scan
	call MidiIn_ProcessMessages
	ld ix,PhilipsMidi_instance
	call MidiIn_ProcessMessages
	ld ix,MSXMidi_instance
	call MidiIn_ProcessMessages
	ld ix,SFGMidi_instance
	call MidiIn_ProcessMessages
	ld ix,Updater_60Hz
	call Updater_Update
	ld ix,Updater_60HzLate
	call Updater_Update

	call Synthesix_EndSpeedMeasurement
	ret

Synthesix_StartSpeedMeasurement:
	ld a,0F5H
	call VDP_SetColor
	call Synthesix_GetHighResTimerValue
	ld (Synthesix_instance.lastSpeedMeasurementStart),hl
	ret

Synthesix_EndSpeedMeasurement:
	call Synthesix_GetHighResTimerValue
	ld de,(Synthesix_instance.lastSpeedMeasurementStart)
	and a
	sbc hl,de
	ld (Synthesix_instance.lastSpeedMeasurement),hl
	ld a,0F4H
	call VDP_SetColor
	ret

; hl <- current timer value, in 14 cycle increments
; Modifies: af, hl
Synthesix_GetHighResTimerValue:
	in a,(0E7H)
	ld h,a
	in a,(0E6H)
	ld l,a
	in a,(0E7H)
	cp h
	ret z
	bit 7,l
	ret nz
	ld h,a
	ret

;
	SECTION RAM

Synthesix_instance: Synthesix

	ENDS
