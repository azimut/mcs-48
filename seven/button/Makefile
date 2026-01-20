
FIRMWARE_END := 0x3FF
NAME         := $(notdir $(basename $(shell pwd)))

default: $(NAME).rom

# assemble with as8048
%.hex: %.asm
	as8048 -l -o $<
	aslink -i -o $(<:.asm=.rel)

# convert to bin
%.bin: %.hex
	hex2bin -p 00 -e bin $<

# generate rom image from bin by adding checksum at end
%.rom: %.bin
	srec_cat $< -binary -crop 0 $(FIRMWARE_END) -fill 0x00 0 $(FIRMWARE_END) -checksum-neg-b-e $(FIRMWARE_END) 1 1 -o $(<:.bin=.rom) -binary

# C array representation of given .BIN
%.h: %.bin
	hexdump -vC $< | gawk -f ../../header.awk | tee $@

.PHONY: clean
clean:; rm -vf ./*.sym ./*.lst ./*.rel ./*.hlr ./*.hex ./*.rom

.PHONY: s48
s48: $(NAME).rom
	cp -v ./$(NAME).rom ~/Downloads/s48/
	dosbox -forcescaler normal2x \
		-c 'MOUNT C ~/Downloads/s48' \
		-c 'C:' \
		-c 'S48.COM $(NAME).ROM'

.PHONY: 8048
8048: $(NAME).asm
	unix2dos < ./$(NAME).asm > ~/Downloads/8048/$(NAME).asm
	dosbox -forcescaler normal2x \
		-c 'MOUNT C ~/Downloads/8048' \
		-c 'C:' \
		-c '8048.EXE $(NAME).ASM'

