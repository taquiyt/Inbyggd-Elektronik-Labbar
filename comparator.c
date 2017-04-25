/* comparator.c  use 16F690 as standalone comparator */
/* B Knudsen Cc5x C-compiler - not ANSI-C            */
#include "16F690.h"
#pragma config |= 0x00D4 
 
void main( void)
{
  C2CH0   = 0;
  C2CH1   = 1;  /* select ch 2 IN2-     pin 14 */
  C2R     = 0;  /* reference select IN+ pin 16 */
  C2POL   = 0;  /* don't invert output         */
  SR1     = 0;  /* don't use SR-latch          */
  C2OE    = 1;  /* out direct to        pin  6 */
  C2ON    = 1;  /* C2 on                       */
  ANSEL.4 = 1;  /* RC0 analog input            */
  ANSEL.6 = 1;  /* RC2 analog input            */
  TRISC.0 = 1;  /* RC0 input            pin 16 */
  TRISC.2 = 1;  /* RC2 input            pin 14 */
  TRISC.4 = 0;  /* RC4 output           pin  6 */
  
  while(1) nop();
}



/* *********************************** */
/*            HARDWARE                 */
/* *********************************** */


/*
            _____________  ____________    
           |             \/            | 
     +5V---|Vdd        16F690       Vss|---GND
           |RA5               RA0/(PGD)|
           |RA4/AN3   AN1/REF/RA1/(PGC)|
           |RA3/!MCLR/(Vpp) RA2/AN2/INT|
           |RC5/CCP           RC0/C2IN+|-<- cmp+
cmp out -<-|RC4/C2OUT               RC1|
           |RC3             RC2/C12IN2-|-<- cmp-
           |RC6                     RB4|
           |RC7                  RB5/Rx|
           |RB7/Tx                  RB6|
           |___________________________|
*/
