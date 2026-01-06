# mcs-48

.asm scripts for the [MCS-48](https://es.wikipedia.org/wiki/Intel_MCS-48) family.

## Projects

- **blink** simple script to make leds blink, using SS (single step) not a clock
- **seven/** scripts to use with 7-segment displays, controlled by a SDA2131
- **seven/rdigit** hardcoded single digit
- **seven/rdigitdb** hardcoded single digit lookup
- **seven/counter** real single digit lookup

## Makefile targets

- **<NAME>.h** generates a snippet to be copied into an arduino sketch with the parsed output of `hexdump -C` of an output `.bin`
