; BIOS defines
ENASLT: equ 24H
INITXT: equ 6CH
CHPUT: equ 0A2H
SNSMAT: equ 141H
EXPTBL: equ 0FCC1H
SLTTBL: equ 0FCC5H
PPI_PORT_A: equ 0A8H


ALIGN: MACRO boundary
	ds boundary - 1 - ($ - 1) % boundary
	ENDM

println:
	call print
	ld hl,crlf
	call print
	ret

print:
	ld a,(hl)
	and a
	ret z
	call CHPUT
	inc hl
	jp print

print_hex_hl:
	push hl
	ld a,h
	call print_hex_a
	pop hl
	ld a,l
	call print_hex_a
	ret

print_hex_a:
	push af
	and 0F0H
	rrca
	rrca
	rrca
	rrca
	call print_hex
	pop af
	and 0FH
	call print_hex
	ret

print_hex:
	ld hl,hex_numbers
	ld b,0
	ld c,a
	add hl,bc
	ld a,(hl)
	call CHPUT
	ret

stop:
	halt
	jp stop

throw_exception:
	ld hl,exception_message
	call print
	pop hl
	call print_hex_hl
	jp stop

exception_message:
	db "An exception occurred on address: ", 0

hex_numbers:
	db "0123456789ABCDEF"

crlf:
	db "\r\n", 0

