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
        mov    A, #4
        add    A, #segments     ;  A = @segments+1
        movp   A, @A            ;  A = @A
        mov   R0, A
        call  sendnumber
        call  delay

        mov    A, #2
        add    A, #segments     ;  A = @segments+1
        movp   A, @A            ;  A = @A
        mov   R0, A
        call  sendnumber
        call  delay

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


segments:
        .byte #0B10110111         ; 0 0xB7
        .byte #0B00100100         ; 1 0x24
        .byte #0B01110011         ; 2 0x73
        .byte #0B01110110         ; 3 0x76
        .byte #0B11100100         ; 4 0xE4
        .byte #0B11010110         ; 5 0xD6
        .byte #0B11010111         ; 6 0xD7
        .byte #0B10110100         ; 7 0xB4
        .byte #0B11110111         ; 8 0xF7
        .byte #0B11110110         ; 9 0xF6
