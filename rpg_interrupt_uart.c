/* rpg_interrupt_uart.c   RPG Interrupt on change
   Use "PICkit2 UART Tool" as a 9600 Baud terminal
   PIC internal USART is used.
   Connect jumpers RB7/Tx-RA0/PGD and RB5/Rx-RA1/PGC.
*/



/* B Knudsen Cc5x C-compiler - not ANSI-C */
#include "16F690.h"
#include "int16Cxx.h"
#pragma config |= 0x00D4

void init( void );
void initserial( void );
void putchar( char );
char getchar( void );
void delay10( char ); 
void printf(const char *string, char variable);

char old_new;  /* global to store bitorder: "oldB oldA newB newA"  */
int cnt;       /* global to store RPG count                        */

#pragma origin 4
interrupt int_server( void ) /* the place for the interrupt routine */
{
  int_save_registers
  if( RABIF == 1 ) /* is it the RA pins onchange-interrupt?  */
    {              /* this time it's obvius that it is!      */
     /* read encoder new value */
     old_new.0 = PORTA.5;  /* read rpgA */
     old_new.1 = PORTA.4;  /* read rpgB */
     /* compare with transitions in state diagram */
     if( old_new == 0b00.01 ) cnt ++; /* from 00 -> 01, forward */
     if( old_new == 0b01.00 ) cnt --; /* from 01->00, backwards */
     /* no action on any other transition */
     /* replace old values with new values */
     old_new.2 = old_new.0;
     old_new.3 = old_new.1;

      RABIF = 0;    /* Reset RB-change flag before leaving  */
    }
  int_restore_registers
}


void main( void)
{
  old_new = 0; /* initialise global */
  cnt = 0;     /* initialise global */
  int old_cnt = 0;
  init();         /* init portpins as input or output */
  initserial();   /* init serialport                  */

  IOCA.5  = 1;   /* interrupt on RA5 pin enable */
  IOCA.4  = 1;   /* interrupt on RA4 pin enable */
  RABIE   = 1;   /* local interrupt enable  */
  GIE     = 1;   /* global interrupt enable */

  while(1)
   {  
     if(cnt != old_cnt)  /* print RPG-count when change */
       {
         printf("Position: %d\r\n", cnt);
         old_cnt = cnt;
       } 
     //delay10(100); /* max one printout per second        */
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
}

void initserial( void )  /* initialise PIC16F690 serialcom port */
{
   /* One start bit, one stop bit, 8 data bit, no parity. 9600 Baud. */

   TXEN = 1;      /* transmit enable                   */
   SYNC = 0;      /* asynchronous operation            */
   TX9  = 0;      /* 8 bit transmission                */
   SPEN = 1;

   BRGH  = 0;     /* settings for 6800 Baud            */
   BRG16 = 1;     /* @ 4 MHz-clock frequency           */
   SPBRG = 25;

   CREN = 1;      /* Continuous receive                     */
   RX9  = 0;      /* 8 bit reception                        */
   ANSELH.3 = 0;  /* RB5 not AD-input but serial_in         */
   TRISB.5 = 0;   /* Tx output */
   TRISB.7 = 1;   /* Rx input  */
   TRISA.0 = 1;   /* using the PGD connection for UART-tool */
   TRISA.1 = 1;   /* using the PGC connection for UART-tool */
}


void putchar( char d_out )  /* sends one char */
{
   while (!TXIF) ;   /* wait until previus character transmitted */
   TXREG = d_out;
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
     rpgA->-|RA5            RA0/AN0/(PGD)|------+-->- PK2 UART-tool
     rpgB->-|RA4/AN3            RA1/(PGC)|---+--|--<- PK2 UART-tool
            |RA3/!MCLR/(Vpp)  RA2/AN2/INT|   |  |
            |RC5/CCP                  RC0|   |  |
            |RC4                      RC1|   |  |
            |RC3/AN7                  RC2|   |  |
            |RC6/AN8             AN10/RB4|   |  |
            |RC7/AN9               RB5/Rx|-<-+  |
        +-<-|RB7/Tx                   RB6|      |
        |   |____________________________|      |
        |                                       |
        +---------------------------------------+
*/

