.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.


.equ maskdisable,  0x00
.equ maskenable,   0x20
.equ maskclock,    0x40
.equ maskclocknot, ~maskclock
.equ maskdata,     0x80|maskenable

.equ numberzero,  0B10110111
.equ numberone,   0B00100100


        .org 0x0
reset:
        dis i
        dis tcnti
        jmp main


        .org 0x10
main:
        mov  R0, #numberzero
        call sendnumber
        call delay

        mov  R0, #numberone
        call sendnumber
        call delay

        jmp  main


sendnumber:
        mov   A, #maskenable    ; ENABLE=ON
        outl P2, A
        mov  R5, #0x08          ; init loop counter
datasend:
        mov   A, R0
        anl   A, #0x01
        jnz  dataon
dataoff:
        mov   A, #maskenable
        outl P2, A
        jmp  dataclock
dataon: mov   A, #maskdata
        outl P2, A
dataclock:
        anl   A, #maskclock
        outl P2, A
        anl   A, #maskclocknot
        outl P2, A
        mov   A, R0             ; shift data
        rr    A
        mov  R0, A
        djnz R5, datasend       ; end loop?
dataeof:
        mov   A, #maskdisable   ; ENABLE=OFF
        outl P2, A
        ret


delay:
        nop
        nop
        nop
        nop
        ret
