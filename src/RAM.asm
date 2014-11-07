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
	call RAM_DetectPage0
	ld hl,RAM_insufficientRAM
	call nc,System_ThrowExceptionWithMessage
	di
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
	call RAM_DetectPage2
	ld hl,RAM_insufficientRAM
	call nc,System_ThrowExceptionWithMessage
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
; ix = this
; f <- c: found
; a <- slot
;
RAM_DetectPage0:
	ld hl,RAM_MatchPage0
	call Memory_SearchSlots
	ret

;
; ix = this
; f <- c: found
; a <- slot
;
RAM_DetectPage2:
	ld hl,RAM_MatchPage2
	call Memory_SearchSlots
	ret

;
; Check slot for RAM in page 0.
;
; a = slot ID
; f <- c: found
; Modifies: af, bc, de, hl, iy
;
RAM_MatchPage0:
	ld ixl,a
	ld hl,1H
	call RAM_Match
	ret nc
	ld a,ixl
	ld hl,2000H
	call RAM_Match
	ret

;
; Check slot for RAM in page 2.
;
; a = slot ID
; f <- c: found
; Modifies: af, bc, de, hl, iy
;
RAM_MatchPage2:
	ld ixl,a
	ld hl,8001H
	call RAM_Match
	ret nc
	ld a,ixl
	ld hl,0A000H
	call RAM_Match
	ret

;
; Check slot for RAM.
;
; a = slot ID
; hl = test address
; f <- c: found
; Modifies: af, bc, de, hl, iy
;
RAM_Match:
	ld iyl,a
	call Memory_ReadSlot
	ld iyh,a
	cpl
	ld c,a
	ld a,iyl
	call Memory_WriteSlot
	ld a,iyl
	call Memory_ReadSlot
	cpl
	xor iyh
	ret nz
	ld c,iyh
	ld a,iyl
	call Memory_WriteSlot
	scf
	ret


;
RAM_insufficientTPA:
	db "Insufficient TPA memory.",0

;
RAM_insufficientRAM:
	db "Insufficient RAM.",0
