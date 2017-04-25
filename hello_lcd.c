/* hello_lcd.c  */

#include "16F690.h"
#pragma config |= 0x00D4 

/* I/O-pin definitions                               */ 
/* change if you need a pin for a different purpose  */
#pragma bit RS  @ PORTB.4
#pragma bit EN  @ PORTB.6

#pragma bit D7  @ PORTC.3
#pragma bit D6  @ PORTC.2
#pragma bit D5  @ PORTC.1
#pragma bit D4  @ PORTC.0

void delay( char ); // ms delay function
void lcd_init( void );
void lcd_putchar( char );
char text1( char );
char text2( char );

void main( void)
{
    /* I/O-pin direction in/out definitions, change if needed  */
	ANSEL=0; 	//  PORTC digital I/O
	ANSELH=0;
	TRISC = 0b1111.0000;  /* RC3,2,1,0 out*/
    TRISB.4=0; /* RB4, RB6 out */
    TRISB.6=0;	

    char i;
    lcd_init();

    RS = 1;  // LCD in character-mode
    // display the 8 char text1() sentence
    for(i=0; i<8; i++) lcd_putchar(text1(i)); 

   // reposition to "line 2" (the next 8 chars)
    RS = 0;  // LCD in command-mode
    lcd_putchar( 0b11000000 );
  
    RS = 1;  // LCD in character-mode
    // display the 8 char text2() sentence
    for(i=0; i<8; i++) lcd_putchar(text2(i)); 
   
    while(1) nop();
}



/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */


char text1( char x)   // this is the way to store a sentence
{
   skip(x); /* internal function CC5x.  */
   #pragma return[] = "Hello wo"    // 8 chars max!
}

char text2( char x)   // this is the way to store a sentence
{
   skip(x); /* internal function CC5x.  */
   #pragma return[] = "rld!    "    // 8 chars max!
}


void lcd_init( void ) // must be run once before using the display
{
  delay(40);  // give LCD time to settle
  RS = 0;     // LCD in command-mode
  lcd_putchar(0b0011.0011); /* LCD starts in 8 bit mode          */
  lcd_putchar(0b0011.0010); /* change to 4 bit mode              */
  lcd_putchar(0b00101000);  /* two line (8+8 chars in the row)   */ 
  lcd_putchar(0b00001100);  /* display on, cursor off, blink off */
  lcd_putchar(0b00000001);  /* display clear                     */
  lcd_putchar(0b00000110);  /* increment mode, shift off         */
  RS = 1;    // LCD in character-mode
             // initialization is done!
}


void lcd_putchar( char data )
{
  // must set LCD-mode before calling this function!
  // RS = 1 LCD in character-mode
  // RS = 0 LCD in command-mode
  // upper Nybble
  D7 = data.7;
  D6 = data.6;
  D5 = data.5;
  D4 = data.4;
  EN = 0;
  nop();
  EN = 1;
  delay(5);
  // lower Nybble
  D7 = data.3;
  D6 = data.2;
  D5 = data.1;
  D4 = data.0;
  EN = 0;
  nop();
  EN = 1;
  delay(5);
}

void delay( char millisec)
/* 
  Delays a multiple of 1 milliseconds at 4 MHz (16F628 internal clock)
  using the TMR0 timer 
*/
{
    OPTION = 2;  /* prescaler divide by 8        */
    do  {
        TMR0 = 0;
        while ( TMR0 < 125)   /* 125 * 8 = 1000  */
            ;
    } while ( -- millisec > 0);
}


/* *********************************** */
/*            HARDWARE                 */
/* *********************************** */

/*
         ___________  ___________
        |           \/           |
  +5V---|Vdd     16F690       Vss|---GND
        |RA5        RA0/AN0/(PGD)|
        |RA4            RA1/(PGC)|
        |RA3/!MCLR/(Vpp)  RA2/INT|
        |RC5/CCP              RC0|->-D4
        |RC4                  RC1|->-D5
  D7 -<-|RC3                  RC2|->-D6
        |RC6                  RB4|->- RS
        |RC7               RB5/Rx|
        |RB7/Tx               RB6|->- EN
        |________________________| 

*/

/*
           LCD Line length 16 (8+8) characters
           Internal ic: KS0066U		   
           _______________
          |               |
          |         Vss  1|--- GND  
          |         Vdd  2|--- +5V
          |    Kontrast  3|-<- Pot
          |          RS  4|-<- RB4
          |      RD/!WR  5|--- 0, GND
          |          EN  6|-<- RB6
          |          D0  7|
          |          D1  8|
          |          D2  9|
          |          D3 10|
          |          D4 11|-<- RC0
          |          D5 12|-<- RC1 
          |          D6 13|-<- RC2
          |          D7 14|-<- RC3 
          |_______________|						  
*/


