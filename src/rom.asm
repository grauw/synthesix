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
	INCLUDE "ram.asm"

	ds 0C000H - $
