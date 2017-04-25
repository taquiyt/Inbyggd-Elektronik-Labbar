
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  21. Apr 2017   8:32  *************

	processor  16F690
	radix  DEC

	__config 0xD4

TMR0        EQU   0x01
PCL         EQU   0x02
TRISB       EQU   0x86
PCLATH      EQU   0x0A
Carry       EQU   0
RP0         EQU   5
RP1         EQU   6
OPTION_REG  EQU   0x81
TRISC       EQU   0x87
ANSEL       EQU   0x11E
ANSELH      EQU   0x11F
RS          EQU   4
EN          EQU   6
D7          EQU   3
D6          EQU   2
D5          EQU   1
D4          EQU   0
i           EQU   0x20
x           EQU   0x21
x_2         EQU   0x21
data        EQU   0x21
millisec    EQU   0x22

	GOTO main

  ; FILE hello_lcd.c
			;/* hello_lcd.c  */
			;
			;#include "16F690.h"
			;#pragma config |= 0x00D4 
			;
			;/* I/O-pin definitions                               */ 
			;/* change if you need a pin for a different purpose  */
			;#pragma bit RS  @ PORTB.4
			;#pragma bit EN  @ PORTB.6
			;
			;#pragma bit D7  @ PORTC.3
			;#pragma bit D6  @ PORTC.2
			;#pragma bit D5  @ PORTC.1
			;#pragma bit D4  @ PORTC.0
			;
			;void delay( char ); // ms delay function
			;void lcd_init( void );
			;void lcd_putchar( char );
			;char text1( char );
			;char text2( char );
			;
			;void main( void)
			;{
main
			;    /* I/O-pin direction in/out definitions, change if needed  */
			;	ANSEL=0; 	//  PORTC digital I/O
	BCF   0x03,RP0
	BSF   0x03,RP1
	CLRF  ANSEL
			;	ANSELH=0;
	CLRF  ANSELH
			;	TRISC = 0b1111.0000;  /* RC3,2,1,0 out*/
	MOVLW 240
	BSF   0x03,RP0
	BCF   0x03,RP1
	MOVWF TRISC
			;    TRISB.4=0; /* RB4, RB6 out */
	BCF   TRISB,4
			;    TRISB.6=0;	
	BCF   TRISB,6
			;
			;    char i;
			;    lcd_init();
	CALL  lcd_init
			;
			;    RS = 1;  // LCD in character-mode
	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x06,RS
			;    // display the 8 char text1() sentence
			;    for(i=0; i<8; i++) lcd_putchar(text1(i)); 
	CLRF  i
m001	MOVLW 8
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF i,W
	BTFSC 0x03,Carry
	GOTO  m002
	MOVF  i,W
	CALL  text1
	CALL  lcd_putchar
	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i,1
	GOTO  m001
			;
			;   // reposition to "line 2" (the next 8 chars)
			;    RS = 0;  // LCD in command-mode
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   0x06,RS
			;    lcd_putchar( 0b11000000 );
	MOVLW 192
	CALL  lcd_putchar
			;  
			;    RS = 1;  // LCD in character-mode
	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x06,RS
			;    // display the 8 char text2() sentence
			;    for(i=0; i<8; i++) lcd_putchar(text2(i)); 
	CLRF  i
m003	MOVLW 8
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF i,W
	BTFSC 0x03,Carry
	GOTO  m004
	MOVF  i,W
	CALL  text2
	CALL  lcd_putchar
	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i,1
	GOTO  m003
			;   
			;    while(1) nop();
m004	NOP  
	GOTO  m004
			;}
			;
			;
			;
			;/* *********************************** */
			;/*            FUNCTIONS                */
			;/* *********************************** */
			;
			;
			;char text1( char x)   // this is the way to store a sentence
			;{
text1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF x
			;   skip(x); /* internal function CC5x.  */
	CLRF  PCLATH
	MOVF  x,W
	ADDWF PCL,1
			;   #pragma return[] = "Hello wo"    // 8 chars max!
	RETLW 72
	RETLW 101
	RETLW 108
	RETLW 108
	RETLW 111
	RETLW 32
	RETLW 119
	RETLW 111
			;}
			;
			;char text2( char x)   // this is the way to store a sentence
			;{
text2
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF x_2
			;   skip(x); /* internal function CC5x.  */
	CLRF  PCLATH
	MOVF  x_2,W
	ADDWF PCL,1
			;   #pragma return[] = "rld!    "    // 8 chars max!
	RETLW 114
	RETLW 108
	RETLW 100
	RETLW 33
	RETLW 32
	RETLW 32
	RETLW 32
	RETLW 32
			;}
			;
			;
			;void lcd_init( void ) // must be run once before using the display
			;{
lcd_init
			;  delay(40);  // give LCD time to settle
	MOVLW 40
	CALL  delay
			;  RS = 0;     // LCD in command-mode
	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   0x06,RS
			;  lcd_putchar(0b0011.0011); /* LCD starts in 8 bit mode          */
	MOVLW 51
	CALL  lcd_putchar
			;  lcd_putchar(0b0011.0010); /* change to 4 bit mode              */
	MOVLW 50
	CALL  lcd_putchar
			;  lcd_putchar(0b00101000);  /* two line (8+8 chars in the row)   */ 
	MOVLW 40
	CALL  lcd_putchar
			;  lcd_putchar(0b00001100);  /* display on, cursor off, blink off */
	MOVLW 12
	CALL  lcd_putchar
			;  lcd_putchar(0b00000001);  /* display clear                     */
	MOVLW 1
	CALL  lcd_putchar
			;  lcd_putchar(0b00000110);  /* increment mode, shift off         */
	MOVLW 6
	CALL  lcd_putchar
			;  RS = 1;    // LCD in character-mode
	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x06,RS
			;             // initialization is done!
			;}
	RETURN
			;
			;
			;void lcd_putchar( char data )
			;{
lcd_putchar
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF data
			;  // must set LCD-mode before calling this function!
			;  // RS = 1 LCD in character-mode
			;  // RS = 0 LCD in command-mode
			;  // upper Nybble
			;  D7 = data.7;
	BTFSS data,7
	BCF   0x07,D7
	BTFSC data,7
	BSF   0x07,D7
			;  D6 = data.6;
	BTFSS data,6
	BCF   0x07,D6
	BTFSC data,6
	BSF   0x07,D6
			;  D5 = data.5;
	BTFSS data,5
	BCF   0x07,D5
	BTFSC data,5
	BSF   0x07,D5
			;  D4 = data.4;
	BTFSS data,4
	BCF   0x07,D4
	BTFSC data,4
	BSF   0x07,D4
			;  EN = 0;
	BCF   0x06,EN
			;  nop();
	NOP  
			;  EN = 1;
	BSF   0x06,EN
			;  delay(5);
	MOVLW 5
	CALL  delay
			;  // lower Nybble
			;  D7 = data.3;
	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS data,3
	BCF   0x07,D7
	BTFSC data,3
	BSF   0x07,D7
			;  D6 = data.2;
	BTFSS data,2
	BCF   0x07,D6
	BTFSC data,2
	BSF   0x07,D6
			;  D5 = data.1;
	BTFSS data,1
	BCF   0x07,D5
	BTFSC data,1
	BSF   0x07,D5
			;  D4 = data.0;
	BTFSS data,0
	BCF   0x07,D4
	BTFSC data,0
	BSF   0x07,D4
			;  EN = 0;
	BCF   0x06,EN
			;  nop();
	NOP  
			;  EN = 1;
	BSF   0x06,EN
			;  delay(5);
	MOVLW 5
	GOTO  delay
			;}
			;
			;void delay( char millisec)
			;/* 
			;  Delays a multiple of 1 milliseconds at 4 MHz (16F628 internal clock)
			;  using the TMR0 timer 
			;*/
			;{
delay
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF millisec
			;    OPTION = 2;  /* prescaler divide by 8        */
	MOVLW 2
	BSF   0x03,RP0
	MOVWF OPTION_REG
			;    do  {
			;        TMR0 = 0;
m005	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  TMR0
			;        while ( TMR0 < 125)   /* 125 * 8 = 1000  */
m006	MOVLW 125
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF TMR0,W
	BTFSS 0x03,Carry
			;            ;
	GOTO  m006
			;    } while ( -- millisec > 0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ millisec,1
	GOTO  m005
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x0095 P0   20 word(s)  0 % : delay
; 0x0051 P0   21 word(s)  1 % : lcd_init
; 0x0066 P0   47 word(s)  2 % : lcd_putchar
; 0x0035 P0   14 word(s)  0 % : text1
; 0x0043 P0   14 word(s)  0 % : text2
; 0x0001 P0   52 word(s)  2 % : main

; RAM usage: 3 bytes (3 local), 253 bytes free
; Maximum call level: 3
;  Codepage 0 has  169 word(s) :   8 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 169 code words (4 %)
