/* mel.c  Play a melody */
/* Connect high impedance earphone to RA5 and GND */

/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4

#include "lookup.c"
#define EIGHT_NOTE 250

char LookUpNote(char);  /* function prototype */
void delay(char);

void  main(void)
{
  char note;
  bit out, button = 1;
  TRISA.3 = 1; /* SW1 input                                 */
  delay(100);  /* 100 ms for demo board initialization      */
  OPTION = 0b111; /* Timer0 Prescaler divide by 256         */

  while(1)
   {
     char i;   
     for(i=0;;i++)
     {
       note = LookUpNote(i);
       if( note == 0 ) break;
       if( note == 1 ) TRISA.4 = 1;  /* pause note is silent */
       else TRISA.4 =  0;            /* RA4 is output        */
          TMR0 = 0;                  /* Reset timer0         */
          while (TMR0 < EIGHT_NOTE)  /* "1/8"-note duration  */
      	    {
              char j;
              for(j = note; j > 0; j--) 
                { /* Delay. Loop + 4 nop()'s totals 10 us  */
                  nop(); nop(); nop(); nop();
                }
              /* Toggle Output bit RA4 On/Off */
              out = !out; 
              PORTA.4 = out;
            }
     }
    while(PORTA.3 == 1){ /* wait */ } /* SW1 to play again */ 
   }
}


/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */

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
  earphone -<-|RA4            RA1/(PGC)|
        SW1->-|RA3/!MCLR/(Vpp)  RA2/INT|
              |RC5/CCP              RC0|
              |RC4                  RC1|
              |RC3                  RC2|
              |RC6                  RB4|
              |RC7               RB5/Rx|
              |RB7/Tx               RB6|
              |________________________|

*/




