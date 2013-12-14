Synthesix - MIDI synthesizer for MSX
====================================

Copyright 2013 Laurens Holst

Project information
-------------------

PSG, Multi-SCC(+), MSX-MUSIC, MSX-AUDIO, OPL4 patch editor with MIDI control.

Open source & with sequencer API so someone can create a tracker for it.

Hires timer using line interrupts for high-quality effects with high update
frequency (limitable to once/frame to make it suitable for bgm).

Lfo, wave morphing, pwm, etc. Hardware (when available) and software ASDR.

MIDI controller assign to each parameter and effect, through common mapping.

Development information
-----------------------

Label naming convention:

  * Constants: UPPERCASE
  * Variables: Class_variableName
  * Methods: Class_MethodName
  * Method-local labels: Class_MethodName_localName
