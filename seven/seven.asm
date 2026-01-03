.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.


.equ maskclock,  0x1f
.equ masklatch,  0x2f
.equ maskdata,   0x3f
.equ numberone,  0x14
.equ numbertwo,  0xE2


        .org 0x0
reset:
        dis i
        dis tcnti
        jmp main


        .org 0x10
main:
        mov  R0, #numberone
        call sendnumber
        call delay

        mov  R0, #numbertwo
        call sendnumber
        call delay

        jmp  main


sendnumber:
        mov  R5, #0x07           ; init loop counter
datasend:
        mov   A, R0
        anl   A, #0x01
        jnz  dataon
dataoff:
        outl P2, A
        jmp dataclock
dataon:
        mov   A, #maskdata
        outl P2, A
dataclock:
        mov   A, #maskclock
        outl P2, A
        mov   A, R0             ; shift data
        rr    A
        mov  R0, A
        djnz R5, datasend       ; end loop?
dataeof:
        mov   A, #masklatch
        outl P2, A
        ret


delay:
        nop
        nop
        nop
        nop
        ret
