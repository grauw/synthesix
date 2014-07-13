;
; A module meta information object
;
Module: MACRO ?acquirer
	acquirer:
		dw ?acquirer
	size:
	ENDM

Module_Acquire:
	ld l,(ix + Module.acquirer)
	ld h,(ix + Module.acquirer + 1)
	jp hl

Module_Acquire_HL:
	push hl
	pop iy
	ld l,(iy + Module.acquirer)
	ld h,(iy + Module.acquirer + 1)
	jp hl

;
; Module definitions
;
Module_values: Module Module_ValuesFactory

Module_ValuesFactory:
	ld ix,Value_values
	ret

Module_channel: Module Module_ChannelFactory

Module_ChannelFactory:
	ld ix,Channel_channels.0
	ret

Module_controllerBank: Module Module_ControllerBankFactory

Module_ControllerBankFactory:
	ld ix,Channel_channels.0
	call Channel_GetControllerBank
	ret

Module_voice: Module Module_VoiceFactory

; ix = Patch
Module_VoiceFactory:
	ld l,(ix + Patch.voicePool)
	ld h,(ix + Patch.voicePool + 1)
	push hl
	call Voice_New
	ex (sp),ix
	pop hl
	push hl
	call VoicePool_AddVoice
	pop ix
	ret

Module_sccVoice: Module SCC_GetFreeVoice

Module_envelopeAD: Module EnvelopeAD_New

Module_envelopeAR: Module EnvelopeAR_New

Module_lfoTriangle: Module LFOTriangle_New

Module_lfoTriangleSigned: Module LFOTriangleSigned_New

Module_attenuate: Module Attenuate_New

Module_attenuateAdd: Module AttenuateAdd_New

Module_pitchBend: Module PitchBend_New

Module_addPitch: Module AddPitch_New

Module_sustain: Module Sustain_New
