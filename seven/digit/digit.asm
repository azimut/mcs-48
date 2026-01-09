.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.


.equ    maskdisable,    0x00
.equ    maskenable,     0B10000000
.equ    maskdata,       0B01000000
.equ    maskclock,      0B00100000


        .org 0x0
reset:
        jmp     main


        .org 0x10
main:
        dis     i
        dis     tcnti
loop:
        mov     r7,      #0xFF
        call    blink
        mov     r7,      #0x00
        call    blink
        jmp     loop


blink:
        anl     p2,     #0              ; P2 = 0x00
        mov     a,      #maskenable     ; ENABLE = ON
        outl    p2,     a
        call    sendpattern
        mov     a,      #maskdisable    ; ENABLE = OFF
        outl    p2,     a
        ret


sendpattern:
        mov     r6,     #16
pattern:
        mov     a,      r7
        cpl     a
        mov     r7,     a
        jz      zero
one:
        call    dataone
        jmp     eof
zero:
        call    datazero
eof:
        djnz    r6,     pattern
        ret


dataone:
        mov     a,      #(maskenable|maskdata)
        outl    p2,     a
        mov     a,      #(maskenable|maskclock)
        outl    p2,     a
        mov     a,      #(maskenable|maskdata)
        outl    p2,     a
        ret

datazero:
        mov     a,      #(maskenable)
        outl    p2,     a
        mov     a,      #(maskenable|maskclock)
        outl    p2,     a
        mov     a,      #(maskenable)
        outl    p2,     a
        ret
