;
; SCC phase reset test program
; Press a key to re-set frequency, notice how phase change audibly
;
	org 4000H
	db "AB"
	dw Main, 0, 0, 0, 0, 0, 0
Main:
	ld a,1  ; SCC slot nr
	ld h,80H
	call 24H  ; ENASLT
	ld a,3FH  ; scc bank
	ld (9000H),a
	ld hl,saw
	ld de,9800H
	ld bc,32
	ldir  ; set wave 1
	ld hl,saw
	ld bc,32
	ldir  ; set wave 2
	ld a,00000011B  ; enable channels 1 & 2
	ld (988FH),a
	ld hl,427  ; play C3 on channels 1 & 2
	ld (9880H),hl
	ld (9882H),hl
	ld a,15  ; set max volume on channels 1 & 2
	ld (988AH),a
	ld (988BH),a
Loop:
	call 9FH  ; CHGET
	ld hl,427
	ld (9882H),hl
	jp Loop

saw: db 04H, 0CH, 14H, 1CH, 25H, 2DH, 35H, 3DH, 45H, 4EH, 56H, 5EH, 66H, 6FH, 77H, 7FH
	db 80H, 88H, 90H, 99H, 0A1H, 0A9H, 0B1H, 0BAH, 0C2H, 0CAH, 0D2H, 0DAH, 0E3H, 0EBH, 0F3H, 0FBH

	ds 06000H - $
