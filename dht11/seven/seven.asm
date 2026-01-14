.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.


.equ    maskdisable,    0x00
.equ    maskenable,     0B10000000
.equ    maskdata,       0B01000000
.equ    maskclock,      0B00100000
.equ    dht11pin,       0B00010000 ; DHT data pin
.equ    dht11pinnot,    ~dht11pin
.equ    raddr,          0x20       ; reading address in RAM
.equ    rhumidity,      (raddr+0)  ; 2 bytes - integer - decimal
.equ    rtemperature,   (raddr+2)  ; 2 bytes - integer - decimal
.equ    rchecksum,      (raddr+4)  ; 1 byte

;;; ========================================

        .org 0x00
reset:
        jmp     main

;;; ========================================

	.org 0x03
interrupt:
	retr

;;; ========================================

	.org 0x07
timer:
        sel     rb1
        mov     r2,     a       ; R2 = save A

startup:
        anl     p2,     #dht11pinnot    ; PULL DOWN dht11 data
        mov     r6,     #10             ;  1.8ms  * 10      = 18ms
        mov     r7,     #240            ;  3.75us * 2 * 240 = 1.8ms
        djnz    r7,     .
        djnz    r6,     .-4

        orl     p2,     #dht11pin       ; PULL UP   dht11 data
        mov     r7,     #2              ; 3.75us * 2 +
        djnz    r7,     .               ; 3.75us * 2 * 2 = 22.5us

;;; ---------DHT RESPONSE---------------------

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

;;; --------DATA TRANSFER----------------------

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

	mov	a, #0x0F        ; restart timer
	mov	t, a
	strt	t
        mov     a,      r2      ; R2 = restore A
	retr

;;; ========================================

        ;; .org 0x100
main:
        clr     f0
        sel     rb0
	mov	a, #0x0F         ; restart timer
	mov	t, a
	strt	t
        en      tcnti
        dis     i
        call    initram
loop:
        mov     r0,     #rtemperature
        mov     a,      @r0
        mov     r1,     a
        call    sendnumber
        call    delay
        jmp     loop


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
        ret

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
        mov     r7,     #200    ; 3.75 * 2
        djnz    r7,     .       ; 3.75 * 2 * 200 = 1.5ms
        ret                     ; 3.75 * 2
