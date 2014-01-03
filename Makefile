all:
	node tools/genftable.js > gen/psgftable.asm
	node tools/genmulttable.js > gen/multtable.asm
	java -jar tools/glass.jar -I gen src/ROM.asm bin/synthe6.rom bin/synthe6.symbol

run: all
	openmsx -cart bin/synthe6.rom -romtype KonamiSCC -machine Panasonic_FS-A1GT
