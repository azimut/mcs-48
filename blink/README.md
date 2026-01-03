# blink

Wrote for the [asm48](https://github.com/daveho/asm48) assembler.

## Reference

- https://hackaday.io/project/161909-8042-clock
- https://github.com/retiredfeline/8042-clock/
- [blink.asm](./blink.asm), simple hello world, a slightly modified version of author's [example](https://www.youtube.com/watch?v=K83uTnW6IHU) to alternate output bits in P1

## Tools used

- [asxxxx](https://shop-pdp.net/ashtml/asxxxx.php) assembler, since it supports 8041 specifically
- [hex2bin](https://github.com/algodesigner/hex2bin) to convert intel .hex files to binary
- [srec_cat](https://srecord.sourceforge.net/man/man1/srec_cat.1.html)
