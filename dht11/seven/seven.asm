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
        stop    tcnt
        mov     r2,     a               ; R2 = save A

startup:
        anl     p2,     #dht11pinnot    ; PULL DOWN dht11 data = 18.907 ms
        mov     r6,     #10             ;  mov             =  7.50 u
        mov     r7,     #250            ;  mov * 10        = 75.00 u
        djnz    r7,     .               ;  djnz * 250 * 10 = 18.75 m
        djnz    r6,     .-4             ;  djnz * 10       = 75.00 u

        orl     p2,     #dht11pin       ; PULL UP   dht11 data

;;; ---------DHT RESPONSE---------------------

waitlow:
        mov     r7,     #3
trylow:
        in      a,      p2
        anl     a,      #dht11pin
        jz      idlelow                 ; got LOW, time to move on
        djnz    r7,     trylow          ; try again
        jmp     startup                 ; ... start over
idlelow:
        ;; orl     p2,     #dht11pin       ; PULL UP quasi for next read
        mov     r7,     #5              ; anl+jz+orl+mov = 30
        djnz    r7,     .               ; djnz*6         = 37.5 + 7.5


waitup:
        mov     r7,     #3              ; 30 + 37.5 + mov = 75us
tryhigh:
        in      a,      p2
        anl     a,      #dht11pin
        jnz     idlehigh                ; got HIGH, time to move on
        djnz    r7,     tryhigh         ; try again
        jmp     startup                 ; ... start over
idlehigh:
        mov     r7,     #2              ; anl+jz+mov = 22.5
        djnz    r7,     .               ; djnz*2     = 15.0

;;; --------DATA TRANSFER----------------------

rdata:                                  ; 22.5 + 15 + mov*5 = 75
        mov     r7,     #5              ; R7 = byte counter
        mov     r0,     #raddr          ; R0 = byte pointer
rbyte:
        mov     r6,     #8              ; R6 = counter - reads 8 bits
        mov     r5,     #0x00           ; R5 = byte result (temporary storage)
rbit:
        mov     r3,     #3              ; R3 = nr of retries
lowwait:
        in      a,      p2
        anl     a,      #dht11pin
        jz      lowdelay                ; if got LOW, move on
        djnz    r3,     lowwait         ; else retry
        jmp     startup                 ; abort
lowdelay:
        nop                             ; anl+jz        = 15
        nop                             ; 7.5 + nop*3   = 26.25
        nop                             ; 26.25 + mov*2 = 41.25

        mov     r4,     #0x00           ; R4 = elapsed time counter, bit cutoff
        mov     r3,     #10             ; R3 = retries
highwait:
        in      a,      p2
        anl     a,      #dht11pin
        jnz     highwait
        djnz    r3,     highidle
        jmp     startup
highidle:
        nop                             ; anl+jnz = 15
        nop                             ; nop*5   = 18.5
        nop                             ; 15 + 18.5 = 33
        nop
        nop
        in      a,      p2
        anl     a,      #dht11pin
        jz      addzero
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

;;; ------------------------------

	mov	a, #0x0F        ; restart timer
	mov	t, a
	strt	t
        mov     a,      r2      ; R2 = restore A

	retr

;;; ========================================

        .org 0x100
main:
        clr     f0
        sel     rb0
	mov	a, #0xF0         ; restart timer
	mov	t, a
	strt	t
        en      tcnti
        ;; dis     tcnti
        dis     i
        call    initram
loop:
        mov     r0,     #raddr+4
        mov     a,      @r0
        mov     r1,     a
        call    sendnumber
        call    delay
        call    delay

        mov     r0,     #raddr+3
        mov     a,      @r0
        mov     r1,     a
        call    sendnumber
        call    delay
        call    delay

        mov     r0,     #raddr+2
        mov     a,      @r0
        mov     r1,     a
        call    sendnumber
        call    delay
        call    delay

        mov     r0,     #raddr+1
        mov     a,      @r0
        mov     r1,     a
        call    sendnumber
        call    delay
        call    delay

        mov     r0,     #raddr+0
        mov     a,      @r0
        mov     r1,     a
        call    sendnumber
        call    delay
        call    delay

        mov     a,      #99             ; aka "63"
        mov     r1,     a
        call    sendnumber
        call    delay
        call    delay
        call    delay
        call    delay

        jmp     loop


initram:
        mov     a,      #0x00           ;  A = value
        mov     r0,     #raddr          ; R0 = address BASE
        mov     r7,     #5              ; R7 = address OFFSET
ramloop:
        inc     a
        mov     @r0,    a
        inc     r0
        djnz    r7,     ramloop
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


delay:
        mov     r6,     #255
        mov     r7,     #255
        djnz    r7,     .       ; 3.75 * 2 * 255 =   1.9125 ms
        djnz    r6,     .-4     ; 1.9125ms * 255 = 487.6875 ms
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
