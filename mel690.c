/* mel690.c  Play a melody */

/*    Low pin count demo board               J1      ----------
         ___________  ___________           1 RA5 --| earphone |
        |           \/           |          2 RA4 --| earphone |
  +5V---|Vdd     16F690       Vss|---GND    3 RA3    ----------
     ---|RA5        RA0/AN0/(PGD)|-<-RP1    4 RC5
     ---|RA4            RA1/(PGC)|---       5 RC4
  SW1---|RA3/!MCLR/(Vpp)  RA2/INT|---       6 RC3
     ---|RC5/CCP              RC0|->-DS1    7 RA0
     ---|RC4                  RC1|->-DS2    8 RA1
  DS4-<-|RC3                  RC2|->-DS3    9 RA2
        |RC6                  RB4|         10 RC0
        |RC7               RB5/Rx|         11 RC1
        |RB7/Tx               RB6|         12 RC2
        |________________________|         13 +5V
                                           14 GND
*/

/* Connect high impedance earphone to J1:1 and J1:2 */
/* B Knudsen Cc5x C-compiler - not ANSI-C           */
#include "16F690.h"
#pragma config |= 0x00D4

#include "lookup.c"
#include "delays.c"
#define EIGHT_NOTE 250
char LookUpNote(char);  /* function prototype */
void delay(char);

void  main(void)
{
  char note;
  bit out, button = 1;
  PORTA = 0;
  TRISA.5 = 0; /* RB5 will act as "ground-pin" for earphone */
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


