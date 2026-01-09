.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.


.equ    maskdisable,    0x00
.equ    maskenable,     0B10000000
.equ    maskdata,       0B01000000|maskenable
.equ    maskclock,      0B00100000
.equ    maskclocknot,   ~maskclock

.equ    numberzero,     0B10110111
.equ    numberone,      0B00100100


        .org 0x0
reset:
        jmp     main


        .org 0x10
main:
        dis     i
        dis     tcnti
        call    limpiar
loop:
        mov     r0,     #numberzero
        call    sendsegments

        mov     r0,     #numberone
        call    sendsegments

        jmp     loop


limpiar:
        anl     p2,     #0              ; P2 = 0x00
        orl     p2,     #maskenable     ; ENABLE = ON
        anl     p2,     #maskdisable    ; ENABLE = OFF
        ret


sendsegments:
        mov     a,      #maskenable     ; ENABLE = ON
        outl    p2,     a
        call    sendsegment
        call    sendsegment
        mov     a,      #maskdisable    ; ENABLE = OFF
        outl    p2,     a
        ret


sendsegment:
        mov     r5,     #8             ; R5 = init loop counter
datasend:
        mov     a,      r0
        anl     a,      #0x01
        jnz     dataon
dataoff:
        mov     a,      #maskenable
        outl    p2,     a
        jmp     dataclock
dataon:
        mov     a,      #maskdata
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
