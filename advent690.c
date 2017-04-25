/* advent690.c  simulate advent candles with PICkit2 starterkit */
/* PIC16F690 compiled with B. Knudsen Cc5x Free, not ANSI-C     */

/* Low pin count demo board PICkit2 Starterkit           J1
           ___________  ___________                      1 RA5
          |           \/           |                     2 RA4
    +5V---|Vdd      16F690      Vss|---GND               3 RA3
       ---|RA5        RA0/AN0/(PGD)|->-PK2 UART-tool 4   4 RC5
       ---|RA4            RA1/(PGC)|-<-PK2 UART-tool 5   5 RC4
    SW1---|RA3/!MCLR/(Vpp)  RA2/INT|---                  6 RC3
       ---|RC5/CCP              RC0|->-DS1               7 RA0
       ---|RC4                  RC1|->-DS2               8 RA1
    DS4-<-|RC3                  RC2|->-DS3               9 RA2
          |RC6                  RB4|                    10 RC0
          |RC7               RB5/Rx|-<-(PCtx)           11 RC1
 (PCrx)-<-|RB7/Tx               RB6|                    12 RC2
          |________________________|                    13 +5V
                                                        14 GND
*/

/*
   Use "PICkit2 UART Tool" as a 9600 Baud terminal.
   Uncheck "Echo On".
   PIC internal UART is not used.
*/

#include "16F690.h"
#include "int16Cxx.h"
#pragma config |= 0x00D4

uns8 rand( void );
void delay( uns8);
void delay10( uns8);
void init_portC( void );
void init_serial( void );
void init_interrupt( void );
void printf(const char *string, uns8 variable);
char getchar( void );
void putchar( char);

bit receiver_flag;   /* Signal-flag used by interrupt routine   */
char receiver_byte;  /* Transfer Byte used by interrupt routine */

#pragma origin 4
interrupt int_server( void ) /* the place for the interrupt routine */
{
  int_save_registers
  /* New interrupts are automaticaly disabled            */
  /* "Interrupt on change" at pin RA1 from PK2 UART-tool */
  
  if( PORTA.1 == 0 )  /* Interpret this as the startbit  */
    {  /* Receives one full character   */
      uns8 bitCount, ti;
      /* delay 1,5 bit 156 usec at 4 MHz         */
      /* 5+28*5-1+1+2+9=156 without optimization */
      ti = 28; do ; while( --ti > 0); nop(); nop2();
      for( bitCount = 8; bitCount > 0 ; bitCount--)
       {
         Carry = PORTA.1;
         receiver_byte = rr( receiver_byte);  /* rotate carry */
         /* delay one bit 104 usec at 4 MHz       */
         /* 5+18*5-1+1+9=104 without optimization */ 
         ti = 18; do ; while( --ti > 0); nop(); 
        }
      receiver_flag = 1; /* A full character is received */
    }
  RABIF = 0;    /* Reset the RABIF-flag before leaving   */
  int_restore_registers
  /* New interrupts are now enabled */
}


void main( void)
{
  uns8 flicker, choice, mask=0x00;
  uns8 speed = 120;

  init_portC();
  init_serial();
  init_interrupt();
  /* You must "connect" PK2 UART-tool in one second after power on! */
  delay10(100); 
  printf("Advent: 1, 2, 3, 4 Light flicker: +,-\r\n",0);

  while(1)
   {
     if( receiver_flag ) /* Character received? */ 
      {
        choice = getchar();

        switch (choice)
         {
          case '1':
           mask = 0x01; /* 00000001 */
           printf("%c First\r\n", choice);
           break;
          case '2':
           mask = 0x03; /* 00000011 */
           printf("%c Second\r\n", choice);
           break;
          case '3':
           mask = 0x07; /* 00000111 */
           printf("%c Third\r\n", choice);
           break;
          case '4':
           mask = 0x0F; /* 00001111 */
           printf("%c Fourth\r\n", choice);
           break;
          case '+':
           if(speed > 0) speed --;
           else speed = 0;
           printf("%c Increasing flicker, ", choice);
           printf("delay %u\r\n", speed);
           break;
          case '-':
           if(speed < 254) speed ++;
           else speed = 255;
           printf("%c Decreasing flicker, ", choice);
           printf("delay %u\r\n", speed);
           break;
          default:
           mask = 0x00; /* 00000000 */
           printf("%c Choose advent: 1, 2, 3, 4 Light flicker: +,-\r\n",choice);
         }
      }
     flicker = rand();
     flicker &= mask;
     PORTC = flicker;
     delay(5);  /* minimum delay */
     delay(speed);
   }
}


/*   FUNCTIONS  */

/* Random number function */
uns8 rand( void )
{
  bit EXOR_out;
  static uns8 rand_hi, rand_lo;
  /* values from last call will be used as seed
     for calculation of the next random number  */

  if( !rand_hi && !rand_lo ) rand_lo = 0x01;  /* 0x0000 won't run ... */

  EXOR_out ^= rand_lo.0;
  EXOR_out ^= rand_lo.2;
  EXOR_out ^= rand_lo.3;
  EXOR_out ^= rand_lo.5;

  Carry = EXOR_out;
  rand_hi = rr( rand_hi); /* rotate right, Cc5x internal function */
  rand_lo = rr( rand_lo);

  return rand_lo;
}


void delay( uns8 millisec)
/*
  Delays a multiple of 1 milliseconds at 4 MHz
  using the TMR0 timer. B. Knudsen.
*/
{
    OPTION = 2;  /* prescaler divide by 8        */
    do  {
        TMR0 = 0;
        while ( TMR0 < 125)   /* 125 * 8 = 1000  */
            ;
    } while ( -- millisec > 0);
}

void delay10( uns8 n)
/*
  Delays a multiple of 10 milliseconds using the TMR0 timer
  Clock : 4 MHz   => period T = 0.25 microseconds
  1 IS = 1 Instruction Cycle = 1 microsecond
  error: 0.16 percent
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

void init_portC( void )
{
  TRISC = 0xF0; /* 11110000 0 is for outputbit  */
  PORTC = 0;
  return;
}

void init_serial( void )  /* initialise serialcom port */
{
   ANSEL.0 = 0; /* No AD on RA0             */
   ANSEL.1 = 0; /* No AD on RA1             */
   PORTA.0 = 1; /* marking line             */
   TRISA.0 = 0; /* output to PK2 UART-tool  */
   TRISA.1 = 1; /* input from PK2 UART-tool */
   receiver_flag = 0 ;
   return;      
}

void init_interrupt( void )
{
  IOCA.1 = 1; /* PORTA.1 interrupt on change */
  RABIE =1;  /* interrupt on change         */
  GIE = 1;   /* interrupt enable            */
  return;
}

char getchar(void)
{
   /* All job is done in the interrupt routine!  */
   receiver_flag = 0; /* Character now taken */
   return receiver_byte;
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

void printf(const char *string, uns8 variable)
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
             if( variable > 128) variable = -variable;  // no break!
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

