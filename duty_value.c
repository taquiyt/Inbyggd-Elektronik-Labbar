/* duty_value.c PIC 16F690 reads PWM-duty from POT           */
/* prints DutyCycle in percent with UART tool on key-press   */

/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4 

void initserial( void );
void ADinit( void );
void PWMinit( void );
void putchar( char );
void printf(const char *string, char variable);
void delay10( char );


void main(void)
{
  char advalue, duty;
  unsigned long tmp1,tmp2;
  TRISC.4 = 0; // lightdiode at RC4 is output
  PORTC.4 = 0; // no light
  TRISB.6 = 1; // switch SW is input

  initserial();
  ADinit();
  PWMinit();
  
  delay10(100); 
  // Header text
  printf("Press button to print Dutycycle\r\n",0);

  while(1)
   {
      /* Now read the POT  */
      GO=1;         // start AD
      while(GO);    // wait for done
      advalue = ADRESH;    // read result 8 bit
	  /* copy to CCPR1L */
	  CCPR1L = advalue;  /* set DutyCycle with POT */

	  
      if(!PORTB.6)  // key is pressed
	    {
	       /* display DutyCycle */ 
           PORTC.4=1;          // LED indicator 
		   
           /* Calculate DutyCycle in percent */
           tmp1 = advalue * 100L;
		   tmp2 = tmp1 / 256L;  /* value in PR2-register */
           duty = tmp2.low8; 
		   
		   printf("CCPR1L = %u  ",advalue);
           printf("DutyCycle = %u %%\r\n", duty);	
		   
           delay10(1);         // Debounce
           PORTC.4=0;          // LED off dutycycle value is printed 
           while (!PORTB.6) ;  // wait for key released
           delay10(1);         // Debounce
        }
   }
}




/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */


/* **** ADconverter function ************** */

void ADinit( void )
{
  // AD setup AN6 at RC2 pin 14
  TRISC.2 = 1;  // AN6 input
  ANSEL.6 = 1;  /* RC2 AN6 analog configurated        */  
  ADCON1 = 0b0.101.0000;   /* AD conversion clock 'fosc/16' */
  ADCON0 = 0b0.0.0110.0.1; /* AD-channel 6 pin 14           */ 
}

/* **** CCP PWM function ************** */

void PWMinit( void )
{
   TRISC.5 = 0;              /* CCP1 output      */
   T2CON   = 0b00000.1.00;   /* prescale 1:1     */
   CCP1CON = 0b00.00.1100;   /* PWM-mode         */
   PR2     = 255;            /* max value        */
   CCPR1L  = 128;            /* Duty 50% initial */
}


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

void printf(const char *string, char variable)
{
  char i, k, m, a, b;
  for(i = 0 ; ; i++)
   {
     k = string[i];
     if( k == '\0') break;   // at end of string
     if( k == '%')           // insert variable in string
      {
        i++;
        k = string[i];
        switch(k)
         {
           case 'd':         // %d  signed 8bit
             if( variable.7 ==1) putchar('-');
             else putchar(' ');
             if( variable > 127) variable = -variable;  // no break!
           case 'u':         // %u unsigned 8bit
             a = variable/100;
             putchar('0'+a); // print 100's
             b = variable%100;
             a = b/10;
             putchar('0'+a); // print 10's
             a = b%10;
             putchar('0'+a); // print 1's
             break;
           case 'b':         // %b BINARY 8bit
             for( m = 0 ; m < 8 ; m++ )
              {
                if (variable.7 == 1) putchar('1');
                else putchar('0');
                variable = rl(variable);
               }
              break;
           case 'c':         // %c  'char'
             putchar(variable);
             break;
           case '%':
             putchar('%');
             break;
           default:          // not implemented
             putchar('!');
         }
      }
      else putchar(k);
   }
}




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
   Use "PICkit2 UART Tool" as a 9600 Baud terminal to save data.
   with BitBanging routines.
           _____________  ____________    
          |             \/            | 
    +5V---|Vdd        16F690       Vss|---GND
          |RA5               RA0/(PGD)|bbTx ->- PK2Rx
          |RA4/AN3   AN1/REF/RA1/(PGC)|
          |RA3/!MCLR/(Vpp)     RA2/INT|
PWMout -<-|RC5/CCP                 RC0|
   LED -<-|RC4                     RC1|
          |RC3                 AN6/RC2|-<- POT
          |RC6                     RB4|
          |RC7                  RB5/Rx|
          |RB7/Tx                  RB6|-<- SW
          |___________________________|
*/


