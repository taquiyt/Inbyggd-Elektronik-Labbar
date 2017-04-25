/* toggle.c Inbyggd Elektronik Lab1       */ 
/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 

void init(void);
void delay10( char );
 
void main( void)
{
  init();
  bit led = 0;
  
  while(1)
    {
      while(PORTB.6==1)  ;  /* wait for Butt=0, pressed  */
      led = !led;
      PORTC.0 = led;        /* LED0, toggle              */
      /* Later on in lab - uncomment to insert the debounce delay */	  
      //delay10(10);  
      while(PORTB.6==0) ; /* wait for Butt=1, released */
      /* Later on in lab - uncomment to insert the debounce delay */	  
       delay10(10); 
    }
}





/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */

void init(void)
{
  TRISC.0 = 0;  /* PORTC pin 0 output */
  TRISB.6 = 1;  /* PORTB pin 6 input  */
  PORTC.0 = 0;  /* PORTC pin 0 "0"    */

  /* Later on in lab - insert "weak pullup" for RB6. */
  /* Preparation task is to find out how?            */
  /* settings for OPTION register and RAPU register  */

}


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
            |RB7/Tx                   RB6|-<-Butt
            |____________________________|
                                          
*/ 
