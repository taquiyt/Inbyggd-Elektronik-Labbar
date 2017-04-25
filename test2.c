/* test2.c  Multiplication                */
/* No hardware needed                     */
/* B Knudsen Cc5x C-compiler - not ANSI-C */

#include "16F690.h"
#pragma config |= 0x00D4

void main( void)
{
  unsigned int a,b;
  unsigned long c;
  c=(unsigned long)a * (unsigned long)b;
}

