        .org 0x0
reset:
        jmp entry

        .org 0x10
entry:
        mov   A, #0xAA       ; 10101010
        outl P1, A           ; output to port 1
        call delay

        mov   A, #0x55       ; 01010101
        outl P1, A           ; output to port 1
        call delay

        jmp entry            ; repeat main loop

delay:
        mov R0, #255         ; init outer loop counter
delay_outer:
        mov R1, #255         ; init inner loop counter
delay_inner:
        nop
        nop
        nop
        nop
        djnz R1, delay_inner ; dec inner count, continue if not zero
        djnz R0, delay_outer ; dec outer count, continue if not zero
        ret                  ; return to caller
