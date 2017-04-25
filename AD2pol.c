/* AD2pol.c 16F690 2 values AD-logg                */
/* Sends A2, A3 values to UART-tool on key-press   */

/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 

/* The SCALE_FACTOR value is wrong - you should correct it!          */
#define SCALE_FACTOR 49 //scaling factorn är 49 in my book
/* The DECIMALS_I value is wrong - you should correct it!            */
#define DECIMALS_I 3 //det ska ersättas med 3
/* The DECIMALS_U value is wrong - you should correct it!            */
#define DECIMALS_U 4 //ska ersättas med 4
/* The AN2_SELECT value is wrong - you should correct it!            */
#define AN2_SELECT 0b10001001
/* The AN3_SELECT value is wrong - you should correct it!            */
#define AN3_SELECT 0b10001101

/* This value is correct the AD-value is unsigned (allways positive) */
#define UN_SIGNED 1 //stoppa in 0
/* Decimal mark: point or comma - what your Excel uses               */
#define DECIMAL_MARK ','

void initserial( void );
void ADinit( void );
void putchar( char );
void string_out( const char * ); 
void longDecimal_out(long number, char decimalPlaces, bit un_signed); 
void delay10( char );

void main(void)
{
  unsigned long advalue;
  TRISC.0 = 0; // lightdiode at RC0 is output
  PORTC.0 = 0; // no light
  TRISB.6 = 1; // switch SW is input

  initserial();
  ADinit();
  delay10(200); 

  // Header text
  string_out("U [V]\tI [mA]\r\n");

while(1)
 {
    while(PORTB.6) ; // wait for key pressed - new measurement 
    PORTC.0=1;       // LED Sampling indicator

    /* Now measure the Voltage [V] */
    ADCON0 = AN2_SELECT; // select ch AN2 for Voltage
    GO=1;         // start AD
    while(GO) ;   // wait for done
    advalue = ADRESH*256;  // read result 10 bit
    advalue += ADRESL;
	/* 1024 -> 5.0000 [V]  */
	advalue *= SCALE_FACTOR;
    //advalue /= 2;  /* uncomment when using 2,5V reference */

    longDecimal_out(advalue, DECIMALS_U, UN_SIGNED); 
	putchar('\t');	
	
	/* Now mesure the current in [mA] */
    ADCON0 = AN3_SELECT;  // select ch AN3 for Current
    GO=1;         // start AD
    while(GO) ;   // wait for done
    advalue = ADRESH*256;    // read result 10 bit
    advalue += ADRESL; 
	/* U=I*R R=100 Ohm U=1024 -> 50.000 [mA]  */
	advalue *= SCALE_FACTOR;
    //advalue /= 2;  /* uncomment when using 2,5V reference */

    longDecimal_out(advalue, DECIMALS_I, UN_SIGNED); 
 
    putchar('\r'); putchar('\n');

     delay10(1);         // Debounce
     PORTC.0=0;          // LED off, measurement done 
     while (!PORTB.6) ;  // wait for key released
     delay10(1);         // Debounce
    }
}





/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */


/* **** ADconverter function ************** */

void ADinit( void )
{
  // AD setup 
  ANSEL.1 = 1; // RA1 AN1 analog configurated - used later in lab
  ANSEL.2 = 1; // RA2 AN2 analog configurated
  ANSEL.4 = 1; // RA4 AN3 analog configurated
  TRISA.1 = 1; // AN1 input - used later in lab 
  TRISA.2 = 1; // AN2 input
  TRISA.4 = 1; // AN3 input

  ADCON1 = 0b0.101.0000; // AD conversion clock 'fosc/16'

  /* 
     1.x.xxxx.x.x  ADRESH:ADRESL is 10 bit right justified
     x.0.xxxx.x.x  Vref is Vdd
     x.x.0010.x.x  Select Channel (AN2) changed in program later
     x.x.xxxx.0.x  Go/!Done bit - start from program later
     x.x.xxxx.x.1  Enable AD-converter
  */
  ADCON0 = 0b1.0.0010.0.1; 
}



/* **** bitbanging serial communication **** */

void initserial( void )  /* initialise PIC16F690 bbCom */
{
   ANSEL.0 = 0; // No AD on RA0
   PORTA.0 = 1; // marking line
   TRISA.0 = 0; // output to PK2 UART-tool
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
        if(i==6-decimalPlaces) putchar( DECIMAL_MARK ); 
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
   Use "PICkit2 UART Tool" as a 9600 Baud terminal to save data.
   with BitBanging routines.
           _____________  ____________    
          |             \/            | 
    +5V---|Vdd        16F690       Vss|---GND
          |RA5               RA0/(PGD)|bbTx ->- PK2Rx/PGD
     I ->-|RA4/AN3   AN1/REF/RA1/(PGC)|-<- Vref or -<- PGC
          |RA3/!MCLR/(Vpp) RA2/AN2/INT|-<- U
          |RC5/CCP                 RC0|->- LED
          |RC4                     RC1|
          |RC3                     RC2|
          |RC6                     RB4|
          |RC7                  RB5/Rx|
          |RB7/Tx                  RB6|-<- SW
          |___________________________|
*/

