all:
	node tools/genftable.js > gen/psgftable.asm
	node tools/genmulttable.js > gen/multtable.asm
	java -jar tools/glass.jar -I gen src/ROM.asm bin/synthe6.rom bin/synthe6.sym

run: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT -script openmsx.tcl

run2: all
	openmsx -ext slotexpander -ext Konami_Snatcher_Sound_Cartridge -cart bin/synthe6.rom -romtype KonamiSCC -machine Philips_NMS_8245 -ext mu-PACK -script openmsx.tcl

run3: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Yamaha_CX5MII-128 -ext mu-PACK -script openmsx.tcl
