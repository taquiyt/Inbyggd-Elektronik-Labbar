/* comp_value.c  use 16F690 as standalone comparator */
/* measure the voltage at IN2- pin with AD           */
/* B Knudsen Cc5x C-compiler - not ANSI-C            */
#include "16F690.h"
#pragma config |= 0x00D4

void initserial( void );
void putchar( char );
void string_out( const char * ); 
void longDecimal_out(long number, char decimalPlaces, bit un_signed); 
void delay10( char );
 
void main( void)
{
  C2CH0   = 0;
  C2CH1   = 1;  /* select ch 2 IN2-    pin 14 */
  C2R     = 0;  /* reference selectIN+ pin 16 */
  C2POL   = 0;  /* don't invert output        */
  SR1     = 0;  /* don't use SR-latch         */
  C2OE    = 1;  /* out direct to       pin  6 */
  C2ON    = 1;  /* C2 on                      */
  ANSEL.4 = 1;  /* RC0 analog input           */
  ANSEL.6 = 1;  /* RC2 analog input           */
  TRISC.0 = 1;  /* RC0 input           pin 16 */
  TRISC.2 = 1;  /* RC2 input           pin 14 */
  TRISC.4 = 0;  /* RC4 output          pin  6 */
  
  /* AD-converter and Comparator can use same input pin!    */
  ADCON1 = 0b0.101.0000;   /* AD conversion clock 'fosc/16' */
  ADCON0 = 0b1.0.0110.0.1; /* AD-channel 6 pin 14           */ 
  TRISB.0 = 1;             /* RB0 SW input                  */
  
  unsigned long advalue;
  
  initserial();
  delay10(100); 

  // Header text
  string_out("U [V]\r\n");
  
  while(1)
    {
      while(PORTB.6) ; /* wait for key pressed - new measurement */

	  GO=1;         // start AD
      while(GO);    // wait for done
      advalue  = ADRESH*256;    /* read result 10 bit */
      advalue += ADRESL; 
	  advalue *= 49;
      longDecimal_out(advalue, 4, 1); 
      putchar('\r'); putchar('\n');  /* new line before next value */
      delay10(1);         // Debounce	  
      while (!PORTB.6) ;  // wait for key released
      delay10(1);         // Debounce
    } 
}


/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */

/* **** bitbanging serial communication **** */

void initserial( void )  /* initialise PIC16F690 bbCom */
{
   ANSEL.0 = 0; // No AD on RA0
   ANSEL.1 = 0; // No AD on RA1
   PORTA.0 = 1; // marking line
   TRISA.0 = 0; // output to PK2 UART-tool
   TRISA.1 = 1; // input from PK2 UART-tool
   return;      
}

void putchar( char ch )  // sends one char bitbanging
{
  char bitCount, ti;
  PORTA.0 = 0; // set startbit
  for ( bitCount = 10; bitCount > 0 ; bitCount-- )
   {
     // delay one bit 104 usec at 4 MHz
     // 5+18*5-1+1+9=104 without optimization 
     ti = 18; do ; while( --ti > 0); nop(); 
     Carry = 1;     // stopbit
     ch = rr( ch ); // Rotate Right through Carry
     PORTA.0 = Carry;
   }
  return;
}

void string_out(const char * string)
{
  char i, k;
  for(i = 0 ; ; i++)
   {
     k = string[i];
     if( k == '\0') return;   // found end of string
     putchar(k); 
   }
  return;
}

/* **** print decimal number function **** */

void longDecimal_out(long number, char decimalPlaces, bit un_signed)
{
   char string[7]; // temporary buffer for reordering characters
   char i,temp;
   string[6] = '\0';
   string[0] = '+'; 
 if(!un_signed)
  {
    if (number < 0 )
     {
       string[0] = '-'; 
       number = -number;
     }
  } 
  
   for (i = 5; ;i--)
     {
       temp = (uns16)number % 10;
       temp += '0';
       string[i]=temp;
       if (i==1) break;
       (uns16)number /= 10;
     }
   for(i = 0 ; ; i++)
     {
        if(i==6-decimalPlaces) putchar(','); 
        temp = string[i];
        if( temp == '\0') return;   // found end of string
        putchar(temp); 
     }
} 



/* **** delay function **** */

void delay10( char n)
/*
  Delays a multiple of 10 milliseconds using the TMR0 timer
  Clock : 4 MHz   => period T = 0.25 microseconds
  1 IS = 1 Instruction Cycle = 1 microsecond
  error: 0.16 percent. B Knudsen.
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
            _____________  ____________    
           |             \/            | 
     +5V---|Vdd        16F690       Vss|---GND
           |RA5               RA0/(PGD)|bbTx ->- PK2Rx
           |RA4/AN3   AN1/REF/RA1/(PGC)|
           |RA3/!MCLR/(Vpp) RA2/AN2/INT|
           |RC5/CCP       RC0/AN4/C2IN+|-<- cmp+
cmp out -<-|RC4/C2OUT               RC1|
           |RC3         RC2/AN6/C12IN2-|-<- cmp- POT
           |RC6                     RB4|
           |RC7                  RB5/Rx|
           |RB7/Tx                  RB6|
           |___________________________|
*/
