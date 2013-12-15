;
; Synthesix
;
; MIDI synthesizer for MSX
;

	org 4000H

	db "AB"
	dw Synthesix_Main
	dw 0, 0, 0, 0, 0, 0

	INCLUDE "Synthesix.asm"
	INCLUDE "Utils.asm"
	INCLUDE "Math.asm"
	INCLUDE "Keys.asm"
	INCLUDE "Channel.asm"
	INCLUDE "VoicePool.asm"
	INCLUDE "PSG.asm"
	INCLUDE "SCC.asm"
	INCLUDE "RAM.asm"

	ds 0A000H - $  ; must be aligned to 2000H
Math_multiply7x7Table:
	INCLUDE "multtable.asm"

	ds 0C000H - $
