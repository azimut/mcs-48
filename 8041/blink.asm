        .ifdef  .__.CPU. ; if we are using as8048 this is defined
        .8041
        .area   CODE    (ABS)
        .endif           ; .__.CPU.

        .org 0x0

reset:  jmp entry

        .org 0x10

entry:  mov    A,      #0x0A  ; 00001010
        outl   P2,     A
        call   delay
        mov    A,      #0x15  ; 00010101
        outl   P2,     A
        call   delay
        jmp    entry          ; repeat main loop

delay:  mov    R0,     #255   ; init outer loop counter
delay2: mov    R1,     #255   ; init inner loop counter
delay1: nop
        nop
        nop
        nop
        djnz   R1,     delay1 ; dec inner count, continue if not zero
        djnz   R0,     delay2 ; dec outer count, continue if not zero
        ret                   ; return to caller
