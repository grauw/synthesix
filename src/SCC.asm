;
; An SCC sound chip
;
SCC_BASE: equ 9800H
SCC_BASE_MSB: equ SCC_BASE / 100H
SCC_WAVE_1: equ 00H
SCC_WAVE_2: equ 20H
SCC_WAVE_3: equ 40H
SCC_WAVE_4_5: equ 60H
SCC_FREQUENCY_1: equ 80H
SCC_FREQUENCY_2: equ 82H
SCC_FREQUENCY_3: equ 84H
SCC_FREQUENCY_4: equ 86H
SCC_FREQUENCY_5: equ 88H
SCC_AMPLITUDE_1: equ 8AH
SCC_AMPLITUDE_2: equ 8BH
SCC_AMPLITUDE_3: equ 8CH
SCC_AMPLITUDE_4: equ 8DH
SCC_AMPLITUDE_5: equ 8EH
SCC_MIXER: equ 8FH
SCC_DEFORMATION: equ 0E0H

SCC_MAX_VOICES: equ 4

SCC: MACRO
	slot:
		db 0
	preparedSlot:
		ds 4
	mixerCopy:
		db 0
	voices:
		ds SCC_MAX_VOICES * 2
	size:
	ENDM

	dw SCC.size
SCC_class: SCC

; ix <- new object
SCC_New:
	push af
	ld iy,SCC_class
	call Class_NewUpper
	pop af
	jp SCC_Constructor

; ix = this
; ix <- this
SCC_Constructor:
	call SCC_Detect
	call nc,System_ThrowException

	ld (ix + SCC.slot),a
	push af
	call Memory_PrepareSlotPage2
	ld (ix + SCC.preparedSlot),b
	ld (ix + SCC.preparedSlot + 1),c
	ld (ix + SCC.preparedSlot + 2),d
	ld (ix + SCC.preparedSlot + 3),e
	pop af

	call Memory_GetSlotPage2
	push af
	ld a,(ix + SCC.slot)
	call Memory_SetSlotPage2

	ld a,ROM_SCCBank
	ld (ROM_bank8000),a
	ld (ROM_BANK_8000_CHANGE),a

	ld a,0
	ld (SCC_BASE + SCC_AMPLITUDE_1),a
	ld (SCC_BASE + SCC_AMPLITUDE_2),a
	ld (SCC_BASE + SCC_AMPLITUDE_3),a
	ld (SCC_BASE + SCC_AMPLITUDE_4),a
	ld (SCC_BASE + SCC_AMPLITUDE_5),a
	ld a,00011111B
	ld (SCC_BASE + SCC_MIXER),a
	ld (ix + SCC.mixerCopy),a

	pop af
	call Memory_SetSlotPage2

	push ix
	ld b,SCC_WAVE_1
	ld c,SCC_FREQUENCY_1
	ld d,SCC_AMPLITUDE_1
	call SCCVoice_New
	pop ix
	ld (ix + SCC.voices),e
	ld (ix + SCC.voices + 1),d

	push ix
	ld b,SCC_WAVE_2
	ld c,SCC_FREQUENCY_2
	ld d,SCC_AMPLITUDE_2
	call SCCVoice_New
	pop ix
	ld (ix + SCC.voices + 2),e
	ld (ix + SCC.voices + 3),d

	push ix
	ld b,SCC_WAVE_3
	ld c,SCC_FREQUENCY_3
	ld d,SCC_AMPLITUDE_3
	call SCCVoice_New
	pop ix
	ld (ix + SCC.voices + 4),e
	ld (ix + SCC.voices + 5),d

	push ix
	ld b,SCC_WAVE_4_5
	ld c,SCC_FREQUENCY_4
	ld d,SCC_AMPLITUDE_4
	call SCCVoice_New
	pop ix
	ld (ix + SCC.voices + 6),e
	ld (ix + SCC.voices + 7),d

	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Clock_60HzLate
	ld hl,SCC_UpdateLate
	call Clock_AddListener
	pop ix
	ret

SCC_UpdateLate:
	ld b,(ix + SCC.preparedSlot)
	ld c,(ix + SCC.preparedSlot + 1)
	ld d,(ix + SCC.preparedSlot + 2)
	ld e,(ix + SCC.preparedSlot + 3)
	call Memory_SetPreparedSlotPage2
	exx

	push ix
	pop iy
	REPT SCC_MAX_VOICES, ?voice
	ld e,(iy + SCC.voices + 2 * ?voice)
	ld d,(iy + SCC.voices + 2 * ?voice + 1)
	ld ixl,e
	ld ixh,d
	call SCCVoice_Apply
	ENDM

	exx
	call Memory_SetPreparedSlotPage2
	ret

; ix = this
; a = voice number
; hl <- voice
; Modifies: bc, ix
SCC_GetVoice:
	cp SCC_MAX_VOICES
	call nc,System_ThrowException
	add a,a
	ld c,a
	ld b,0
	add ix,bc
	ld l,(ix + SCC.voices)
	ld h,(ix + SCC.voices + 1)
	ret

; iy = this
; a = voice number
; iy <- voice
; Modifies: bc, ix
SCC_GetVoice_IY:
	cp SCC_MAX_VOICES
	call nc,System_ThrowException
	add a,a
	ld c,a
	ld b,0
	add iy,bc
	ld c,(iy + SCC.voices)
	ld b,(iy + SCC.voices + 1)
	ld iyl,c
	ld iyh,b
	ret

; ix = this
; ix <- voice
; Modifies: de
SCC_GetFreeVoice:
	push ix
	pop iy
	REPT SCC_MAX_VOICES, ?voice
	ld e,(iy + SCC.voices + ?voice * 2)
	ld d,(iy + SCC.voices + ?voice * 2 + 1)
	ld ixl,e
	ld ixh,d
	call SCCVoice_IsBound
	jp z,SCCVoice_Bind
	ENDM
	call System_ThrowException

;
; Detect SCC
;
; ix = this
; f <- c: found
; a <- slot
;
SCC_Detect:
	ld hl,SCC_MatchSlot
	call Memory_SearchSlots
	ret

;
; Check slot for SCC
;
; ix = this
; a = slot id
; f <- c: found
;
SCC_MatchSlot: PROC
	ex af,af'
	call Memory_GetSlotPage2
	push af
	ex af,af'
	call Memory_SetSlotPage2

	ld a,(9000H)
	ld d,a
	ld a,3FH
	ld (9000H),a
	ld hl,9800H
	ld e,(hl)
	xor a
	ld (hl),a
	ld a,(hl)
	or a
	jr nz,NoSCC
	dec a
	ld (hl),a
	ld a,(hl)
	inc a
	jr nz,NoSCC
	ld a,(9000H)
	cp 3FH
	jr z,NoSCC
	xor a
	jr Found
NoSCC:
	ld (hl),e
	ld a,d
	ld (9000H),a
	pop af
	call Memory_SetSlotPage2
	and a
	ret
Found:
	pop af
	call Memory_SetSlotPage2
	scf
	ret
	ENDP
