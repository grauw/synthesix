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
Keys_modulation:
	dw 0000H

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

Synthesix_channel1:
	dw 0

SCC_voice1:
	db SCC_WAVE_1
	db SCC_FREQUENCY_1
	db SCC_LEVEL_1
	db 00000001B
	db 11111110B
	db 0

SCC_voice2:
	db SCC_WAVE_2
	db SCC_FREQUENCY_2
	db SCC_LEVEL_2
	db 00000010B
	db 11111101B
	db 0

SCC_voice3:
	db SCC_WAVE_3
	db SCC_FREQUENCY_3
	db SCC_LEVEL_3
	db 00000100B
	db 11111011B
	db 0

SCC_voice4:
	db SCC_WAVE_4_5
	db SCC_FREQUENCY_4
	db SCC_LEVEL_4
	db 00001000B
	db 11110111B
	db 0

;=================================================================
; HEAP MUST BE THE LAST THING DEFINED HERE
Heap_heapPosition:
	dw Heap_start
Heap_heapCapacity:
	dw 1000H
Heap_start:
;
;=================================================================
RAM_dataSize: equ $ - RAM_dataStartAddress
	org RAM_dataStart + RAM_dataSize
