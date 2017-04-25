/* speed.c  motor speed from pot   */

/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16f690.h"
#pragma config |= 0x00D4

void main(void)
{
  unsigned int Duty;
  TRISC.7  = 1; /* RC7 AN9 Pot input         */
  ANSELH.1 = 1; /* AN9 analog input          */
  TRISC.4  = 0; /* RC4 P1B PWM+  output      */
  ANSEL.4  = 0; /* RC4 digital               */
  TRISC.2  = 0; /* RC2 P1D PWM-  output      */
  ANSEL.2  = 0; /* RC2 digital               */

  /* AD setup */ 
 
  ADCON1 = 0b0.101.0000; /* AD conversion clock 'fosc/16' */
  /* 
     0.x.xxxx.x.x  ADRESH:ADRESL is 10 bit left justified
     x.0.xxxx.x.x  Vref is Vdd
     x.x.1001.x.x  Channel 9 (AN9/RC7)
     x.x.xxxx.0.x  Go/!Done start later
     x.x.xxxx.x.1  Enable AD-converter
  */
  ADCON0 = 0b0.0.1001.0.1; 

  /* Setup TIMER2 */
  /*
  0.xxxx.x.xx  - unimplemented
  x.0000.x.xx  Postscaler 1:1 (not used)
  x.xxxx.1.xx  TMR2 is on
  x.xxxx.x.00  Prescaler 1 (as fast as possible)
  */
  T2CON = 0b0.0000.1.01;   

  /* Setup CCP1 PWM-mode  */ 
  /*
  01.xx.xxxx  PWM Full bridge forward
  xx.00.xxxx  PWM DutyCycle Two LSB not used
  xx.xx.1100  1100 Full bridge with not inverted outputs
  */
  CCP1CON = 0b01.00.1100 ;               

  PR2 = 255; /* full 8 bit Duty */

  while(1)
  {
    GO=1;          /* start AD                                       */
    while(GO);     /* wait for done                                  */
    Duty = ADRESH; /* only using the 8 MSB of ADRES (=ADRESH)        */

      /* make changes when pot is used for two directions! */
      if(Duty < 128)  
	     {
           /* set direction reverse */
           Duty = Duty; /* make change to reverse code */
		 }
	  else 
	    {
          /* set direction forward */		
		   Duty = Duty; /* make change to forward code */
	    }
     //Duty *= 2;  /* you need to rescale when pot is used for two directions! */
     CCPR1L = (unsigned int) Duty;  /* update PWM-value  */
  }
}




/* *********************************** */
/*            HARDWARE                 */
/* *********************************** */


/*
           ___________  ___________ 
          |           \/           |
   +5V ---|Vdd      16F690      Vss|--- GND
          |RA5        RA0/AN0/(PGD)|
          |RA4            RA1/(PGC)|
          |RA3/!MCLR/(Vpp)  RA2/INT|
          |RC5/CCP              RC0|
  PWM+ -<-|RC4/P1B              RC1|
          |RC3              RC2/P1D|->- PWM-
          |RC6                  RB4|
   Pot ->-|RC7/AN9           RB5/Rx|
          |RB7/Tx               RB6|
          |________________________| 
*/  

