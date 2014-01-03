;
; An SCC voice (channel)
;
	dw SCCVoice_size
SCCVoice:
SCCVoice_wave: equ $ - SCCVoice
	db SCC_WAVE_1
SCCVoice_frequency: equ $ - SCCVoice
	db SCC_FREQUENCY_1
SCCVoice_level: equ $ - SCCVoice
	db SCC_LEVEL_1
SCCVoice_mixerOrMask: equ $ - SCCVoice
	db 00000001B
SCCVoice_mixerAndMask: equ $ - SCCVoice
	db 11111110B
SCCVoice_velocity: equ $ - SCCVoice
	db 0
SCCVoice_envelope: equ $ - SCCVoice
	dw System_ThrowException
SCCVoice_free: equ $ - SCCVoice
	db 0
SCCVoice_size: equ $ - SCCVoice

; ix = this
; b = wave register
; c = frequency register
; d = level register
; e = mixer or mask
; ix <- this
SCCVoice_Constructor:
	ld (ix + SCCVoice_wave),b
	ld (ix + SCCVoice_frequency),c
	ld (ix + SCCVoice_level),d
	ld (ix + SCCVoice_mixerOrMask),e
	ld a,e
	xor 0FFH
	ld (ix + SCCVoice_mixerAndMask),a
	push ix
	ld iy,AREnvelope
	call Class_New
	ld e,ixl
	ld d,ixh
	pop ix
	ld (ix + SCCVoice_envelope + 0),e
	ld (ix + SCCVoice_envelope + 1),d
	ret

; ix = this
; a = note number (0-127)
; b = velocity (0-127)
SCCVoice_NoteOn:
	ld (ix + SCCVoice_velocity),b

	; de = frequency
	ld h,PSG_frequencyTable / 100H
	rlca
	ld l,a
	ld e,(hl)
	inc l
	ld d,(hl)

	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice_frequency)
	ld (hl),e
	inc l
	ld (hl),d

	ld e,(ix + SCCVoice_envelope + 0)
	ld d,(ix + SCCVoice_envelope + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call AREnvelope_NoteOn
	pop ix
	call SCCVoice_SetLevel
	ret

; ix = this
SCCVoice_NoteOff:
	ld e,(ix + SCCVoice_envelope + 0)
	ld d,(ix + SCCVoice_envelope + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call AREnvelope_NoteOff
	pop ix
	call SCCVoice_SetLevel
	ret

; ix = this
; b = time delta
SCCVoice_Update:
	ld e,(ix + SCCVoice_envelope + 0)
	ld d,(ix + SCCVoice_envelope + 1)
	push ix
	ld ixl,e
	ld ixh,d
	call AREnvelope_Update
	pop ix
	call SCCVoice_SetLevel
	ret

; ix = this
; a = volume
SCCVoice_SetLevel:
	ld l,(ix + SCCVoice_velocity)
	call Math_Multiply127x127
	rrca
	rrca
	rrca
	ld h,SCC_BASE_MSB
	ld l,(ix + SCCVoice_level)
	ld (hl),a
	jr z,SCCVoice_SetLevel_Off
	; only needed if the mixer flag resets the phase of the wave...
SCCVoice_SetLevel_On:
	ld a,(SCC_mixerCopy)
	or (ix + SCCVoice_mixerOrMask)
	ld (SCC_BASE + SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret
SCCVoice_SetLevel_Off:
	ld a,(SCC_mixerCopy)
	and (ix + SCCVoice_mixerAndMask)
	ld (SCC_BASE + SCC_MIXER),a
	ld (SCC_mixerCopy),a
	ret

; ix = this
; hl = wave address
SCCVoice_LoadWave:
	ld e,(ix + SCCVoice_wave)
	ld d,SCC_BASE_MSB
	ld bc,32
	ldir
	ret

; ix = this
SCCVoice_Bind:
	set 7,(ix + SCCVoice_free)
	ret

; ix = this
SCCVoice_Free:
	res 7,(ix + SCCVoice_free)
	ret
