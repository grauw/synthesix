;
; UI system
;

	INCLUDE "Font.asm"
	INCLUDE "UINode.asm"
	INCLUDE "UIValue.asm"
	INCLUDE "UISynthesix.asm"
	INCLUDE "UIProgram.asm"
	INCLUDE "UIChannel.asm"
	INCLUDE "UIControllerBank.asm"
	INCLUDE "UINote.asm"
	INCLUDE "UIKeyboard.asm"
	INCLUDE "UISCCVoice.asm"

UI_Init:
	call VDP_InitScreen0
	call VDP_Enable212Lines
	call VDP_Enable60Hz
	call Font_Install
	ld iy,UISynthesix_class
	call Class_New
	ld (UI_root),ix
	call UISynthesix_Constructor
	call UISynthesix_Draw
	ret

UI_Update:
	ld ix,(UI_root)
	call UISynthesix_Update
	ret

;
	SECTION RAM

UI_root:
	dw 0

	ENDS
