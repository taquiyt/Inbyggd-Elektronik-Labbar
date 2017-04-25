
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  31. Mar 2017  15:05  *************

	processor  16F690
	radix  DEC

	__config 0xD4

TMR0        EQU   0x01
PCL         EQU   0x02
STATUS      EQU   0x03
PORTA       EQU   0x05
TRISA       EQU   0x85
TRISB       EQU   0x86
PCLATH      EQU   0x0A
Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
GIE         EQU   7
OPTION_REG  EQU   0x81
TXREG       EQU   0x19
WPUA        EQU   0x95
IOCA        EQU   0x96
SPBRG       EQU   0x99
ANSEL       EQU   0x11E
ANSELH      EQU   0x11F
RABIF       EQU   0
RABIE       EQU   3
TXIF        EQU   4
CREN        EQU   4
RX9         EQU   6
SPEN        EQU   7
BRGH        EQU   2
SYNC        EQU   4
TXEN        EQU   5
TX9         EQU   6
BRG16       EQU   3
old_new     EQU   0x2D
cnt         EQU   0x2E
svrWREG     EQU   0x70
svrSTATUS   EQU   0x20
svrPCLATH   EQU   0x21
old_cnt     EQU   0x22
d_out       EQU   0x2A
n           EQU   0x7F
i           EQU   0x7F
string      EQU   0x23
variable    EQU   0x24
i_2         EQU   0x25
k           EQU   0x26
m           EQU   0x27
a           EQU   0x28
b           EQU   0x29
C1cnt       EQU   0x2A
C2tmp       EQU   0x2B
C3rem       EQU   0x2C
C4cnt       EQU   0x2A
C5tmp       EQU   0x2B
C6cnt       EQU   0x2A
C7tmp       EQU   0x2B
C8rem       EQU   0x2C
C9cnt       EQU   0x2A
C10tmp      EQU   0x2B
ci          EQU   0x2A

	GOTO main

  ; FILE rpg_interrupt_uart.c
			;/* rpg_interrupt_uart.c   RPG Interrupt on change
			;   Use "PICkit2 UART Tool" as a 9600 Baud terminal
			;   PIC internal USART is used.
			;   Connect jumpers RB7/Tx-RA0/PGD and RB5/Rx-RA1/PGC.
			;*/
			;
			;
			;
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;#include "16F690.h"
			;#include "int16Cxx.h"
			;#pragma config |= 0x00D4
			;
			;void init( void );
			;void initserial( void );
			;void putchar( char );
			;char getchar( void );
			;void delay10( char ); 
			;void printf(const char *string, char variable);
			;
			;char old_new;  /* global to store bitorder: "oldB oldA newB newA"  */
			;int cnt;       /* global to store RPG count                        */
			;
			;#pragma origin 4
	ORG 0x0004
			;interrupt int_server( void ) /* the place for the interrupt routine */
			;{
int_server
			;  int_save_registers
	MOVWF svrWREG
	SWAPF STATUS,W
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF svrSTATUS
	MOVF  PCLATH,W
	MOVWF svrPCLATH
	CLRF  PCLATH
			;  if( RABIF == 1 ) /* is it the RA pins onchange-interrupt?  */
	BTFSS 0x0B,RABIF
	GOTO  m001
			;    {              /* this time it's obvius that it is!      */
			;     /* read encoder new value */
			;     old_new.0 = PORTA.5;  /* read rpgA */
	BCF   old_new,0
	BTFSC PORTA,5
	BSF   old_new,0
			;     old_new.1 = PORTA.4;  /* read rpgB */
	BCF   old_new,1
	BTFSC PORTA,4
	BSF   old_new,1
			;     /* compare with transitions in state diagram */
			;     if( old_new == 0b00.01 ) cnt ++; /* from 00 -> 01, forward */
	DECF  old_new,W
	BTFSC 0x03,Zero_
	INCF  cnt,1
			;     if( old_new == 0b01.00 ) cnt --; /* from 01->00, backwards */
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  old_new,W
	XORLW 4
	BTFSC 0x03,Zero_
	DECF  cnt,1
			;     /* no action on any other transition */
			;     /* replace old values with new values */
			;     old_new.2 = old_new.0;
	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   old_new,2
	BTFSC old_new,0
	BSF   old_new,2
			;     old_new.3 = old_new.1;
	BCF   old_new,3
	BTFSC old_new,1
	BSF   old_new,3
			;
			;      RABIF = 0;    /* Reset RB-change flag before leaving  */
	BCF   0x0B,RABIF
			;    }
			;  int_restore_registers
m001	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  svrPCLATH,W
	MOVWF PCLATH
	SWAPF svrSTATUS,W
	MOVWF STATUS
	SWAPF svrWREG,1
	SWAPF svrWREG,W
			;}
	RETFIE
			;
			;
			;void main( void)
			;{
_const1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF ci
	CLRF  PCLATH
	MOVF  ci,W
	ANDLW 15
	ADDWF PCL,1
	RETLW 80
	RETLW 111
	RETLW 115
	RETLW 105
	RETLW 116
	RETLW 105
	RETLW 111
	RETLW 110
	RETLW 58
	RETLW 32
	RETLW 37
	RETLW 100
	RETLW 13
	RETLW 10
	RETLW 0
	RETLW 0
main
			;  old_new = 0; /* initialise global */
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  old_new
			;  cnt = 0;     /* initialise global */
	CLRF  cnt
			;  int old_cnt = 0;
	CLRF  old_cnt
			;  init();         /* init portpins as input or output */
	CALL  init
			;  initserial();   /* init serialport                  */
	CALL  initserial
			;
			;  IOCA.5  = 1;   /* interrupt on RA5 pin enable */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   IOCA,5
			;  IOCA.4  = 1;   /* interrupt on RA4 pin enable */
	BSF   IOCA,4
			;  RABIE   = 1;   /* local interrupt enable  */
	BSF   0x0B,RABIE
			;  GIE     = 1;   /* global interrupt enable */
	BSF   0x0B,GIE
			;
			;  while(1)
			;   {  
			;     if(cnt != old_cnt)  /* print RPG-count when change */
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  cnt,W
	XORWF old_cnt,W
	BTFSC 0x03,Zero_
	GOTO  m002
			;       {
			;         printf("Position: %d\r\n", cnt);
	CLRF  string
	MOVF  cnt,W
	CALL  printf
			;         old_cnt = cnt;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  cnt,W
	MOVWF old_cnt
			;       } 
			;     //delay10(100); /* max one printout per second        */
			;   }
	GOTO  m002
			;}
			;
			;
			;
			;/* *********************************** */
			;/*            FUNCTIONS                */
			;/* *********************************** */
			;
			;
			;void init( void )
			;{
init
			;  ANSEL =0;     /* not AD-input */
	BCF   0x03,RP0
	BSF   0x03,RP1
	CLRF  ANSEL
			;  TRISA.5 = 1;  /* input rpgA   */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   TRISA,5
			;  TRISA.4 = 1;  /* input rpgB   */
	BSF   TRISA,4
			;
			;  /* Enable week pullup's       */
			;  OPTION.7 = 0; /* !RABPU bit   */
	BCF   OPTION_REG,7
			;  WPUA.5   = 1; /* rpgA pullup  */
	BSF   WPUA,5
			;  WPUA.4   = 1; /* rpgB pullup  */
	BSF   WPUA,4
			;}
	RETURN
			;
			;void initserial( void )  /* initialise PIC16F690 serialcom port */
			;{
initserial
			;   /* One start bit, one stop bit, 8 data bit, no parity. 9600 Baud. */
			;
			;   TXEN = 1;      /* transmit enable                   */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x98,TXEN
			;   SYNC = 0;      /* asynchronous operation            */
	BCF   0x98,SYNC
			;   TX9  = 0;      /* 8 bit transmission                */
	BCF   0x98,TX9
			;   SPEN = 1;
	BCF   0x03,RP0
	BSF   0x18,SPEN
			;
			;   BRGH  = 0;     /* settings for 6800 Baud            */
	BSF   0x03,RP0
	BCF   0x98,BRGH
			;   BRG16 = 1;     /* @ 4 MHz-clock frequency           */
	BSF   0x9B,BRG16
			;   SPBRG = 25;
	MOVLW 25
	MOVWF SPBRG
			;
			;   CREN = 1;      /* Continuous receive                     */
	BCF   0x03,RP0
	BSF   0x18,CREN
			;   RX9  = 0;      /* 8 bit reception                        */
	BCF   0x18,RX9
			;   ANSELH.3 = 0;  /* RB5 not AD-input but serial_in         */
	BSF   0x03,RP1
	BCF   ANSELH,3
			;   TRISB.5 = 0;   /* Tx output */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   TRISB,5
			;   TRISB.7 = 1;   /* Rx input  */
	BSF   TRISB,7
			;   TRISA.0 = 1;   /* using the PGD connection for UART-tool */
	BSF   TRISA,0
			;   TRISA.1 = 1;   /* using the PGC connection for UART-tool */
	BSF   TRISA,1
			;}
	RETURN
			;
			;
			;void putchar( char d_out )  /* sends one char */
			;{
putchar
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF d_out
			;   while (!TXIF) ;   /* wait until previus character transmitted */
m003	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS 0x0C,TXIF
	GOTO  m003
			;   TXREG = d_out;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  d_out,W
	MOVWF TXREG
			;}
	RETURN
			;
			;void delay10( char n)
			;/*
			;  Delays a multiple of 10 milliseconds using the TMR0 timer
			;  Clock : 4 MHz   => period T = 0.25 microseconds
			;  1 IS = 1 Instruction Cycle = 1 microsecond
			;  error: 0.16 percent. B Knudsen.
			;*/
			;{
delay10
	MOVWF n
			;    char i;
			;
			;    OPTION = 7;
	MOVLW 7
	BSF   0x03,RP0
	BCF   0x03,RP1
	MOVWF OPTION_REG
			;    do  {
			;        i = TMR0 + 39; /* 256 microsec * 39 = 10 ms */
m004	MOVLW 39
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF TMR0,W
	MOVWF i
			;        while ( i != TMR0)
m005	MOVF  i,W
	BCF   0x03,RP0
	BCF   0x03,RP1
	XORWF TMR0,W
	BTFSS 0x03,Zero_
			;            ;
	GOTO  m005
			;    } while ( --n > 0);
	DECFSZ n,1
	GOTO  m004
			;}
	RETURN
			;
			;
			;void printf(const char *string, char variable)
			;{
printf
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF variable
			;  char i, k, m, a, b;
			;  for(i = 0 ; ; i++)
	CLRF  i_2
			;   {
			;     k = string[i];
m006	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i_2,W
	ADDWF string,W
	CALL  _const1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF k
			;     if( k == '\0') break;   // at end of string
	MOVF  k,1
	BTFSC 0x03,Zero_
	GOTO  m028
			;     if( k == '%')           // insert variable in string
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	XORLW 37
	BTFSS 0x03,Zero_
	GOTO  m026
			;      {
			;        i++;
	INCF  i_2,1
			;        k = string[i];
	MOVF  i_2,W
	ADDWF string,W
	CALL  _const1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF k
			;        switch(k)
	MOVF  k,W
	XORLW 100
	BTFSC 0x03,Zero_
	GOTO  m007
	XORLW 17
	BTFSC 0x03,Zero_
	GOTO  m010
	XORLW 23
	BTFSC 0x03,Zero_
	GOTO  m019
	XORLW 1
	BTFSC 0x03,Zero_
	GOTO  m023
	XORLW 70
	BTFSC 0x03,Zero_
	GOTO  m024
	GOTO  m025
			;         {
			;           case 'd':         // %d  signed 8bit
			;             if( variable.7 ==1) putchar('-');
m007	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS variable,7
	GOTO  m008
	MOVLW 45
	CALL  putchar
			;             else putchar(' ');
	GOTO  m009
m008	MOVLW 32
	CALL  putchar
			;             if( variable > 127) variable = -variable;  // no break!
m009	MOVLW 128
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF variable,W
	BTFSS 0x03,Carry
	GOTO  m010
	COMF  variable,1
	INCF  variable,1
			;           case 'u':         // %u unsigned 8bit
			;             a = variable/100;
m010	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	MOVWF C2tmp
	CLRF  C3rem
	MOVLW 8
	MOVWF C1cnt
m011	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C2tmp,1
	RLF   C3rem,1
	MOVLW 100
	SUBWF C3rem,W
	BTFSS 0x03,Carry
	GOTO  m012
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C3rem,1
	BSF   0x03,Carry
m012	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C1cnt,1
	GOTO  m011
			;             putchar('0'+a); // print 100's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             b = variable%100;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	MOVWF C5tmp
	CLRF  b
	MOVLW 8
	MOVWF C4cnt
m013	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C5tmp,1
	RLF   b,1
	MOVLW 100
	SUBWF b,W
	BTFSS 0x03,Carry
	GOTO  m014
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF b,1
m014	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C4cnt,1
	GOTO  m013
			;             a = b/10;
	MOVF  b,W
	MOVWF C7tmp
	CLRF  C8rem
	MOVLW 8
	MOVWF C6cnt
m015	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C7tmp,1
	RLF   C8rem,1
	MOVLW 10
	SUBWF C8rem,W
	BTFSS 0x03,Carry
	GOTO  m016
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C8rem,1
	BSF   0x03,Carry
m016	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C6cnt,1
	GOTO  m015
			;             putchar('0'+a); // print 10's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             a = b%10;        
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  b,W
	MOVWF C10tmp
	CLRF  a
	MOVLW 8
	MOVWF C9cnt
m017	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C10tmp,1
	RLF   a,1
	MOVLW 10
	SUBWF a,W
	BTFSS 0x03,Carry
	GOTO  m018
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF a,1
m018	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C9cnt,1
	GOTO  m017
			;             putchar('0'+a); // print 1's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             break;
	GOTO  m027
			;           case 'b':         // %b BINARY 8bit
			;             for( m = 0 ; m < 8 ; m++ )
m019	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  m
m020	MOVLW 8
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m027
			;              {
			;                if (variable.7 == 1) putchar('1');
	BTFSS variable,7
	GOTO  m021
	MOVLW 49
	CALL  putchar
			;                else putchar('0');
	GOTO  m022
m021	MOVLW 48
	CALL  putchar
			;                variable = rl(variable);
m022	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   variable,1
			;               }
	INCF  m,1
	GOTO  m020
			;              break;
			;           case 'c':         // %c  'char'
			;             putchar(variable);
m023	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	CALL  putchar
			;             break;
	GOTO  m027
			;           case '%':
			;             putchar('%');
m024	MOVLW 37
	CALL  putchar
			;             break;
	GOTO  m027
			;           default:          // not implemented
			;             putchar('!');  
m025	MOVLW 33
	CALL  putchar
			;         }  
			;      }
			;      else putchar(k);
	GOTO  m027
m026	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	CALL  putchar
			;   }
m027	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i_2,1
	GOTO  m006
			;}
m028	RETURN

	END


; *** KEY INFO ***

; 0x0061 P0   11 word(s)  0 % : init
; 0x006C P0   24 word(s)  1 % : initserial
; 0x0084 P0   12 word(s)  0 % : putchar
; 0x0090 P0   19 word(s)  0 % : delay10
; 0x00A3 P0  207 word(s) 10 % : printf
; 0x0004 P0   43 word(s)  2 % : int_server
; 0x0046 P0   27 word(s)  1 % : main
; 0x002F P0   23 word(s)  1 % : _const1

; RAM usage: 16 bytes (14 local), 240 bytes free
; Maximum call level: 2 (+1 for interrupt)
;  Codepage 0 has  367 word(s) :  17 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 367 code words (8 %)
