/* onoff.c Inbyggd Elektronik Lab1       */ 
/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 

void init( void );

void main( void)
{
  init();
  
  while(1)
    {
      if(!PORTB.6) PORTC.0 = 1; /* PORTC LED0 ON  */
      else PORTC.0 = 0;         /* PORTC LED0 OFF */
    }
}


/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */

void init( void )
{
  TRISC.0 = 0;  /* PORTC pin 0 output */
  TRISB.6 = 1;  /* PORTB pin 6 input  */
  PORTC.0 = 0;  /* PORTC pin 0 "0"    */
	OPTION.7=0;
	WPUB.6=1;
	
  /* Later on in lab - insert "weak pullup" for RB6. */
  /* Preparation task is to find out how?            */

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
            |RB7/Tx                   RB6|-<-Butt
            |____________________________|
                                          
*/ 
