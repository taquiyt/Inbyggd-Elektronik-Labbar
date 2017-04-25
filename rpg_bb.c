/* rpg_bb.c  Readout on PK2 UARTtool of RPG Position */
/* (RPG, Rotary Pulse Generator) */

/*
   Use "PICkit2 UART Tool" as a 9600 Baud terminal
   with BitBanging routines.
*/

/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#pragma config |= 0x00D4

void init( void );
void initserial( void );
void putchar( char );
char getchar( void );
void delay10( char ); /* not used, but could come to use */
void printf(const char *string, char variable);

void main( void)
{
  init(); /* initiate portpins as input or output */

  char oneHot = 0b010;
  /* display oneHot with a neutral startvalue 010 */
  PORTC = oneHot;  

  char old_new = 0;         /* to store bitorder: "oldB oldA newB newA"    */
  int cnt = 0, old_cnt = 0; /* count in this loop turn, and previous count */

  initserial();
  
  while(1)
   {
     /* read encoder new value */
     old_new.0 = PORTA.5;  // read rpgA
     old_new.1 = PORTA.4;  // read rpgB

     /* compare with transitions in state diagram */
     if( old_new == 0b00.01 )  // from 00 -> 01, forward
      {
         cnt ++;
		 oneHot=rr(oneHot);
		 oneHot.2=Carry;
         /* insert code to rotate 3-bit oneHot to right 010 -> 001 */
         /* Preparation task is to find out how! */
      }

     if( old_new == 0b01.00 )  // from 01->00, backwards
      {
         cnt --;
		Carry=
		oneHot.2;
		oneHot=rl(oneHot);
		 
         /* insert code to rotate 3-bit oneHot to left 010 -> 100 */
         /* Preparation task is to find out how! */
      }
     /* no action on any other transition */

     /* replace the old values with the new values */
     old_new.2 = old_new.0;
     old_new.3 = old_new.1;

     if(cnt != old_cnt)       /* Only print when there is a change in cnt! */
       printf("Position: %d\r\n", cnt);  /* this function call takes time! */
     old_cnt = cnt;  /* update oldcnt */

     /* display oneHot  100 010 001 */
     PORTC = oneHot; 
   }
}








/* *********************************** */
/*            FUNCTIONS                */
/* *********************************** */


void init( void )
{
  ANSEL =0;     /* not AD-input */
  TRISA.5 = 1;  /* input rpgA   */
  TRISA.4 = 1;  /* input rpgB   */

  /* Enable week pullup's       */
  OPTION.7 = 0; /* !RABPU bit   */
  WPUA.5   = 1; /* rpgA pullup  */
  WPUA.4   = 1; /* rpgB pullup  */
  
  TRISC.0=0;
  TRISC.1=0;
  TRISC.2=0;
}



void initserial( void )  /* initialise PIC16F690 bitbang serialcom port */
{
   ANSEL.0 = 0; /* No AD on RA0             */
   ANSEL.1 = 0; /* No AD on RA1             */
   PORTA.0 = 1; /* marking line             */
   TRISA.0 = 0; /* output to PK2 UART-tool  */
   TRISA.1 = 1; /* input from PK2 UART-tool */
   return;     
}


void putchar( char ch )  /* sends one char */
{
  char bitCount, ti;
  PORTA.0 = 0; /* set startbit */
  for ( bitCount = 10; bitCount > 0 ; bitCount-- )
   {
     /* delay one bit 104 usec at 4 MHz       */
     /* 5+18*5-1+1+9=104 without optimization */
     ti = 18; do ; while( --ti > 0); nop();
     Carry = 1;     /* stopbit                    */
     ch = rr( ch ); /* Rotate Right through Carry */
     PORTA.0 = Carry;
   }
  return;
}


char getchar( void )  /* recieves one char, blocking */
{
   /* One start bit, one stop bit, 8 data bit, no parity = 10 bit. */
   /* Baudrate: 9600 baud => 104.167 usec. per bit.                */
   char d_in, bitCount, ti;
   while( PORTA.1 == 1 ) /* wait for startbit */ ;
      /* delay 1,5 bit 156 usec at 4 MHz         */
      /* 5+28*5-1+1+2+9=156 without optimization */
      ti = 28; do ; while( --ti > 0); nop(); nop2();
   for( bitCount = 8; bitCount > 0 ; bitCount--)
       {
        Carry = PORTA.1;
        d_in = rr( d_in);  /* rotate carry */
         /* delay one bit 104 usec at 4 MHz       */
         /* 5+18*5-1+1+9=104 without optimization */
         ti = 18; do ; while( --ti > 0); nop();
        }
   return d_in;
}


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


/* *********************************** */
/*            HARDWARE                 */
/* *********************************** */


/*
             _____________  _____________ 
            |             \/             |
      +5V---|Vdd        16F690        Vss|---Gnd
     rpgA->-|RA5            RA0/AN0/(PGD)|bbTx->- PK2 UART-tool
     rpgB->-|RA4/AN3            RA1/(PGC)|bbRx-<- PK2 UART-tool
            |RA3/!MCLR/(Vpp)  RA2/AN2/INT|
            |RC5/CCP                  RC0|->-LED0
            |RC4                      RC1|->-LED1
            |RC3/AN7                  RC2|->-LED2
            |RC6/AN8             AN10/RB4|
            |RC7/AN9               RB5/Rx|
            |RB7/Tx                   RB6|
            |____________________________|
                                          
*/

