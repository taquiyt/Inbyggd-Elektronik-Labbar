/* test5.c  float NTC linearization       */
/* No hardware needed                     */
/* B Knudsen Cc5x C-compiler - not ANSI-C */

#include "16F690.h"
#include "math24f.h"
#include "math24lb.h"
#pragma config |= 0x00D4

void main( void)
{
  unsigned long int R_T;
  float T, temp1, temp2;
  const float A0 = 123.456;
  const float A1 = 345.678;
  // T=1/(A0+A1*log(R_T))
  temp1=log((float) R_T);
  temp2=A1*temp1;
  temp1=A0+temp2;
  T=1/temp1;  
}
