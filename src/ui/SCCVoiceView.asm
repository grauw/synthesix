;
; Display an SCC voice
;
; ix = voice
; iy = buffer
; hl = buffer address
SCCVoiceView_Paint:
	push hl
	ex de,hl
	ld hl,SCCVoiceView_background
	ld bc,0610H
	call UIBuffer_CopyToBuffer
	pop hl

	push hl
	ld de,010AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.note
	call InputView_Paint
	pop hl

	push hl
	ld de,020AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.detune
	call InputView_Paint
	pop hl

	push hl
	ld de,030AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.amplitude
	call InputView_Paint
	pop hl

	push hl
	ld de,040AH
	call UIBuffer_GetRelativePosition
	ld a,SCCVoice.wave
	call InputView_Paint
	pop hl
	ret

;
SCCVoiceView_background:
	db 24,23,23," SCC Voice ",23,25
	db 29," Note    0000 ",22
	db 29," Detune  0000 ",22
	db 29," Amplitu 0000 ",22
	db 29," Wave    0000 ",22
	db 26,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27
