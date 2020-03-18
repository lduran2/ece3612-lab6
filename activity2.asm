;
; ECE 3613 Lab 6 Activity 2.asm
;
; Created: 3/18/2020 1:45:00 AM
; Author : Leomar Duran
; Board  : ATmega324PB Xplained Pro - 2505
; For    : ECE 3612, Spring 2020
;
; This demo cycles through the ASCII characters [' ','`'[ with a 2
; second delay for each character.
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACROS

.equ	C_FLAG=0	;carry flag of the status register
.equ	Z_FLAG=1	; zero flag of the status register

;LoaD Immediate to Word: loads a word value into a word register
;@params
;  @0:@1 -- the word register (little endian)
;  @2    -- the word value to load
.macro	ldiw
	ldi	@0,high(@2)	;the high byte
	ldi	@1, low(@2)	;the  low byte
.endmacro	;ldiw

;BRanch if Immediate Not Equal to Word: compares a word value to a
;word register and branches if equal
;
;@params
;  @0:@1 -- the word register (little endian) whereto to compare
;  @2    -- the word value whereby to compare
;  @3    -- label whereto to branch on inequality
.macro	brinew
	cpi	@1, low(@2)	;compare the low byte
	brne	@3	;branch if not equal
	cpi	@0,high(@2)	;compare the high byte
	brne	@3	;branch if not equal
.endmacro	;brieqw


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEGIN PROGRAM

;set up PORTA for output
	ldi	r16,0xFF	;to PORT A
	out	DDRA,r16	;all outputs
;set up the stack pointer
	ldiw	r16,r17,RAMEND	;load to registers
	out	SPH,r16	;store the stack pointer high byte
	out	SPL,r17	;store the stack pointer low byte

;initializes the Z pointer for the message
INIT_DISPLAY:
	
	ldiw	ZH,ZL, ASCII_TABLE << 1	;set the Z pointer to
		;ASCII_TABLE
;reads, decodes and displays the next character in the MESSAGE,
;and correspondingly decides the delay
DISPLAY_LOOP:
	lpm	r16,Z+	;read the next bit pattern from program memory
	brinew	ZH,ZL, END_ASCII_TABLE << 1,	CONT_DISPLAY	;continue
	;the loop if the Z Pointer has not reached the end of
	;the ASCII_TABLE
	rjmp	INIT_DISPLAY	;if it has, initialize Z pointer again
CONT_DISPLAY:
	out	PORTA,r16	;write the bit pattern to PORTA
	ldi	r18,4	;delay = 2/2 s
;delays by (r18) [1/2 s]
DELAY_LOOP:
	rcall	delay	;perform the delay
	dec	r18	;count down the delay [*1/2 s]
	brne	DELAY_LOOP	;delay again
	rjmp	DISPLAY_LOOP	;repeat the display loop
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

;bit patterns for ASCII characters
ASCII_TABLE:
;*unsupported: #$%& ()*+, :;<>? @
;      [space],       !'.,         ",        #*,        $*,        %*,        &*,         '
.db 0b00000000,0b10000010,0b00100010,0b00000000,0b00000000,0b00000000,0b00000000,0b00000010
;           (*,        )*,        **         +*,        ,*,         -,        .*,         /
.db 0b00000000,0b00000000,0b00000000,0b00000000,0b00000000,0b01000000,0b10000000,0b01010010
;            0,         1,         2,         3,         4,         5,         6,         7
.db 0b00111111,0b00000110,0b01011011,0b01001111,0b01100110,0b01101101,0b01111101,0b00000111
;            8,         9,        :*,        ;*,        <*,         =,        >*,        ?*
.db 0b01111111,0b01101111,0b00000000,0b00000000,0b00000000,0b01001000,0b00000000,0b00000000
;           @*,         A,        Bb,         C,        Dd,         E,         F,         G
.db 0b00000000,0b01110111,0b01111100,0b00111001,0b01011110,0b01111001,0b01110001,0b00111101
;            H,         I,         J,         K,         L,      M\~n,        Nn,        Oo
.db 0b01110110,0b00110000,0b00011110,0b01110101,0b00111000,0b01010101,0b01010100,0b01011100
;            P,         Q,        Rr,         S,        Tt,         U          V,      W\-u
.db 0b01110011,0b01101011,0b01010000,0b01101101,0b01111000,0b00111110,0b00101110,0b00011101
;         X\Xi,        Yy,         Z          [,        \*,         ],         ^,         _
.db 0b01001001,0b01101110,0b01011011,0b00111001,0b01100100,0b00001111,0b00100011,0b00001000
END_ASCII_TABLE:
