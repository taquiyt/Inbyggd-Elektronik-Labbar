
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  23. Mar 2017  10:13  *************

	processor  16F690
	radix  DEC

	__config 0xD4

TMR0        EQU   0x01
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
OPTION_REG  EQU   0x81
PORTC       EQU   0x07
TRISC       EQU   0x87
n           EQU   0x20
i           EQU   0x21

	GOTO main

  ; FILE blinka.c
			;/* blinka.c  PICkit 2 LPC DS1 or breadboard  */ 
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;#include "16F690.h"
			;#pragma config |= 0x00D4 
			;void delay10( char );
			; 
			;void main( void)
			;{
main
			;  TRISC.0 = 0;  /* PORTC pin 0 output */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   TRISC,0
			;  
			;  while(1)
			;    {
			;       delay10(10);
m001	MOVLW 10
	CALL  delay10
			;	   PORTC.0 = 1; /* PORTC pin 0 "1" */
	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   PORTC,0
			;	   delay10(10);
	MOVLW 10
	CALL  delay10
			;	   PORTC.0 = 0; /* PORTC pin 0 "0" */
	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   PORTC,0
			;    }
	GOTO  m001
			;}
			;
			;
			;/* *********************************** */
			;/*            FUNCTIONS                */
			;/* *********************************** */
			;
			;
			;void delay10( char n)
			;/*
			;  Delays a multiple of 10 milliseconds using the TMR0 timer
			;  Clock : 4 MHz   => period T = 0.25 microseconds
			;  1 IS = 1 Instruction Cycle = 1 microsecond
			;  error: 0.16 percent
			;*/
			;{
delay10
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF n
			;    char i;
			;
			;    OPTION = 7;
	MOVLW 7
	BSF   0x03,RP0
	MOVWF OPTION_REG
			;    do  {
			;        i = TMR0 + 39; /* 256 microsec * 39 = 10 ms */
m002	MOVLW 39
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF TMR0,W
	MOVWF i
			;        while ( i != TMR0)
m003	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i,W
	XORWF TMR0,W
	BTFSS 0x03,Zero_
			;            ;
	GOTO  m003
			;    } while ( --n > 0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ n,1
	GOTO  m002
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x000F P0   22 word(s)  1 % : delay10
; 0x0001 P0   14 word(s)  0 % : main

; RAM usage: 2 bytes (2 local), 254 bytes free
; Maximum call level: 1
;  Codepage 0 has   37 word(s) :   1 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 37 code words (0 %)
