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
        mov     r1,     #0      ; R1 = 0
loop:
        inc     r1              ; R1 = R1 + 1
        call    sendnumber
        call    delay
        jmp     loop


sendnumber:                             ; INPUT(R1)
        anl     p2,     #0              ; P2 = 0x00
        mov     a,      #maskenable     ; ENABLE = ON
        outl    p2,     a

        mov     a,      r1              ;  A = R1
        da      a                       ; da(A)
        mov     r2,     a               ; R2 = A
        anl     a,      #0x0F
        add     a,      #segments
        movp    a,      @a
        mov     r0,     a
        call    sendsegment

        mov     a,      r2
        swap    a
        anl     a,      #0x0F
        add     a,      #segments
        movp    a,      @a
        mov     r0,     a
        call    sendsegment

        mov     a,      #maskdisable    ; ENABLE = OFF
        outl    p2,     a
        ret

sendsegment:
        mov     r7,     #8              ; R7 = init loop counter
        mov     a,      r0              ; R0 = input segment
        mov     r6,     a               ; R6 = working variable for input R0 segment
send:
        mov     a,      r6
        anl     a,      #0x01
        jnz     one
zero:
        call    datazero
        jmp     eof
one:
        call    dataone
eof:
        mov     a,      r6              ; shift data
        rr      a
        mov     r6,     a
        djnz    r7,     send            ; end loop?
        ret


dataone:
        mov     a,      #(maskenable|maskdata)
        outl    p2,     a
        mov     a,      #(maskenable|maskdata|maskclock)
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


segments:
        .byte #0B10110111       ; 0 0xB7
        .byte #0B00100100       ; 1 0x24
        .byte #0B01110011       ; 2 0x73
        .byte #0B01110110       ; 3 0x76
        .byte #0B11100100       ; 4 0xE4
        .byte #0B11010110       ; 5 0xD6
        .byte #0B11010111       ; 6 0xD7
        .byte #0B10110100       ; 7 0xB4
        .byte #0B11110111       ; 8 0xF7
        .byte #0B11110110       ; 9 0xF6


delay:                          ; = 1.515ms
        mov     r6,     #255
        mov     r7,     #255
        djnz    r7,     .
        djnz    r6,     .-4
        ret
