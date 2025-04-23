# mcs-48

Little .asm scripts for a chip of the [MCS-48](https://es.wikipedia.org/wiki/Intel_MCS-48) family. Wrote for the [asm48](https://github.com/daveho/asm48) assembler.

## Descriptions

- [blink.asm](./blink.asm), simple hello world, a slightly modified version of author's [example](https://www.youtube.com/watch?v=K83uTnW6IHU) to alternate output bits in P1
- [inc.awk](./inc.awk), script to generate a snippet to be copied into an arduino sketch with the parsed output of `hexdump -C` of an output .bin
