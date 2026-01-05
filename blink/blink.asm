        .ifdef  .__.CPU. ; if we are using as8048 this is defined
        .8041
        .area   CODE    (ABS)
        .endif           ; .__.CPU.


        .org 0x00
reset:
        dis     i
        dis     tcnti
        jmp     entry


        .org 0x10
entry:
        mov     a,      #0x5F   ; 01011111
        outl    p2,     a
        call    delay

        mov     a,      #0xAF   ; 10101111
        outl    p2,     a
        call    delay

        jmp     entry           ; repeat main loop


delay:
        nop
        nop
        nop
        nop
        ret
