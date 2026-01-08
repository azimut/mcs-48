# mcs-48

.asm scripts for the [MCS-48](https://es.wikipedia.org/wiki/Intel_MCS-48) family.

## Projects

- **blink** simple script to make leds blink, using SS (single step) not a clock
- **seven/** scripts to use with 7-segment displays, controlled by a `SDA2131`
  - **/rdigit** hardcoded single digit
  - **/rdigitdb** hardcoded single digit lookup
  - **/counter** real single digit lookup

## Makefile targets

- **<NAME>.h** generates a snippet to be copied into an arduino sketch with the parsed output of `hexdump -C` of an output `.bin`

## References

- 8042 clock: [source](https://github.com/retiredfeline/8042-clock/) and [overview](https://hackaday.io/project/161909-8042-clock)
- video [Random Stuff, Episode 5: 8048 microcontroller experiments](https://www.youtube.com/watch?v=K83uTnW6IHU)

## Tools used

- [asm48](https://github.com/daveho/asm48)
- [asxxxx](https://shop-pdp.net/ashtml/asxxxx.php) assembler, since it supports 8041 specifically
- [hex2bin](https://github.com/algodesigner/hex2bin) to convert intel .hex files to binary
- [srec_cat](https://srecord.sourceforge.net/man/man1/srec_cat.1.html)
- [s48](https://www.os2site.com/sw/DEC/emulators/index.html) mcs-48 cpu simulator
- [dosbox](https://www.dosbox.com/) needed to run s48
