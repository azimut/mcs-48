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
        mov     r7,     #0xFF   ; R7 = 0xFF
        djnz    r7,     .       ; R7 = R7 - 1
        ret
