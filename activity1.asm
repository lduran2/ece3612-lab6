;
; ECE 3613 Lab 6 Activity 1.asm
;
; Created: 3/18/2020 5:59:52 PM
; Author : Leo Duran
; Board  : ATmega324PB Xplained Pro - 2505
; For    : ECE 3612, Spring 2020
;
; This activity displays the message "SPIG2020" with letters being displayed
; for 1 s, and numbers for 1/2 s.
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACROS

;LoaD Immediate to Word: loads a word value into a word register
;@params
;  @0:@1 -- the word register (little endian)
;  @2    -- the word value to load
.macro	ldiw
	ldi	@0,high(@2)	;the high byte
	ldi	@1, low(@2)	;the  low byte
.endmacro	;ldiw


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN PROGRAM

;set up PORTA for output
	ldi	r16,0xFF	;to PORTA data direction register
	out	DDRA,r16	;all outputs
;close PORTB pull switches
	ldi	r16,0xFF	;to PORTB output
	out	PORTB,r16	;all closed
;set up PORTB for input
	ldi	r16,0x00	;to PORTB data direction register
	out	DDRB,r16	;all inputs

;listens to PORTB switches
LISTENER:
	in	r20,PINB	;read in PORTB switches
	com	r20	;PORTB is closed low
	ldiw	ZH,ZL, OP_CONDITIONS << 1	;set the Z pointer to
		;OP_CONDITIONS
;looks for the switch combination
SWITCH_LOOP:
	;check if operating conditions available
	lpm	r16,Z+	;load delay[0]
	cpi	r16,0	;if ran out of operating conditions:
	breq	LISTENER	;start listening again
	;load rest of operating condition
	lpm	r17,Z+	;load bit pattern[0]
	lpm	r18,Z+	;load delay[1]
	lpm	r19,Z+	;load bit pattern[1]
	;check if correct switch conditions
	cpi	r20,0	;if correct switch combination
	breq	PLAY_CYCLE	;plays out the cycle
	;otherwise
	dec	r20	;decrease the switch
	rjmp	SWITCH_LOOP;and keep looking
;plays out the bit pattern found
PLAY_CYCLE:
	;on time
	out	PORTA,r17	;write bit pattern[0] to PORTA
DELAY_LOOP_0:
	rcall	DELAY	;perform the delay for delay[0]
	dec	r16	;count down from delay[0] [*1/2 s]
	brne	DELAY_LOOP_0	;delay again
	;off time
	out	PORTA,r19	;write bit pattern[1] to PORTA
DELAY_LOOP_1:
	rcall	DELAY	;perform the delay for delay[1]
	dec	r18	;count down from delay[1] [*1/2 s]
	brne	DELAY_LOOP_1	;delay again
	rjmp	LISTENER	;start listening again
END:

;delays by 1/2 [s]
;@returns
;  R20 := 0
;  R21 := 0
;  R22 := 0
DELAY: LDI r20,106	;212 for 1 second, 106 for 0.5 second
	L1: LDI R21, 100
	L2: LDI R22, 150
	L3: NOP
		NOP
		DEC R22
		BRNE L3
		DEC R21
		BRNE L2
		DEC R20
		BRNE L1

	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM MEMORY

;table for operating conditions
OP_CONDITIONS:
;time delays in [*1/2 s]
	;on time,on pattern,off time,off pattern
	.db	1,0x25,3,0x00
	.db	2,0x51,2,0x00
	.db	3,0x75,1,0x00
	.db	4,0x51,4,0x00
	.db	0,0x00	;NULL terminator
