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

;=================================================================
RAM_dataSize: equ $ - RAM_dataStartAddress
	org RAM_dataStart + RAM_dataSize
