
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  23. Mar 2017  10:25  *************

	processor  16F690
	radix  DEC

	__config 0xD4

Carry       EQU   0
RP0         EQU   5
RP1         EQU   6
a           EQU   0x20
b           EQU   0x21
c           EQU   0x22

	GOTO main

  ; FILE test1.c
			;/* test1.c add with 16-bit variable       */
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
	BCF   0x03,RP0
			;  unsigned long c;
		;  c=(unsigned long)a + (unsigned long)b;
	BCF   0x03,RP1
	CLRF  c+1
	MOVF  b,W ; W=b
	ADDWF a,W;W+=a
	MOVWF c ; c=W
	BTFSC 0x03,Carry;if(Carry) kör insctruction else skip!
	INCF  c+1,1
			;}
	SLEEP
	GOTO main
	

	END


; *** KEY INFO ***
; 0x0001 P0   10 word(s)  0 % : main


; RAM usage: 4 bytes (4 local), 252 bytes free
; Maximum call level: 0
;  Codepage 0 has   11 word(s) :   0 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 11 code words (0 %)
