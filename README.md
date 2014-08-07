Synthesix - MIDI synthesizer for MSX
====================================

Copyright 2013 Laurens Holst

Project information
-------------------

Author: Laurens Holst <laurens.nospam@grauw.nl>  
Site: <https://bitbucket.org/grauw/synthesix>  
Issues: <https://bitbucket.org/grauw/synthesix/issues>
Support: <http://www.msx.org/forum/msx-talk/software/synthesix>

PSG, Multi-SCC(+), MSX-MUSIC, MSX-AUDIO, OPL4 patch editor with MIDI control.

Open source & with sequencer API so someone can create a tracker for it.

Hires timer using line interrupts for high-quality effects with high update
frequency (limitable to once/frame to make it suitable for bgm).

Lfo, wave morphing, pwm, etc. Hardware (when available) and software ASDR.

MIDI controller assign to each parameter and effect, through common mapping.

Synthesix can be loaded on an MSX using a Konami Snatcher SCC+ cartridge,
or compatible devices such as the MegaFlashROM SCC+ or the ESE Mega-SCC+
(built into One Chip MSX).


System Requirements
-------------------

  * MSX2, MSX2+, MSX turboR
  * Certain MSX1 models with V9938 VDP
  * 32kB Main RAM
  * 16kB Video RAM


Supported output devices
------------------------

  * Konami SCC


Supported input devices
-----------------------

Synthesix currently supports the following input devices:

  * Internal MSX-MIDI (turboR GT)
  * External MSX-MIDI (µ-Pack), on all MSX models
  * Philips NMS-1205 Music Module MIDI
  * Yamaha SFG-01 / 05 FM Sound Synthesizer Unit MIDI
  * Philips NMS-1160 Music Keyboard, connected to NMS-1205
  * Toshiba HX-MU901 Music Keyboard, connected to HX-MU900 or FS-CA1
  * Yamaha YK-01/10/20 Music Keyboard, connected to HX-MU900 or FS-CA1
  * Computer alphanumeric keys

If you have another input device which you’d like to be supported, let me know
or file a ticket for it in the issue tracker.

Development information
-----------------------

Label naming convention:

  * Constants: UPPERCASE
  * Variables: Class_variableName
  * Methods: Class_MethodName
  * Method-local labels: Class_MethodName_localName
