
FIRMWARE_END=0x3FF

default: blink.rom

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

clean:; rm -vf ./*.sym ./*.lst ./*.rel ./*.hlr ./*.hex ./*.rom
