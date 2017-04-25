/* StepUp.c PIC 16F690 PWM-signal to stepup converter  */

/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 

void main(void)
{
   TRISC.5 = 0;              /* CCP1 output             */
   T2CON   = 0b00000.1.00;   /* prescale 1:1            */
   CCP1CON = 0b00.00.1100;   /* PWM-mode                */
   PR2     = 255;            /* max value               */
   CCPR1L = 101; /* change this to your measured value  */
     
   while(1) nop();  /* place to do other things! */
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
          |RA3/!MCLR/(Vpp)     RA2/INT|
PWMout -<-|RC5/CCP                 RC0|
          |RC4                     RC1|
          |RC3                 AN6/RC2|
          |RC6                     RB4|
          |RC7                  RB5/Rx|
          |RB7/Tx                  RB6|
          |___________________________|
*/


