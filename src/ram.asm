;
; All RAM data is defined below
; These values are copied to RAM during program initialisation
;

	org 0C000H
RAM_dataStartAddress:

Keys_lastScan:
	ds 11,0

Keys_velocity:
	dw 7F00H

SCC_mixerCopy:
	db 0
