.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.


.equ    dht11pin,       0B00010000 ; DHT data pin
.equ    dht11pinnot,    ~dht11pin
.equ    raddr,          0x20       ; reading address in RAM
.equ    rhumidity,      (raddr+0)  ; 2 bytes - integer - decimal
.equ    rtemperature,   (raddr+2)  ; 2 bytes - integer - decimal
.equ    rchecksum,      (raddr+4)  ; 1 byte


        .org 0x00
reset:
        jmp     main


        .org 0x10
main:
        dis     i
        dis     tcnti
initram:
        mov     a,      #0x00
        mov     r0,     #rhumidity
        mov     @r0,    a
        mov     r0,     #rhumidity+1
        mov     @r0,    a
        mov     r0,     #rtemperature
        mov     @r0,    a
        mov     r0,     #rtemperature+1
        mov     @r0,    a
        mov     r0,     #rchecksum
        mov     @r0,    a

;;; ------------------------------

startup:
        anl     p2,     #dht11pinnot    ; PULL DOWN dht11 data
        mov     r6,     #10             ;  1.8ms  * 10      = 18ms
        mov     r7,     #240            ;  3.75us * 2 * 240 = 1.8ms
        djnz    r7,     .
        djnz    r6,     .-4

        orl     p2,     #dht11pin       ; PULL UP   dht11 data
        mov     r7,     #2              ; 3.75us * 2 +
        djnz    r7,     .               ; 3.75us * 2 * 2 = 22.5us

;;; ------------------------------

waitlow:
        mov     r7,     #2              ; 2 * (2+2+2+2) * 3.75us = 60us
trylow:
        in      a,      p2
        anl     a,      #dht11pin
        jz      idlelow                 ; got LOW, time to move on
        djnz    r7,     trylow          ; try again
        jmp     startup                 ; ... start over
idlelow:
        mov     r7,     #11             ; 3.75us * 2 * 11 = 82.5us
        djnz    r7,     .


waitup:
        mov     r7,     #2              ; 2 * (2+2+2+2) * 3.75us = 60us
tryhigh:
        in      a,      p2
        anl     a,      #dht11pin
        jnz     idlehigh                ; got HIGH, time to move on
        djnz    r7,     tryhigh         ; try again
        jmp     startup                 ; ... start over
idlehigh:
        mov     r7,     #11             ; 3.75 * 2 * 11 = 82.5us
        djnz    r7,     .

;;; ------------------------------

rdata:
        mov     r7,     #5              ; R7 = counter - reads 5 bytes
        mov     r0,     #raddr          ; R0 = pointer where to write
rbyte:
        mov     r6,     #8              ; R6 = counter - reads 8 bits
        mov     r5,     #0x00           ; R5 = result byte (temporary storage)
rbit:

        mov     r3,     #10             ; R3 = nr of retries
lowwait:
        in      a,      p2
        anl     a,      #dht11pin
        jz      lowdelay                ; if got LOW, move on
        djnz    r3,     lowwait         ; else retry
        jmp     startup                 ; abort
lowdelay:
        mov     r0,     #5              ; 3.75 * 2
        djnz    r0,     .               ; 3.75 * 2 * 5 = 45us


        mov     r4,     #0x00           ; R4 = elapsed time counter, bit cutoff
        mov     r3,     #10             ; R3 = retries
highwait:
        in      a,      p2
        anl     a,      #dht11pin
        jnz     highcount
        djnz    r3,     highwait
        jmp     startup
highcount:                              ; = 26.25u
        inc     r4                      ; 3.75
        in      a,      p2              ; 3.75 * 2
        anl     a,      #dht11pin       ; 3.75 * 2
        jnz     highcount               ; 3.75 * 2


choosebit:
        mov     a,      #3              ; r4<3 is 0
        cpl     a
        add     a,      #1
        add     a,      r4
        jnc     addzero
addone:
        mov     a,      r5
        rl      a
        orl     a,      #0x01
        mov     r5,     a
        jmp     endbit
addzero:
        mov     a,      r5
        rl      a
        mov     r5,     a
endbit:
        djnz    r6,     rbit
        mov     a,      r5
        mov     @r0,    a        ; store byte
        inc     r0               ; advance RAM pointer
        djnz    r7,     rbyte

;;; ------------------------------

holdline:
        orl     p2,     #dht11pin       ; hold DHT11 data line UP
