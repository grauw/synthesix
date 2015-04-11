;
; Top-level application program class
;
; Contains references to top-level objects, the main loop and the core ISR.
;
Application: MACRO
	scc:
		dw 0
	sccVoiceBank:
		dw 0
	program:
		dw 0
	lastSpeedMeasurementStart:
		dw 0
	lastSpeedMeasurement:
		dw 0
	ENDM

;
Application_Main:
	call VDP_GetVersion
	cp 1
	ret c

;	call System_EnableTurbo

	ld ix,Heap_main
	call Heap_Constructor
	ld ix,Heap_upper
	call Heap_Constructor

	call MemoryTest_Test
	call HeapTest_Test
	call MathTest_Test
	call ArrayListTest_Test

	ld ix,Application_instance
	call Application_Constructor
	call Application_EnterMainLoop

	ld iy,(EXPTBL-1)
	ld ix,KILBUF
	call CALSLT
	ret

; ix = this
; ix <- this
Application_Constructor:
	push ix
	ld ix,KeyMidi_instance
	call KeyMidi_Constructor
	call Channels_Init
	call PSG_Init
	call SCC_New
	ld (Application_instance.scc),ix
	ld hl,Channel_channels.0
	call Program_New
	ld (Application_instance.program),ix

	call UI_Init

	call Interrupt_Init
	pop ix
	ret

; ix = this
Application_EnterMainLoop:
	call Interrupt_EnableInterruptHandler
	ld ix,PhilipsMidi_instance
	call PhilipsMidi_Install
	ld ix,MSXMidi_instance
	call MSXMidi_Install
	ld ix,SFGMidi_instance
	call SFGMidi_Install
	ld hl,Application_Interrupt
	call Interrupt_InstallTIMIHook

	call Application_MainLoop

	ld ix,SFGMidi_instance
	call SFGMidi_Uninstall
	ld ix,MSXMidi_instance
	call MSXMidi_Uninstall
	ld ix,PhilipsMidi_instance
	call PhilipsMidi_Uninstall
	call Interrupt_RestoreTIMIHook
	call Interrupt_DisableInterruptHandler
	ret

Application_MainLoop:
	call UI_Update
	ld ix,KeyMidi_instance
	bit 0,(ix + KeyMidi.quit)
	jp z,Application_MainLoop
	ret

Application_Interrupt:
	call Application_StartSpeedMeasurement

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

	call Application_EndSpeedMeasurement
	ret

Application_StartSpeedMeasurement:
	ld a,0F5H
	call VDP_SetColor
	call System_GetHighResTimerValue
	ld (Application_instance.lastSpeedMeasurementStart),hl
	ret

Application_EndSpeedMeasurement:
	call System_GetHighResTimerValue
	ld de,(Application_instance.lastSpeedMeasurementStart)
	and a
	sbc hl,de
	ld (Application_instance.lastSpeedMeasurement),hl
	ld a,0F4H
	call VDP_SetColor
	ret

;
	SECTION RAM

Application_instance: Application

	ENDS
