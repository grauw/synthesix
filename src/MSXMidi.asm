;
; MSX-MIDI driver
;
; MSX-MIDI uses the 8251 UART and the 8253 timer.
; See http://map.grauw.nl/resources/midi/msx-midi.php for documentation.
;
;
;	MIDI interface I/O
;
setcart		equ	0e2h	;MIDI cartridge setting
UARTsend	equ	0e8h	;8251 data transmit
UARTrecv	equ	0e8h	;8251 data receive
UARTcmd		equ	0e9h	;8251 command/mode register
UARTstat	equ	0e9h	;8251 status
tm_int		equ	0eah	;timer interrupt flag off
timer0		equ	0ech	;8253 counter #0
timer2		equ	0eeh	;8253 counter #2
tm_cmd		equ	0efh	;8253 command

;
;	Set hooks
;
setmidi:
	call	chkmidi		;Have I MIDI interface ?
	jp	c,nomidi	; No
	di
	jr	z,setho2	;MIDI interface is not built in
;
;	Setting for built-in MIDI interface
;
	ld	hl,H.MDTM	;save hook (8253 timer)
	ld	de,hoksvt	;set address to save area
	push	hl		;save hook address
	call	copy5		;copy old hook
	ld	hl,hokmdt	;set address to new hook data
	pop	de		;get hook address
	call	copy5		;set new hook
;
	ld	hl,H.MDIN       ;save hook (MIDI IN)
	ld	de,hoksvt+5	;set address to save area
	push	hl		;save hook address
	call	copy5		;copy old hook
	ld	hl,hokmdi	;set address to new hook data
	pop	de		;get hook address
	call	copy5		;set new hook
	jr	inimdp
;
;	Setting for MIDI cartridge
;
setho2:
	xor	a
	out	(setcart),a	;set cartridge as same as built-in I/F
	ld	hl,H.KEYI	;save hook
	ld	de,hoksvt	;set address to save area
	push	hl		;save hook address
	call	copy5		;copy old hook
	ld	hl,hokmdc	;set address to new hook data
	pop	de		;get hook address
	call	copy5		;set new hook
	xor	a
	out	(setcart),a	;set MIDI cartridge I/O
	jr	inimdp
;
;	Here when no MIDI interface.
;	Print message and return to DOS.
;
nomidi:
	ret

copy5:
	ld	bc,5
	ldir
	ret
;
;	Hook Definition
;
hokmdi:				;hook for MIDI IN
	jp	midiin
	ret
	ret
hokmdt:				;hook for 8253timer
	jp	mdtmin
	ret
	ret
hokmdc:				;hook for MIDI cartridge
	jp	mdintr
	ret
	ret

;
;	Initialize MIDI Interface
;
inimdp:
;
;	MIDI baud rate generater
;
	ld	a,00010110b	;8253 Control Word
;		  |||||||+-----   Binary Count
;		  ||||+++------   Mode 3 :Rate Generater (Square Wave)
;		  ||++---------   LSB Read/Load
;		  ++-----------   Counter #0 for Baud Rate Generater of 8251
;
	out	(tm_cmd),a
	ld	a,8		; Set Counter.   4MHz / 8 = 500KHz
	out	(timer0),a	; Set 8253 Counter (LSB)
;
;	5msec timer
;
	ld	a,10110100b	;8253 Control Word
;		  |||||||+-----   Binary Count
;		  ||||+++------   Mode 2 :Rate Generater
;		  ||++---------   2bytes Read/Load
;		  ++-----------   Counter #2 for 5msec timer
;
	out	(tm_cmd),a
	ld	hl,20000
	ld	a,l		;
	out	(timer2),a	; Set 8253 Counter (LSB)
	ld	a,h
	out	(timer2),a	; Set 8253 Counter (MSB)
;
;	Initialize 8251
;
	xor	a		; Reset 8251
	out	(UARTcmd),a	; Set 0
	call	waits
	out	(UARTcmd),a	; Set 0
	call	waits
	out	(UARTcmd),a	; Set 0
	call	waits
	ld	a,40h
	out	(UARTcmd),a	; Set 40h
	call	waits
;
;	Set 8251
;
	ld	a,01001110b	;8251 MODE Instruction
;		  ||||||++-----   Baud Rate :*16  ( 500KHz/16 = 31.25KHz )
;		  ||||++-------   Character Length : 8bits
;		  ||++---------   Parity Disable
;		  ++-----------   Stop Bit : 1bit
;
	out	(UARTcmd),a
	call	waits
	ld	a,00100111b	;8251 COMMAND Instruction
;		  |||||||+-----   Transmit : Enable
;		  ||||||+------   ~DTR = LOW : 8253timer enable
;		  |||||+-------   Receive  : Enable
;		  ||||+--------   Send Break Character : Normal
;		  |||+---------   Error Reset : No Operation
;		  ||+----------   ~RTS = LOW : MIDI IN enable
;		  |+-----------   No Operation
;		  +------------   No Operation
;
	ld	(cmdsv),a	;save command
	out	(UARTcmd),a
	in	a,(UARTrecv)	;interrupt flag reset
	xor	a
	out	(tm_int),a
	ei
	ret

;
;	main routine
;
;	Get data from buffer and print it.
;	If overrun error, then print '*'.
;
main:
	ld	hl,mdbuf	;set pointer
	ld	(putp),hl
	ld	(getp),hl
main1:
	call	getdat		;get MIDI IN data
	in	a,(UARTstat)
	and	00010000b	;overrun error ?
	jr	z,main2		;no
	ld	a,(cmdsv)	;8251 command
	or	00010000b	;reset 8251
	out	(UARTcmd),a	;reset 8251 error flag
main2:
	call CHSNS
	or	0		;is there any input ?
	jr	z,main1		;no , loop again
	jp	rstmidi

;
;	Get data from buffer
;
getdat:
	ld	hl,(getp)
	ld	de,(putp)
	scf
	ccf
	sbc	hl,de		;no data in buffer ?
	ret	z		;no data , then ret
	ld	hl,(getp)
	ld	a,(hl)		;get data from buffer
	ld	c,a
getda0:
	in	a,(UARTstat)	;get 8251 status
	and	1		;can I transmit ?
	jr	z,getda0	;no , check again
	ld	a,c
	out	(UARTsend),a	;MIDI OUT
	cp	0f8h		;if it is 'f8'(MIDI sync timing clock)
	jr	z,getda2	; then not print it
	cp	0feh		;if it is 'fe'(active sensing)
	jr	z,getda2	; then not print it
	cp	80h		;is it data-byte ?
	jr	c,getda1	;yes , skip
getda1:
;	call	System_PrintHexA		;print it
getda2:
	ld	hl,(getp)
	inc	hl		;increment 'getp' pointer
	ld	de,bufend
	push	hl
	scf
	ccf
	sbc	hl,de		;end of buffer ?
	pop	hl
	jr	nz,getda3	;no
	ld	hl,mdbuf
getda3:
	ld	(getp),hl	;save pointer
	ret

;
;	Reset MIDI interface and reset hooks
;
rstmidi:
	di
;		Reset 8251
;				 RTS = HIGH : MIDI IN disable
;				 DTR = HIGH : 8253timer disable
	ld	a,00000001b	;8251 COMMAND Instruction
;		  |||||||+-----   Transmit : Enable
;		  ||||||+------   ~DTR = High
;		  |||||+-------   Receive  : Disable
;		  ||||+--------   Send Break Character : Normal
;		  |||+---------   Error Reset : No Operation
;		  ||+----------   ~RTS = High
;		  |+-----------   No Operation
;		  +------------   No Operation
;
	out	(UARTcmd),a

	call	chkmd2
	jr	z,rstmd1	;if not built-in , then jump
;
;	Reset built-in MIDI interface
;
	ld	de,H.MDTM	;restore hook
	ld	hl,hoksvt	;save area
	call	copy5
	ld	de,H.MDIN
	ld	hl,hoksvt+5	;save area
	call	copy5
	jr	rstmd2
;
;	Reset MIDI cartridge
;
rstmd1:
	ld	de,H.KEYI	;restore hook
	ld	hl,hoksvt	;save area
	call	copy5
rstmd2:
	ei
	ret

;
;	Interrupt routin
;

;
;	For MIDI cartridge
;
mdintr:
	in	a,(UARTstat)	;MIDI IN ?
	and	00000010B
	jr	z,mdint1	;no
	call	intr_in		;yes
	jr	mdintr		;MIDI IN check again
mdint1:
	in	a,(UARTstat)	;8253 timer ?
	and	10000000B
	call	nz,intr_time	;yes
	jp	hoksvt

;
;	For built-in MIDI interface
;
;	MIDI IN
midiin:
	in	a,(UARTstat)	;MIDI IN ?
	and	00000010B
	jr	z,midin1	;no
	call	intr_in		;yes
	jr	midiin		;MIDI IN check again
midin1:
	ei
	jp	hoksvt+5

;	5msec timer
mdtmin:
	in	a,(UARTstat)	;8253 timer ?
	and	10000000B
	call	nz,intr_time	;yes
	jp	hoksvt

;
;	MIDI IN interrupt
;
intr_in:
	in	a,(UARTrecv)	;read MIDI IN data and reset interrupt flag
	call MidiIn_WriteByte
	ret
;
;	timer interrupt
;
intr_time:
	ld	a,(cmdsv)	;check timer interrupt enable or not.
	and	00000010b	;enable ?
	ret	z		;no
	xor	a
	out	(tm_int),a	;reset interrupt flag
	ret

;
;	Check MIDI interface
;	Return : [CF]=1			no MIDI interface
;	       : [CF]=0 , [ZF]=1        found MIDI cartridge
;	       : [CF]=0 , [ZF]=0        MIDI interface is built in
;
chkmidi:
	ld	a,(EXPTBL)
	ld	hl,VERID1
	call	RDSLT		;read Main ROM version ID
	cp	3
	ret	c		;MSX1,MSX2,MSX2+	return
	call	chkmd2		;read MIDI interface ID
	ret	nz		;MIDI interface is built in
	ld	b,4
chkro1:
	push	bc		;save counter
	ld	a,4
	sub	b		;primary slot number
	ld	c,a		;save
	ld	hl,EXPTBL
	ld	a,c
	add	a,l		;set EXPTBL
	ld	l,a
	ld	a,(hl)
	and	10000000B	;expanded ?
	jr	z,chkro3	;no
	ld	b,4		;number of expanded slots
chkro2:				;search expanded slot
	push	bc
	ld	a,00100100B
	sub	b		;001000nnB
	rlc	a
	rlc	a		;1000nn00B
	or	c		;1000nnmmB = slot address
	call	chkid		;check MIDI ID
	pop	bc
	jr	z,chkroy	;found MIDI ID
	djnz	chkro2		;next expanded slot
	pop	bc
	jr	chkro4		;next slot
chkro3:				;search primary slot
	ld	a,c		;set slot address
	call	chkid		;check MIDI ID
	pop	bc
	jr	z,chkroz	;found MIDI ID
chkro4:
	djnz	chkro1		;search next slot
	scf			;no MIDI ID
	ret
chkroy:
	pop	bc
chkroz:
	xor	a		;set Z flag, reset Cy flag
	ret

;
;	Is MIDI interface built in ?
;	Return : [ZF]=1		built in
;	       : [ZF]=0		not built in
;
chkmd2:
	ld	a,(EXPTBL)
	ld	hl,VERID2
	call	RDSLT		;read MIDI interface ID
	and	1		;set Zflag
	ret

;
;	Check MIDI ID
;
;	Entry :[A]=slot address
;	Return:Z flag is set if MIDI ID is found
;
id_string:	db	"MIDI"
id_address	equ	401ch	;MIDI ID address
chkid:
	push	bc
	ld	de,id_string
	ld	hl,id_address
	ld	b,4		;length of id_string
chkid1:
	push	af
	push	bc
	push	de
	call	RDSLT		;read data
	pop	de
	pop	bc
	ld	c,a		;save data
	ld	a,(de)		;get char
	cp	c		;same ?
	jr	nz,chkid2	;no
	pop	af		;restore slot address
	inc	de		;next char
	inc	hl
	djnz	chkid1		;check next char
	pop	bc		;restore environment
	xor	a		;I found ID
	ret
chkid2:
	pop	af		;restore slot address
	pop	bc		;restore environment
	xor	a
	inc	a		;worng ID
	ret

;
;	Wait routine
;
stimec	equ	0e6h		;system timer clear
stimeh	equ	0e7h		;system timer High
waits:
	push	af
	push	bc
	ld	c,1
	out	(stimec),a	;clear timer
waitlp:
	in	a,(stimeh)	; get counter
	cp	c
	jr	c,waitlp	; loop
	pop	bc
	pop	af
	ret


;
;	Workarea definition
;
	SECTION RAM

hoksvt:	ds	10		;hook save area
cmdsv:	ds	1		;8251 command save area
getp:	ds	2		;pointer for getting MIDI data
putp:	ds	2		;pointer for putting MIDI data
mdbuf:	ds	128		;buffer for MIDI IN
bufend	equ	$		;end of buffer

	ENDS
