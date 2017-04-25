/* blinka.c  PICkit 2 LPC DS1 or breadboard  */ 
/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 
void delay10( char );
 
void main( void)
{
  TRISC.0 = 0;  /* PORTC pin 0 output */
  
  while(1)
    {
       delay10(10);
	   PORTC.0 = 1; /* PORTC pin 0 "1" */
	   delay10(10);
	   PORTC.0 = 0; /* PORTC pin 0 "0" */
    }
}


/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */


void delay10( char n)
/*
  Delays a multiple of 10 milliseconds using the TMR0 timer
  Clock : 4 MHz   => period T = 0.25 microseconds
  1 IS = 1 Instruction Cycle = 1 microsecond
  error: 0.16 percent
*/
{
    char i;

    OPTION = 7;
    do  {
        i = TMR0 + 39; /* 256 microsec * 39 = 10 ms */
        while ( i != TMR0)
            ;
    } while ( --n > 0);
}


/* *********************************** */
/*            HARDWARE                 */
/* *********************************** */

/*
             _____________  _____________ 
            |             \/             |
      +5V---|Vdd        16F690        Vss|---Gnd
            |RA5            RA0/AN0/(PGD)|
            |RA4/AN3            RA1/(PGC)|
            |RA3/!MCLR/(Vpp)  RA2/AN2/INT|
            |RC5/CCP                  RC0|->-LED0
            |RC4                      RC1|
            |RC3/AN7                  RC2|
            |RC6/AN8             AN10/RB4|
            |RC7/AN9               RB5/Rx|
            |RB7/Tx                   RB6|
            |____________________________|
                                          
*/
