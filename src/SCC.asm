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
	mixerCopy:
		db 0
	voices:
		ds SCC_MAX_VOICES * 2
	size:
	ENDM

	dw SCC.size
SCC_class: SCC

; a = slot
; ix <- this
SCC_New:
	push af
	ld iy,SCC_class
	call Class_NewUpper
	pop af
	jp SCC_Constructor

; ix = this
; a = slot
; ix <- this
SCC_Constructor:
	ld (ix + SCC.slot),a

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
	ld a,(ix + SCC.slot)
	ld b,SCC_WAVE_1
	ld c,SCC_FREQUENCY_1
	ld d,SCC_AMPLITUDE_1
	call SCCVoice_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCC.voices),e
	ld (ix + SCC.voices + 1),d

	push ix
	ld a,(ix + SCC.slot)
	ld b,SCC_WAVE_2
	ld c,SCC_FREQUENCY_2
	ld d,SCC_AMPLITUDE_2
	call SCCVoice_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCC.voices + 2),e
	ld (ix + SCC.voices + 3),d

	push ix
	ld a,(ix + SCC.slot)
	ld b,SCC_WAVE_3
	ld c,SCC_FREQUENCY_3
	ld d,SCC_AMPLITUDE_3
	call SCCVoice_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCC.voices + 4),e
	ld (ix + SCC.voices + 5),d

	push ix
	ld a,(ix + SCC.slot)
	ld b,SCC_WAVE_4_5
	ld c,SCC_FREQUENCY_4
	ld d,SCC_AMPLITUDE_4
	call SCCVoice_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCC.voices + 6),e
	ld (ix + SCC.voices + 7),d
	ret

; ix = this
; a = voice number
; hl <- voice
; Modifies: bc, ix
SCC_GetVoice:
	cp SCC_MAX_VOICES
	jp nc,System_ThrowException
	add a,a
	ld c,a
	ld b,0
	add ix,bc
	ld l,(ix + SCC.voices)
	ld h,(ix + SCC.voices + 1)
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
