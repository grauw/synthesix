; Konami SCC mapper
ROM_BANK_0_CHANGE: equ 5000H
ROM_BANK_1_CHANGE: equ 7000H
ROM_BANK_2_CHANGE: equ 9000H
ROM_BANK_3_CHANGE: equ 0B000H

SCC_WAVEFORM_1: equ 9800H
SCC_WAVEFORM_2: equ 9820H
SCC_WAVEFORM_3: equ 9840H
SCC_WAVEFORM_4_5: equ 9860H
SCC_FREQUENCY_1: equ 9880H
SCC_FREQUENCY_2: equ 9882H
SCC_FREQUENCY_3: equ 9884H
SCC_FREQUENCY_4: equ 9886H
SCC_FREQUENCY_5: equ 9888H
SCC_VOLUME_1: equ 988AH
SCC_VOLUME_2: equ 988BH
SCC_VOLUME_3: equ 988CH
SCC_VOLUME_4: equ 988DH
SCC_VOLUME_5: equ 988EH
SCC_ON_OFF: equ 988FH
SCC_DEFORMATION: equ 98E0H

scc_init:
	in a,(PPI_PORT_A)
	and 00001100B
	rrca
	rrca
	ld hl,EXPTBL + 1
	or (hl)
	jp p,scc_init_no_subslot
	ld b,a
	ld a,(SLTTBL + 1)
	and 00001100B
	or b
scc_init_no_subslot:
	ld h,80H
	call ENASLT
	ld a,3FH
	ld (ROM_BANK_2_CHANGE),a
	ret

; a = note number (0-127)
; b = velocity (0-127)
; c = channel (0-4)
scc_note_on:
	; de = frequency
	ld h,psg_frequency_table / 100H
	ld l,a
	sla l
	ld e,(hl)
	inc hl
	ld d,(hl)

	; a = volume
	ld a,b
	rrca
	rrca
	rrca

	ld hl,SCC_ON_OFF
	ld (SCC_FREQUENCY_1),de
	ld (SCC_VOLUME_1),a
	ld (hl),1
	ret

; c = channel (0-4)
scc_note_off:
	ld hl,SCC_ON_OFF
	ld (hl),0
	ret

; a = program number (0-127)
scc_program_change:
	sla a
	ld h,scc_preset_programs / 100H
	ld l,a
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	call scc_load_waveform
	ret

scc_load_waveform:
	ld de,SCC_WAVEFORM_1
	ld bc,32
	ldir
	ret

;
;
;

	ALIGN 100H
scc_preset_programs:
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave
	dw square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, square_wave, init_wave

square_wave:
	db 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH, 7FH
	db 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H, 80H

init_wave:
	ds 32, 0
