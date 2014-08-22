;
; A MIDI clock
;
MidiClock: MACRO
	outputs:
	trigger:
		Value 0
	counter:
		Value 0
	fraction:
		Value 0
	outputsEnd:
	lastClock:
		db 0
	inputs:
	port:
		dw Constants_instance + 0
	divider:
		dw Constants_instance + 24
	inputsEnd:
	labels: equ MidiClock_labels
	_size:
	ENDM

	dw MidiClock._size
MidiClock_class: MidiClock

; ix, de <- new object
MidiClock_New:
	ld iy,MidiClock_class
	call Class_New
	call MidiClock_Constructor
	ret

; ix = this
; ix, de <- this
MidiClock_Constructor:
	push ix
	ld e,ixl
	ld d,ixh
	ld ix,Updater_60Hz
	ld hl,MidiClock_Update
	call Updater_AddListener
	pop ix
	ret

; ix = this
MidiClock_Update: PROC
	ld (ix + MidiClock.trigger),0
	call MidiClock_GetPort
	ld a,(iy + MidiIn.clock)
	ld b,a
	sub (ix + MidiClock.lastClock)
	ld (ix + MidiClock.lastClock),b
	ld l,(ix + MidiClock.divider)
	ld h,(ix + MidiClock.divider + 1)
	ld b,(hl)
	add a,(ix + MidiClock.fraction)
	call c,Overflow
	call CountTicks
	add a,b
	ld (ix + MidiClock.fraction),a
	ret
Overflow:
	inc (ix + MidiClock.counter)
	ld (ix + MidiClock.trigger),127
CountTicks:
	sub b
	ret c
	inc (ix + MidiClock.counter)
	ld (ix + MidiClock.trigger),127
	jp CountTicks
	ENDP

; ix = this
; iy <- MIDI buffer
MidiClock_GetPort:
	ld l,(ix + MidiClock.port)
	ld h,(ix + MidiClock.port + 1)
	ld a,(hl)
	ld iy,KeyMidi_instance
	and a
	ret z
	ld iy,MSXMidi_instance
	dec a
	ret z
	ld iy,PhilipsMidi_instance
	dec a
	ret z
	ld iy,SFGMidi_instance
	dec a
	ret z
	ld iy,AudioMidi_instance
	ret

;
MidiClock_labels:
	db "MIDI Clock",0
	db "Trigger",0
	db "Counter",0
	db "Fraction",0
	db "Port",0
	db "Divider",0
