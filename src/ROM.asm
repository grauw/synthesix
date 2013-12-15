;
; Synthesix
;
; MIDI synthesizer for MSX
;

	org 4000H

	db "AB"
	dw Synthesix_Main
	dw 0, 0, 0, 0, 0, 0

	INCLUDE "Utils.asm"
	INCLUDE "Synthesix.asm"
	INCLUDE "Keys.asm"
	INCLUDE "Channel.asm"
	INCLUDE "PSG.asm"
	INCLUDE "SCC.asm"
	INCLUDE "RAM.asm"

	ds 0C000H - $
