/* color.c  rgb-led                       */ 
/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 
#define ON 0   /* LEDs are commom anode, active low */
#define OFF 1
 
void main( void)
{
  TRISC.0=0;
  TRISC.1=0;
  TRISC.2=0;
  
  /* colormix change proportions for different mix */
  char R_Duty = 128;
  char G_Duty = 128;
  char B_Duty = 128;
  
  char colormix = 0;
  OPTION = 0b11000101;    /* Timer0 Prescaler divide by 64   */
 
  while(1)
    {
       /* PWM-generation   */
       if (TMR0 < R_Duty) colormix.0 = ON; /* Red PWM   */
       else colormix.0 = OFF;
       
       if (TMR0 < G_Duty) colormix.1 = ON; /* Green PWM */
       else colormix.1 = OFF;

       if (TMR0 < B_Duty) colormix.2 = ON; /* Blue PWM  */
       else colormix.2 = OFF;
	   PORTC = colormix;
    }
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
              |RC5/CCP              RC0|->- LED-B
              |RC4                  RC1|->- LED-R
              |RC3                  RC2|->- LED-G
              |RC6                  RB4|
              |RC7               RB5/Rx|
              |RB7/Tx               RB6|
              |________________________|

*/
