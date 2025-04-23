.PHONY: all
all: blink.bin

%.inc: %.bin
	hexdump -C $< | awk -f inc.awk > $@
%.bin: %.asm
	asm48 -f bin -o $@ $<
