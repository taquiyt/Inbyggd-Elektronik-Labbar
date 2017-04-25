/* rmw.c  */ 
/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 
 
void main( void)
{
  TRISC.0 = 0;  /* PORTC pin 0 output */
  TRISC.1 = 0;  /* PORTC pin 1 output */

  PORTC.0 = 1; /* PORTC pin 0 "1" */
  PORTC.0 = 0; /* PORTC pin 0 "0" */
  while(1) ;
}

