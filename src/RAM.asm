;
; Copy RAM initialisation data from ROM to RAM.
; These values are defined in the RAM section and copied on boot.
;
RAM_Init:
	call RAM_InitPage3
	call RAM_InitPage2
	call RAM_InitPage0
	ret

	SECTION ROM_BANK0

;
RAM_InitPage0:
	di
	call Memory_GetSlotPage3
	ld h,00H
	call Memory_SetSlot
	ld a,ROM_CodeBank3
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,6000H + DEBUG  ; skip 1st byte just to avoid breakpoint
	ld de,0000H + DEBUG
	ld bc,2000H - DEBUG
	ldir
	ld a,ROM_CodeBank4
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,6000H
	ld de,2000H
	ld bc,2000H
	ldir
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ei
	ret

	ENDS

;
RAM_InitPage2:
	call Memory_GetSlotPage3
	ld h,80H
	call Memory_SetSlot
	ret

	SECTION ROM_BANK0

;
RAM_InitPage3:
	and a
	ld hl,0
	add hl,sp
	ld bc,RAM_endAddress + 100H
	sbc hl,bc
	ld hl,RAM_insufficientTPA
	call c,System_ThrowExceptionWithMessage

	ld a,ROM_RAMInitBank
	ld (ROM_BANK_6000_CHANGE),a
	ld hl,RAM_sourceAddress
	ld de,RAM_startAddress
	ld bc,RAM_endAddress - RAM_startAddress
	ldir
	ld a,ROM_CodeBank2
	ld (ROM_BANK_6000_CHANGE),a
	ret

	ENDS

;
RAM_RestorePage0:
	ld a,(EXPTBL)
	ld h,00H
	call Memory_SetSlot
	ret


;
RAM_insufficientTPA:
	db "Insufficient TPA memory.",0
