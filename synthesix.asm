;
; Synthesix
;
; MIDI synthesizer for MSX
;

	org 4000H

	db "AB"
	dw main
	dw 0, 0, 0, 0, 0, 0

	INCLUDE "utils.asm"
	INCLUDE "main.asm"
	INCLUDE "keys.asm"
	INCLUDE "psg.asm"
	INCLUDE "scc.asm"

	ds 0C000H - $
