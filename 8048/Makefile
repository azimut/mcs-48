.PHONY: all
all: blink.bin

%.bin: %.asm
	asm48 -f bin -o $@ $<

.PHONY: clean
clean: ; rm -vf ./*.bin ./*.hex ./*.inc
