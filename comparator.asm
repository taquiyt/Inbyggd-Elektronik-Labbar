
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  21. Apr 2017  13:34  *************

	processor  16F690
	radix  DEC

	__config 0xD4

RP0         EQU   5
RP1         EQU   6
TRISC       EQU   0x87
ANSEL       EQU   0x11E
C2CH0       EQU   0
C2CH1       EQU   1
C2R         EQU   2
C2POL       EQU   4
C2OE        EQU   5
C2ON        EQU   7
SR1         EQU   7

	GOTO main

  ; FILE comparator.c
			;/* comparator.c  use 16F690 as standalone comparator */
			;/* B Knudsen Cc5x C-compiler - not ANSI-C            */
			;#include "16F690.h"
			;#pragma config |= 0x00D4 
			; 
			;void main( void)
			;{
main
			;  C2CH0   = 0;
	BCF   0x03,RP0
	BSF   0x03,RP1
	BCF   0x11A,C2CH0
			;  C2CH1   = 1;  /* select ch 2 IN2-     pin 14 */
	BSF   0x11A,C2CH1
			;  C2R     = 0;  /* reference select IN+ pin 16 */
	BCF   0x11A,C2R
			;  C2POL   = 0;  /* don't invert output         */
	BCF   0x11A,C2POL
			;  SR1     = 0;  /* don't use SR-latch          */
	BSF   0x03,RP0
	BCF   0x19E,SR1
			;  C2OE    = 1;  /* out direct to        pin  6 */
	BCF   0x03,RP0
	BSF   0x11A,C2OE
			;  C2ON    = 1;  /* C2 on                       */
	BSF   0x11A,C2ON
			;  ANSEL.4 = 1;  /* RC0 analog input            */
	BSF   ANSEL,4
			;  ANSEL.6 = 1;  /* RC2 analog input            */
	BSF   ANSEL,6
			;  TRISC.0 = 1;  /* RC0 input            pin 16 */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   TRISC,0
			;  TRISC.2 = 1;  /* RC2 input            pin 14 */
	BSF   TRISC,2
			;  TRISC.4 = 0;  /* RC4 output           pin  6 */
	BCF   TRISC,4
			;  
			;  while(1) nop();
m001	NOP  
	GOTO  m001

	END


; *** KEY INFO ***

; 0x0001 P0   20 word(s)  0 % : main

; RAM usage: 0 bytes (0 local), 256 bytes free
; Maximum call level: 0
;  Codepage 0 has   21 word(s) :   1 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 21 code words (0 %)
