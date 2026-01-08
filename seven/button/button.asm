.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.


.equ    maskdisable,    0x00
.equ    maskenable,     0x20
.equ    maskclock,      0x40
.equ    maskclocknot,   ~maskclock
.equ    maskdata,       0x80|maskenable


        .org 0x0
reset:
        jmp     main


        .org 0x10
main:
        dis     i
        dis     tcnti
        mov     r1,     #0xFF           ; initialize count
addone:
        inc     r1
loop:
        call    sendnumber
        call    delay
        jt0     addone
        jmp     loop


sendnumber:                             ; INPUT(R1)
        mov     a,      #maskenable     ; ENABLE=ON
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

        mov     a,      #maskdisable    ; ENABLE=OFF
        outl    p2,     a


sendsegment:                            ; INPUT(R0)
        mov     r5,     #0x08           ; init loop counter
datasend:
        mov     a,      r0
        anl     a,      #0x01
        jnz     dataon
dataoff:
        mov     a,      #maskenable
        outl    p2,     a
        jmp     dataclock
dataon: mov     a,      #maskdata
        outl    p2,     a
dataclock:
        anl     a,      #maskclock
        outl    p2,     a
        anl     a,      #maskclocknot
        outl    p2,     a
        mov     a,      r0             ; shift data
        rr      a
        mov     r0,     a
        djnz    r5,     datasend       ; end loop?
dataeof:
        ret


delay:
        nop
        nop
        nop
        nop
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
