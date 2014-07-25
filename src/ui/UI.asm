;
; UI system
;

	INCLUDE "Font.asm"
	INCLUDE "UIBuffer.asm"
	INCLUDE "UIFocus.asm"
	INCLUDE "UIValue.asm"
	INCLUDE "UIInput.asm"
	INCLUDE "UIOutput.asm"
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
	call VDP_EnableBlink
	call Font_Install
	call UISynthesix_New
	ld (UI_root),ix
	call UISynthesix_Update
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
