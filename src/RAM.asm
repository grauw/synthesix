;
; All RAM data is defined inside the marked section below
; These values are copied to RAM during program initialisation
;

RAM_Init:
	ld hl,RAM_dataStart
	ld de,RAM_dataStartAddress
	ld bc,RAM_dataSize
	ldir
	ret

RAM_dataStart:
	org 0C000H
RAM_dataStartAddress:
;=================================================================

Keys_lastScan:
	ds 11,0

Keys_velocity:
	dw 7F00H

SCC_mixerCopy:
	db 0

; The initial ROM banks
; Stored as words that include the bank select register address
; Example: ld hl,(ROM_bank3) / ld (hl),l
ROM_bank1:
	dw 5000H
ROM_bank2:
	dw 7001H
ROM_bank3:
	dw 9002H
ROM_bank4:
	dw 0B003H

; max 5 voices / pool
VoicePool_voicePool1:
VoicePool:
VoicePool_mono: equ $ - VoicePool
	db -1;
VoicePool_notes: equ $ - VoicePool
	db -1, -1, -1, -1, -1
VoicePool_voices: equ $ - VoicePool
	dw SCC_voice1, SCC_voice2, SCC_voice3, SCC_voice4, 0

;=================================================================
RAM_dataSize: equ $ - RAM_dataStartAddress
	org RAM_dataStart + RAM_dataSize
