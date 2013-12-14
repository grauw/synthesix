main:
	call INITXT
	ld hl,hello_message
	call print

	call ram_init
	call keys_init
	call psg_init
	call scc_init

	ld hl,saw_wave
	call scc_load_waveform

main_loop:
	halt
	call keys_scan
	jp main_loop

ram_init:
	ld hl,ram_data_start
	ld de,ram_data_start_address
	ld bc,ram_data_size
	ldir
	ret

hello_message:
	db "Synthesix\r\n\nMIDI synthesizer for MSX\r\n", 0

ram_data_start:
	include "ram.symbol"
	incbin "ram.bin"
ram_data_size: equ $ - ram_data_start
