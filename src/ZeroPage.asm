;
; The zero page is the 100H header in RAM at address 0.
;
; This contains some support and interrupt handling routines.
; It is similar to the zero page in DOS2.
;
ZeroPage_RST00:
	jp 0
	ds 2  ; reserved
ZeroPage_BDOS:
	jp 0
ZeroPage_RST08:
	di  ; not used
	halt
	di
	halt
ZeroPage_RDSLT:
	jp ZeroPage_RDSLTWrapper
	nop
ZeroPage_RST10:
	di  ; not used
	halt
	di
	halt
ZeroPage_WRSLT:
	jp ZeroPage_WRSLTWrapper
	nop
ZeroPage_RST18:
	di  ; not used
	halt
	di
	halt
ZeroPage_CALSLT:
	jp ZeroPage_CALSLTWrapper
	nop
ZeroPage_RST20:
	di  ; not used
	halt
	di
	halt
ZeroPage_ENASLT:
	jp ZeroPage_ENASLTWrapper
	nop
ZeroPage_RST28:
	di  ; not used
	halt
	di
	halt
	di  ; not used
	halt
	di
	halt
ZeroPage_RST30:
ZeroPage_CALLF:
	jp ZeroPage_CALLFWrapper
	nop
	di  ; not used
	halt
	di
	halt
ZeroPage_RST38:
	push af  ; minimal implementation
	in a,(99H)
	pop af
	ei
	ret

ZeroPage_RDSLTWrapper:
	ex af,af'
	push af
	ex af,af'
	push hl
	di
	call Memory_ReadSlot
	pop hl
	ex af,af'
	pop af
	ex af,af'
	ret

ZeroPage_WRSLTWrapper:
	ex af,af'
	push af
	ex af,af'
	push de
	push hl
	ld c,e
	di
	call Memory_WriteSlot
	pop hl
	pop de
	ex af,af'
	pop af
	ex af,af'
	ret

ZeroPage_ENASLTWrapper:
	di
	jp Memory_SetSlot

ZeroPage_CALSLTWrapper:
	jp Memory_CallSlot

ZeroPage_CALLFWrapper:
	exx
	ex af,af'
	pop hl
	ld a,(hl)
	ld iyh,a
	inc hl
	ld a,(hl)
	ld ixl,a
	inc hl
	ld a,(hl)
	ld ixh,a
	inc hl
	push hl
	ex af,af'
	exx
	jp Memory_CallSlot

	ds 100H - $
