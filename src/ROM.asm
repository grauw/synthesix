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
	INCLUDE "System.asm"
	INCLUDE "Math.asm"
	INCLUDE "Heap.asm"
	INCLUDE "Class.asm"
	INCLUDE "Keys.asm"
	INCLUDE "Channel.asm"
	INCLUDE "Patch.asm"
	INCLUDE "SCCPatch.asm"
	INCLUDE "PSG.asm"
	INCLUDE "SCC.asm"
	INCLUDE "SCCVoice.asm"

	IF $ > 8000H
		.ERROR Code exceeds 8000H.
	ENDIF

	INCLUDE "RAM.asm"

	IF $ > 0A000H
		.ERROR Data exceeds A000H.
	ENDIF

	ds 0A000H - $  ; must be aligned to 2000H
Math_multiply7x7Table:
	INCLUDE "multtable.asm"

	ds 0C000H - $
