
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  23. Mar 2017  10:59  *************

	processor  16F690
	radix  DEC

	__config 0xD4

Carry       EQU   0
RP0         EQU   5
RP1         EQU   6
a           EQU   0x20
b           EQU   0x21
c           EQU   0x22
C1cnt       EQU   0x24
C2tmp       EQU   0x25

	GOTO main

  ; FILE test2.c
			;/* test2.c  Multiplication                */
			;/* No hardware needed                     */
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;
			;#include "16F690.h"
			;#pragma config |= 0x00D4
			;
			;void main( void)
			;{
main
			;  unsigned int a,b;
			;  unsigned long c;
			;  c=(unsigned long)a * (unsigned long)b;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  a,W
	MOVWF C2tmp
	CLRF  c
	MOVLW 8
	MOVWF C1cnt
m001	BCF   0x03,Carry
	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   c,1
	RLF   c+1,1
	RLF   C2tmp,1
	BTFSS 0x03,Carry
	GOTO  m002
	MOVF  b,W
	ADDWF c,1
	BTFSC 0x03,Carry
	INCF  c+1,1
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C1cnt,1
	GOTO  m001
			;}
	SLEEP
	GOTO main

	END


; *** KEY INFO ***

; 0x0001 P0   25 word(s)  1 % : main

; RAM usage: 7 bytes (7 local), 249 bytes free
; Maximum call level: 0
;  Codepage 0 has   26 word(s) :   1 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 26 code words (0 %)
