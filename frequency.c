/* frequency.c measure frequency on CCP-pin.        */
/* input frequency 100 Hz - 10 kHz  at CCP1-pin     */
/* Output 1 MHz clock for 4040 counter.             */


/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#include "math16.h"
/* RA4 is used as 1 MHz Clockout pin */
#pragma config |= 0xD5  

/*  function prototypes  */
void initserial( void );
void putchar( char );
void string_out( const char * ); 
void unsLong_out(unsigned long number);
void delay10( char );

void main( void)
{
   unsigned long T, f, t1, t2;
   TRISC.5 = 1;  /* CCP1-pin is input                 */
   TRISA.4 = 0;  /* Clockout is output                */

   initserial();
   delay10(100); /* 1 sek delay                  */
   /* 1 sek to turn on VDD and Connect UART-Tool */

/* Setup TIMER1 */
/*
00.xx.x.x.x.x  --
xx.00.x.x.x.x  Prescale 1/1
xx.xx.0.x.x.x  TMR1-oscillator is shut off
xx.xx.x.0.x.x  - (clock input synchronization)
xx.xx.x.x.0.x  Use internal clock f_osc/4
xx.xx.x.x.x.1  TIMER1 is ON
*/
   T1CON = 0b00.00.0.0.0.1 ;

/* Setup CCP1 */
/*
00.00.xxxx  -- --
xx.xx.0101  Capture each positive edge
*/
   CCP1CON = 0b00.00.0101 ;


while(1)
  {
    CCP1IF = 0 ;          /* reset flag            */
    while (CCP1IF == 0 ); /* wait for capture      */
    t1  = CCPR1H*256;
    t1 += CCPR1L;
    CCP1IF = 0 ;          /* reset flag            */
    while (CCP1IF == 0 ); /* wait for next capture */
    t2  = CCPR1H*256;
    t2 += CCPR1L;

    /* Calculations  */
    T = t2 - t1;          /* calculate period                 */
    f = 1000000/T;        /* calculate frequency              */
    delay10(100);         /* 1 sek delay between measurements */

    /* print values */
	string_out( "Frequency f is [Hz]: " );
    unsLong_out(f); 
    string_out( "  Period T is [us]: " );
    unsLong_out(T); 
   
    putchar('\r'); putchar('\n');

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
   TRISA.1 = 1; // input from PK2 UART-tool - not used
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
}



/* ******************************************** */

/* **** print decimal number function **** */

void unsLong_out(unsigned long number)
{
   char string[7]; // temporary buffer for reordering characters
   char i,temp;
   string[6] = '\0';
   string[0] = ' '; // place for sign. Not used this time.
 
  
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
        temp = string[i];
        if( temp == '\0') return;   // found end of string
        putchar(temp); 
     }
} 

/* ***************************************** */


/* **** delay function **** */

void delay10( char n)
{
    char i;
    OPTION = 7;
    do  {  i = TMR0 + 39; /* 256 microsec * 39 = 10 ms */
        while ( i != TMR0) ;
    } while ( --n > 0);
}


/* *********************************** */
/*            HARDWARE                 */
/* *********************************** */

/*
   Use "PICkit2 UART Tool" as a 9600 Baud terminal.
   PIC internal USART is not used. BitBanging routines.
   Measure unknown frequency at CCP-pin.
   Testfrequencies from 4040 chip, Clocked by 16F690.
           ___________  ___________ 
          |           \/           |
    +5V---|Vdd      16F690      Vss|---GND 
          |RA5            RA0/(PGD)|bbTx->-PK2Rx
 Clkout-<-|RA4            RA1/(PGC)|bbRx-<-PK2Tx 
          |RA3/!MCLR/(Vpp)  RA2/INT|
 ?freq?->-|RC5/CCP              RC0|
          |RC4                  RC1|
          |RC3                  RC2|
          |RC6                  RB4|
          |RC7               RB5/Rx|not used 
  not used|RB7/Tx               RB6|
          |________________________| 
                                        
           ________  ________
          |        \/        |
   244 -<-|QL     4040    Vcc|--- +5V
 15625 -<-|QF              QK|->- 488
 31250 -<-|QE              QJ|->- 976
  7812 -<-|QG              QH|->- 3906
 62500 -<-|QD              QI|->- 1953
125000 -<-|QC             CLR|--- GND
250000 -<-|QB             CLK|-<- 1 MHz Clockin
   GND ---|GND             QA|->- 500000
          |__________________|
*/
