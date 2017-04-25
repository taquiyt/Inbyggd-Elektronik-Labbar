
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  21. Apr 2017  14:29  *************

	processor  16F690
	radix  DEC

	__config 0xD4

RP0         EQU   5
RP1         EQU   6
T2CON       EQU   0x12
CCPR1L      EQU   0x15
CCP1CON     EQU   0x17
TRISC       EQU   0x87
PR2         EQU   0x92

	GOTO main

  ; FILE StepUp.c
			;/* StepUp.c PIC 16F690 PWM-signal to stepup converter  */
			;
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;#include "16F690.h"
			;#pragma config |= 0x00D4 
			;
			;void main(void)
			;{
main
			;   TRISC.5 = 0;              /* CCP1 output             */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   TRISC,5
			;   T2CON   = 0b00000.1.00;   /* prescale 1:1            */
	MOVLW 4
	BCF   0x03,RP0
	MOVWF T2CON
			;   CCP1CON = 0b00.00.1100;   /* PWM-mode                */
	MOVLW 12
	MOVWF CCP1CON
			;   PR2     = 255;            /* max value               */
	MOVLW 255
	BSF   0x03,RP0
	MOVWF PR2
			;   CCPR1L = 101; /* change this to your measured value  */
	MOVLW 101
	BCF   0x03,RP0
	MOVWF CCPR1L
			;     
			;   while(1) nop();  /* place to do other things! */
m001	NOP  
	GOTO  m001

	END


; *** KEY INFO ***

; 0x0001 P0   16 word(s)  0 % : main

; RAM usage: 0 bytes (0 local), 256 bytes free
; Maximum call level: 0
;  Codepage 0 has   17 word(s) :   0 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 17 code words (0 %)
