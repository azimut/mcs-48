.ifdef  .__.CPU. ; if we are using as8048 this is defined
.8041
.area   CODE    (ABS)
.endif           ; .__.CPU.

.equ    idleseparator,  7

.equ    erroracklow,    0x04
.equ    errorackhigh,   0x03
.equ    errordatalow,   0x02
.equ    errordatahigh,  0x01

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
        retr

timerroutine:
        sel     rb1
        stop    tcnt
        ;; mov     r2,     a               ; R2 = save A

startup:

        anl     p2,     #dht11pinnot    ; PULL DOWN dht11 data = 18.44 ms
        mov     r6,     #17             ;  mov
        mov     r7,     #255            ;  mov * 10
        djnz    r7,     .               ;  djnz * 240 * 10
        djnz    r6,     .-4             ;  djnz * 10

        orl     p2,     #dht11pin       ; PULL UP   dht11 data (also set as input?)
        mov     r7,     #3
        djnz    r7,     .


;;; ---------DHT ACK---------------------
;;; R7 = nr of retries OR idle loop

waitlow:
        mov     r7,     #10              ; 15 + mov = 22.5 us
trylow:
        in      a,      p2
        anl     a,      #dht11pin
        jz      idlelow                 ; got LOW, time to move on
        djnz    r7,     trylow          ; try again
        mov     r0,     #raddr
        mov     @r0,    #erroracklow
        jmp     holdline                ; ... give up
idlelow:
        ;; mov     r7,     #7              ; anl+jz+mov = 22.5 us
        ;; djnz    r7,     .               ; djnz*7     = 52.5 us


waitup:
        mov     r7,     #10              ; 52.5 + 22.5 + mov = 82.5 us
        ;; orl     p2,     #dht11pin       ; PULL UP for INPUT
tryhigh:
        in      a,      p2
        anl     a,      #dht11pin
        jnz     idlehigh                ; got HIGH, time to move on
        djnz    r7,     tryhigh         ; try again
        mov     r0,     #raddr+1
        mov     @r0,    #errorackhigh
        jmp     holdline                 ; ... give up
idlehigh:
        ;; mov     r7,     #5              ; anl+jz+mov = 22.5 us
        ;; djnz    r7,     .               ; djnz*5     = 37.5 us

;;; --------DHT DATA TRANSFER----------------------
;;; R0 = byte POINTER
;;; R1 = bits COUNTER
;;; R2 = byte RESULT (temporary storage)
;;; R7 = byte COUNTER

        mov     r0,     #raddr
        mov     r7,     #5
        orl     p2,     #dht11pin       ; PULL UP dht11 (also set as input?)
rbyte:
        mov     r1,     #8
rbit:
        in      a,      p2
        jb4     rbit                    ; loop until LOW
highwait:
        in      a,      p2
        jb4     highidle                ; loop until HIGH
        jmp     highwait
highidle:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        clr     c
        cpl     c                       ; clr + cpl = 4.21

        in      a,      p2

        jb4     shiftit
        clr     c
shiftit:                                ; movi*2 + rlc = 6.32
        mov     a,      r2
        rlc     a
        mov     r2,     a
endbit:                                 ; djnz*2 + movi*2 + inc  = 14.76
        djnz    r1,     rbit
        mov     a,      r2              ; store byte in A
        mov     @r0,    a               ; store byte in RAM
        inc     r0                      ; increase RAM pointer
        djnz    r7,     rbyte           ; process next byte

;;; ------------------------------

holdline:
        orl     p2,     #dht11pin       ; hold DHT11 data line UP

;;; ------------------------------

	;; mov	a, #0x0F        ; restart timer
	;; mov	t, a
	;; strt	t
        ;; mov     a,      r2      ; R2 = restore A

	;; retr
        ret

;;; ========================================

        .org 0x100
main:
        sel     rb0
	;; mov	a, #0xF0         ; restart timer
	;; mov	t, a
	;; strt	t
        ;; en      tcnti
        dis     tcnti
        dis     i
        call    initram

loop:
        call    initram
        call    timerroutine

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

        mov     a,      #idleseparator
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


sendnumber:                                     ; INPUT(R1)
        anl     p2,     #(dht11pin|maskdisable) ; P2     = 0x00
        mov     a,      #(dht11pin|maskenable)  ; ENABLE = ON
        outl    p2,     a

        mov     a,      r1                      ; A  = R1
        da      a                               ; da(A)
        mov     r2,     a                       ; R2 = A
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

        mov     a,      #(dht11pin|maskdisable) ; ENABLE = OFF
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
        mov     a,      #(dht11pin|maskenable|maskdata)
        outl    p2,     a
        mov     a,      #(dht11pin|maskenable|maskdata|maskclock)
        outl    p2,     a
        mov     a,      #(dht11pin|maskenable|maskdata)
        outl    p2,     a
        ret

datazero:
        mov     a,      #(dht11pin|maskenable)
        outl    p2,     a
        mov     a,      #(dht11pin|maskenable|maskclock)
        outl    p2,     a
        mov     a,      #(dht11pin|maskenable)
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
        .byte #0B11110101       ; A 0xF5
        .byte #0B11010111       ; b 0xD7
        .byte #0B10010011       ; C 0x93
        .byte #0B01110111       ; d 0x77
        .byte #0B11010011       ; E 0xD3
        .byte #0B11010001       ; F 0xD1
