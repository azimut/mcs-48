        .ifdef  .__.CPU. ; if we are using as8048 this is defined
        .8041
        .area   CODE    (ABS)
        .endif           ; .__.CPU.


        .org 0x0
reset:
        dis i
        dis tcnti
        jmp entry


        .org 0x10
entry:
        mov  A,    #0x5F ; 01011111
        outl P2,   A
        call delay

        mov  A,    #0xAF ; 10101111
        outl P2,   A
        call delay

        jmp  entry       ; repeat main loop


delay:
        nop
        nop
        nop
        nop
        ret
