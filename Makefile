all:
	node tools/genftable.js > gen/psgftable.asm
	pasmo -I src -I gen src/ROM.asm bin/synthe6.rom

run: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT
