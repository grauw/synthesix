;
; UI system
;

	INCLUDE "Font.asm"
	INCLUDE "UIBuffer.asm"
	INCLUDE "UISynthesix.asm"
	INCLUDE "UIKeyboard.asm"
	INCLUDE "PatchEditor.asm"
	INCLUDE "ValueView.asm"
	INCLUDE "InputView.asm"
	INCLUDE "OutputView.asm"
	INCLUDE "PatchEditorModuleView.asm"
	INCLUDE "PatchEditorGridView.asm"
	INCLUDE "ModuleView.asm"
	INCLUDE "HorizontalScrollBarView.asm"

UI_Init:
	call VDP_InitScreen0
	call VDP_Enable212Lines
	call VDP_Enable60Hz
	call VDP_EnableBlink
	ld hl,UI_palette
	call VDP_SetPalette
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
UI_palette:
	dw 000H, 000H, 500H, 733H  ; format: GRB
	dw 024H, 024H, 151H, 627H
	dw 070H, 373H, 661H, 663H
	dw 411H, 265H, 444H, 777H

	SECTION RAM

UI_root:
	dw 0

	ENDS
