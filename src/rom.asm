;
; Synthesix
;
; MIDI synthesizer for MSX
;

	org 4000H

	db "AB"
	dw Synthesix_Main
	dw 0, 0, 0, 0, 0, 0

	INCLUDE "utils.asm"
	INCLUDE "synthesix.asm"
	INCLUDE "keys.asm"
	INCLUDE "psg.asm"
	INCLUDE "scc.asm"

RAM_Init:
	ld hl,RAM_dataStart
	ld de,RAM_dataStartAddress
	ld bc,RAM_dataSize
	ldir
	ret

RAM_dataStart:
	include "ram.symbol"
	incbin "ram.bin"
RAM_dataSize: equ $ - RAM_dataStart

	ds 0C000H - $
