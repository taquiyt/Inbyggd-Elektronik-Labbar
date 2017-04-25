
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  31. Mar 2017  14:12  *************

	processor  16F690
	radix  DEC

	__config 0xD4

TMR0        EQU   0x01
PORTB       EQU   0x06
TRISB       EQU   0x86
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
OPTION_REG  EQU   0x81
PORTC       EQU   0x07
TRISC       EQU   0x87
led         EQU   0
n           EQU   0x21
i           EQU   0x22
TtmpA32     EQU   0x20

	GOTO main

  ; FILE toggle.c
			;/* toggle.c Inbyggd Elektronik Lab1       */ 
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;#include "16F690.h"
			;#pragma config |= 0x00D4 
			;
			;void init(void);
			;void delay10( char );
			; 
			;void main( void)
			;{
main
			;  init();
	CALL  init
			;  bit led = 0;
	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   0x20,led
			;  
			;  while(1)
			;    {
			;      while(PORTB.6==1)  ;  /* wait for Butt=0, pressed  */
m001	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC PORTB,6
	GOTO  m001
			;      led = !led;
	MOVLW 1
	BCF   0x03,RP0
	BCF   0x03,RP1
	XORWF TtmpA32,1
			;      PORTC.0 = led;        /* LED0, toggle              */
	BTFSS 0x20,led
	BCF   PORTC,0
	BTFSC 0x20,led
	BSF   PORTC,0
			;      /* Later on in lab - uncomment to insert the debounce delay */	  
			;      //delay10(10);  
			;      while(PORTB.6==0) ; /* wait for Butt=1, released */
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS PORTB,6
	GOTO  m002
			;      /* Later on in lab - uncomment to insert the debounce delay */	  
			;       delay10(10); 
	MOVLW 10
	CALL  delay10
			;    }
	GOTO  m001
			;}
			;
			;
			;
			;
			;
			;/* *********************************** */
			;/*            FUNCTIONS                */
			;/* *********************************** */
			;
			;void init(void)
			;{
init
			;  TRISC.0 = 0;  /* PORTC pin 0 output */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   TRISC,0
			;  TRISB.6 = 1;  /* PORTB pin 6 input  */
	BSF   TRISB,6
			;  PORTC.0 = 0;  /* PORTC pin 0 "0"    */
	BCF   0x03,RP0
	BCF   PORTC,0
			;
			;  /* Later on in lab - insert "weak pullup" for RB6. */
			;  /* Preparation task is to find out how?            */
			;  /* settings for OPTION register and RAPU register  */
			;
			;}
	RETURN
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
m003	MOVLW 39
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF TMR0,W
	MOVWF i
			;        while ( i != TMR0)
m004	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i,W
	XORWF TMR0,W
	BTFSS 0x03,Zero_
			;            ;
	GOTO  m004
			;    } while ( --n > 0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ n,1
	GOTO  m003
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x0018 P0    7 word(s)  0 % : init
; 0x001F P0   22 word(s)  1 % : delay10
; 0x0001 P0   23 word(s)  1 % : main

; RAM usage: 3 bytes (3 local), 253 bytes free
; Maximum call level: 1
;  Codepage 0 has   53 word(s) :   2 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 53 code words (1 %)
