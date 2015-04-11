;
; A module meta information object
;
ModuleType: MACRO ?core, ?acquirer
	acquirer:
		dw ?acquirer
	size:
		dw ?core._size
	outputs:
		db ?core.outputs
	outputCount:
		dw ?core.outputsEnd - ?core.outputs
	inputs:
		db ?core.inputs
	inputCount:
		dw (?core.inputsEnd - ?core.inputs) >> 1
	labels:
		dw ?core.labels
	_size:
	ENDM

; ix = this
; iy = patch
ModuleType_Acquire:
	ld l,(ix + ModuleType.acquirer)
	ld h,(ix + ModuleType.acquirer + 1)
	jp hl

; hl = this
; iy = patch
ModuleType_Acquire_HL:
	push hl
	pop ix
	ld l,(ix + ModuleType.acquirer)
	ld h,(ix + ModuleType.acquirer + 1)
	jp hl

; a = port number
; de = module core
; ix = this
; hl <- module output address
; Modifies: af, hl
ModuleType_GetOutput: PROC
	cp (ix + ModuleType.outputCount)
	call nc,Check100H
	add a,(ix + ModuleType.outputs)
	ld l,a
	ld h,0
	rl h
	add hl,de
	ret
Check100H:
	bit 0,(ix + ModuleType.outputCount + 1)
	ret nz
	call System_ThrowException
	ENDP

; a = port number
; de = module core
; ix = this
; hl <- module input address
; Modifies: af, hl
ModuleType_GetInput: PROC
	cp (ix + ModuleType.inputCount)
	call nc,Check100H
	add a,a
	ld h,0
	rl h
	add a,(ix + ModuleType.inputs)
	ld l,a
	ld a,h
	adc a,0
	ld h,a
	add hl,de
	ret
Check100H:
	bit 0,(ix + ModuleType.inputCount + 1)
	ret nz
	call System_ThrowException
	ENDP

;
; Link an input port of this module to another module’s output port.
;
; ix = this
; iy = other module
; b = this module’s input port number
; c = other module’s output port number
; de = this module’s core
; hl = other module’s core
ModuleType_Link: PROC
	push hl
	ld a,b
	call ModuleType_GetInput
	pop de
	push hl
	push iy
	pop ix
	ld a,c
	call ModuleType_GetOutput
	pop de
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	ret
	ENDP

;
; ModuleType definitions
;
ModuleType_constants: ModuleType Constants, ModuleType_ConstantsFactory

ModuleType_ConstantsFactory:
	ld ix,Constants_instance
	ret

ModuleType_channel: ModuleType Channel, ModuleType_ChannelFactory

ModuleType_ChannelFactory:
	ld ix,Channel_channels.0
	ret

ModuleType_controllerBank: ModuleType ControllerBank, ModuleType_ControllerBankFactory

ModuleType_ControllerBankFactory:
	ld ix,Channel_channels.0
	call Channel_GetControllerBank
	ret

ModuleType_note: ModuleType Note, ModuleType_NoteFactory

; iy = Patch
ModuleType_NoteFactory:
	ld l,(iy + Patch.notePool)
	ld h,(iy + Patch.notePool + 1)
	push hl
	call Note_New
	ex (sp),ix
	pop hl
	push hl
	call NotePool_AddNote
	pop ix
	ret

ModuleType_sccVoice: ModuleType SCCVoice, ModuleType_SCCVoiceFactory

ModuleType_SCCVoiceFactory:
	ld ix,(Application_instance.scc)
	call SCC_GetFreeVoice
	ret

ModuleType_multCounter: ModuleType MultCounter, MultCounter_New

ModuleType_divCounter: ModuleType DivCounter, DivCounter_New

ModuleType_envelopeAD: ModuleType EnvelopeAD, EnvelopeAD_New

ModuleType_envelopeAR: ModuleType EnvelopeAR, EnvelopeAR_New

ModuleType_lfoTriangle: ModuleType LFOTriangle, LFOTriangle_New

ModuleType_lfoTriangleBipolar: ModuleType LFOTriangleBipolar, LFOTriangleBipolar_New

ModuleType_waveSine: ModuleType WaveSine, WaveSine_New

ModuleType_waveSineBipolar: ModuleType WaveSineBipolar, WaveSineBipolar_New

ModuleType_waveSquare: ModuleType WaveSquare, WaveSquare_New

ModuleType_waveSquareBipolar: ModuleType WaveSquareBipolar, WaveSquareBipolar_New

ModuleType_wavePulse: ModuleType WavePulse, WavePulse_New

ModuleType_wavePulseBipolar: ModuleType WavePulseBipolar, WavePulseBipolar_New

ModuleType_waveSaw: ModuleType WaveSaw, WaveSaw_New

ModuleType_waveSawBipolar: ModuleType WaveSawBipolar, WaveSawBipolar_New

ModuleType_waveTriangle: ModuleType WaveTriangle, WaveTriangle_New

ModuleType_waveTriangleBipolar: ModuleType WaveTriangleBipolar, WaveTriangleBipolar_New

ModuleType_attenuate: ModuleType Attenuate, Attenuate_New

ModuleType_attenuateAdd: ModuleType AttenuateAdd, AttenuateAdd_New

ModuleType_pitchBend: ModuleType PitchBend, PitchBend_New

ModuleType_addPitch: ModuleType AddPitch, AddPitch_New

ModuleType_sustain: ModuleType Sustain, Sustain_New

ModuleType_select8: ModuleType Select8, Select8_New

ModuleType_sequence8: ModuleType Sequence8, Sequence8_New

ModuleType_midiClock: ModuleType MidiClock, MidiClock_New
