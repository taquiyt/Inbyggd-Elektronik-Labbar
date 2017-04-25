
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  31. Mar 2017  14:20  *************

	processor  16F690
	radix  DEC

	__config 0xD4

TMR0        EQU   0x01
PCL         EQU   0x02
PORTA       EQU   0x05
TRISA       EQU   0x85
PCLATH      EQU   0x0A
Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
OPTION_REG  EQU   0x81
PORTC       EQU   0x07
TRISC       EQU   0x87
WPUA        EQU   0x95
ANSEL       EQU   0x11E
oneHot      EQU   0x20
old_new     EQU   0x21
cnt         EQU   0x22
old_cnt     EQU   0x23
ch          EQU   0x2B
bitCount    EQU   0x2C
ti          EQU   0x2D
d_in        EQU   0x7F
bitCount_2  EQU   0x7F
ti_2        EQU   0x7F
n           EQU   0x7F
i           EQU   0x7F
string      EQU   0x24
variable    EQU   0x25
i_2         EQU   0x26
k           EQU   0x27
m           EQU   0x28
a           EQU   0x29
b           EQU   0x2A
C1cnt       EQU   0x2B
C2tmp       EQU   0x2C
C3rem       EQU   0x2D
C4cnt       EQU   0x2B
C5tmp       EQU   0x2C
C6cnt       EQU   0x2B
C7tmp       EQU   0x2C
C8rem       EQU   0x2D
C9cnt       EQU   0x2B
C10tmp      EQU   0x2C
ci          EQU   0x2B

	GOTO main

  ; FILE rpg_bb.c
			;/* rpg_bb.c  Readout on PK2 UARTtool of RPG Position */
			;/* (RPG, Rotary Pulse Generator) */
			;
			;/*
			;   Use "PICkit2 UART Tool" as a 9600 Baud terminal
			;   with BitBanging routines.
			;*/
			;
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;#include "16F690.h"
			;#pragma config |= 0x00D4
			;
			;void init( void );
			;void initserial( void );
			;void putchar( char );
			;char getchar( void );
			;void delay10( char ); /* not used, but could come to use */
			;void printf(const char *string, char variable);
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
			;  init(); /* initiate portpins as input or output */
	CALL  init
			;
			;  char oneHot = 0b010;
	MOVLW 2
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF oneHot
			;  /* display oneHot with a neutral startvalue 010 */
			;  PORTC = oneHot;  
	MOVF  oneHot,W
	MOVWF PORTC
			;
			;  char old_new = 0;         /* to store bitorder: "oldB oldA newB newA"    */
	CLRF  old_new
			;  int cnt = 0, old_cnt = 0; /* count in this loop turn, and previous count */
	CLRF  cnt
	CLRF  old_cnt
			;
			;  initserial();
	CALL  initserial
			;  
			;  while(1)
			;   {
			;     /* read encoder new value */
			;     old_new.0 = PORTA.5;  // read rpgA
m001	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   old_new,0
	BTFSC PORTA,5
	BSF   old_new,0
			;     old_new.1 = PORTA.4;  // read rpgB
	BCF   old_new,1
	BTFSC PORTA,4
	BSF   old_new,1
			;
			;     /* compare with transitions in state diagram */
			;     if( old_new == 0b00.01 )  // from 00 -> 01, forward
	DECFSZ old_new,W
	GOTO  m002
			;      {
			;         cnt ++;
	INCF  cnt,1
			;		 oneHot=rr(oneHot);
	RRF   oneHot,1
			;		 oneHot.2=Carry;
	BCF   oneHot,2
	BTFSC 0x03,Carry
	BSF   oneHot,2
			;         /* insert code to rotate 3-bit oneHot to right 010 -> 001 */
			;         /* Preparation task is to find out how! */
			;      }
			;
			;     if( old_new == 0b01.00 )  // from 01->00, backwards
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  old_new,W
	XORLW 4
	BTFSS 0x03,Zero_
	GOTO  m003
			;      {
			;         cnt --;
	DECF  cnt,1
			;		Carry=oneHot.2;
	BCF   0x03,Carry
	BTFSC oneHot,2
	BSF   0x03,Carry
			;		oneHot=rl(oneHot);
	RLF   oneHot,1
			;		 
			;         /* insert code to rotate 3-bit oneHot to left 010 -> 100 */
			;         /* Preparation task is to find out how! */
			;      }
			;     /* no action on any other transition */
			;
			;     /* replace the old values with the new values */
			;     old_new.2 = old_new.0;
m003	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   old_new,2
	BTFSC old_new,0
	BSF   old_new,2
			;     old_new.3 = old_new.1;
	BCF   old_new,3
	BTFSC old_new,1
	BSF   old_new,3
			;
			;     if(cnt != old_cnt)       /* Only print when there is a change in cnt! */
	MOVF  cnt,W
	XORWF old_cnt,W
	BTFSC 0x03,Zero_
	GOTO  m004
			;       printf("Position: %d\r\n", cnt);  /* this function call takes time! */
	CLRF  string
	MOVF  cnt,W
	CALL  printf
			;     old_cnt = cnt;  /* update oldcnt */
m004	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  cnt,W
	MOVWF old_cnt
			;
			;     /* display oneHot  100 010 001 */
			;     PORTC = oneHot; 
	MOVF  oneHot,W
	MOVWF PORTC
			;   }
	GOTO  m001
			;}
			;
			;
			;
			;
			;
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
			;  
			;  TRISC.0=0;
	BCF   TRISC,0
			;  TRISC.1=0;
	BCF   TRISC,1
			;  TRISC.2=0;
	BCF   TRISC,2
			;}
	RETURN
			;
			;
			;
			;void initserial( void )  /* initialise PIC16F690 bitbang serialcom port */
			;{
initserial
			;   ANSEL.0 = 0; /* No AD on RA0             */
	BCF   0x03,RP0
	BSF   0x03,RP1
	BCF   ANSEL,0
			;   ANSEL.1 = 0; /* No AD on RA1             */
	BCF   ANSEL,1
			;   PORTA.0 = 1; /* marking line             */
	BCF   0x03,RP1
	BSF   PORTA,0
			;   TRISA.0 = 0; /* output to PK2 UART-tool  */
	BSF   0x03,RP0
	BCF   TRISA,0
			;   TRISA.1 = 1; /* input from PK2 UART-tool */
	BSF   TRISA,1
			;   return;     
	RETURN
			;}
			;
			;
			;void putchar( char ch )  /* sends one char */
			;{
putchar
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF ch
			;  char bitCount, ti;
			;  PORTA.0 = 0; /* set startbit */
	BCF   PORTA,0
			;  for ( bitCount = 10; bitCount > 0 ; bitCount-- )
	MOVLW 10
	MOVWF bitCount
m005	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  bitCount,1
	BTFSC 0x03,Zero_
	GOTO  m007
			;   {
			;     /* delay one bit 104 usec at 4 MHz       */
			;     /* 5+18*5-1+1+9=104 without optimization */
			;     ti = 18; do ; while( --ti > 0); nop();
	MOVLW 18
	MOVWF ti
m006	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ ti,1
	GOTO  m006
	NOP  
			;     Carry = 1;     /* stopbit                    */
	BSF   0x03,Carry
			;     ch = rr( ch ); /* Rotate Right through Carry */
	RRF   ch,1
			;     PORTA.0 = Carry;
	BTFSS 0x03,Carry
	BCF   PORTA,0
	BTFSC 0x03,Carry
	BSF   PORTA,0
			;   }
	DECF  bitCount,1
	GOTO  m005
			;  return;
m007	RETURN
			;}
			;
			;
			;char getchar( void )  /* recieves one char, blocking */
			;{
getchar
			;   /* One start bit, one stop bit, 8 data bit, no parity = 10 bit. */
			;   /* Baudrate: 9600 baud => 104.167 usec. per bit.                */
			;   char d_in, bitCount, ti;
			;   while( PORTA.1 == 1 ) /* wait for startbit */ ;
m008	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC PORTA,1
	GOTO  m008
			;      /* delay 1,5 bit 156 usec at 4 MHz         */
			;      /* 5+28*5-1+1+2+9=156 without optimization */
			;      ti = 28; do ; while( --ti > 0); nop(); nop2();
	MOVLW 28
	MOVWF ti_2
m009	DECFSZ ti_2,1
	GOTO  m009
	NOP  
	GOTO  m010
			;   for( bitCount = 8; bitCount > 0 ; bitCount--)
m010	MOVLW 8
	MOVWF bitCount_2
m011	MOVF  bitCount_2,1
	BTFSC 0x03,Zero_
	GOTO  m013
			;       {
			;        Carry = PORTA.1;
	BCF   0x03,Carry
	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC PORTA,1
	BSF   0x03,Carry
			;        d_in = rr( d_in);  /* rotate carry */
	RRF   d_in,1
			;         /* delay one bit 104 usec at 4 MHz       */
			;         /* 5+18*5-1+1+9=104 without optimization */
			;         ti = 18; do ; while( --ti > 0); nop();
	MOVLW 18
	MOVWF ti_2
m012	DECFSZ ti_2,1
	GOTO  m012
	NOP  
			;        }
	DECF  bitCount_2,1
	GOTO  m011
			;   return d_in;
m013	MOVF  d_in,W
	RETURN
			;}
			;
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
m014	MOVLW 39
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF TMR0,W
	MOVWF i
			;        while ( i != TMR0)
m015	MOVF  i,W
	BCF   0x03,RP0
	BCF   0x03,RP1
	XORWF TMR0,W
	BTFSS 0x03,Zero_
			;            ;
	GOTO  m015
			;    } while ( --n > 0);
	DECFSZ n,1
	GOTO  m014
			;}
	RETURN
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
m016	BCF   0x03,RP0
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
	GOTO  m038
			;     if( k == '%')           // insert variable in string
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	XORLW 37
	BTFSS 0x03,Zero_
	GOTO  m036
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
	GOTO  m017
	XORLW 17
	BTFSC 0x03,Zero_
	GOTO  m020
	XORLW 23
	BTFSC 0x03,Zero_
	GOTO  m029
	XORLW 1
	BTFSC 0x03,Zero_
	GOTO  m033
	XORLW 70
	BTFSC 0x03,Zero_
	GOTO  m034
	GOTO  m035
			;         {
			;           case 'd':         // %d  signed 8bit
			;             if( variable.7 ==1) putchar('-');
m017	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS variable,7
	GOTO  m018
	MOVLW 45
	CALL  putchar
			;             else putchar(' ');
	GOTO  m019
m018	MOVLW 32
	CALL  putchar
			;             if( variable > 127) variable = -variable;  // no break!
m019	MOVLW 128
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF variable,W
	BTFSS 0x03,Carry
	GOTO  m020
	COMF  variable,1
	INCF  variable,1
			;           case 'u':         // %u unsigned 8bit
			;             a = variable/100;
m020	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	MOVWF C2tmp
	CLRF  C3rem
	MOVLW 8
	MOVWF C1cnt
m021	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C2tmp,1
	RLF   C3rem,1
	MOVLW 100
	SUBWF C3rem,W
	BTFSS 0x03,Carry
	GOTO  m022
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C3rem,1
	BSF   0x03,Carry
m022	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C1cnt,1
	GOTO  m021
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
m023	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C5tmp,1
	RLF   b,1
	MOVLW 100
	SUBWF b,W
	BTFSS 0x03,Carry
	GOTO  m024
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF b,1
m024	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C4cnt,1
	GOTO  m023
			;             a = b/10;
	MOVF  b,W
	MOVWF C7tmp
	CLRF  C8rem
	MOVLW 8
	MOVWF C6cnt
m025	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C7tmp,1
	RLF   C8rem,1
	MOVLW 10
	SUBWF C8rem,W
	BTFSS 0x03,Carry
	GOTO  m026
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C8rem,1
	BSF   0x03,Carry
m026	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C6cnt,1
	GOTO  m025
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
m027	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C10tmp,1
	RLF   a,1
	MOVLW 10
	SUBWF a,W
	BTFSS 0x03,Carry
	GOTO  m028
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF a,1
m028	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C9cnt,1
	GOTO  m027
			;             putchar('0'+a); // print 1's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             break;
	GOTO  m037
			;           case 'b':         // %b BINARY 8bit
			;             for( m = 0 ; m < 8 ; m++ )
m029	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  m
m030	MOVLW 8
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m037
			;              {
			;                if (variable.7 == 1) putchar('1');
	BTFSS variable,7
	GOTO  m031
	MOVLW 49
	CALL  putchar
			;                else putchar('0');
	GOTO  m032
m031	MOVLW 48
	CALL  putchar
			;                variable = rl(variable);
m032	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   variable,1
			;               }
	INCF  m,1
	GOTO  m030
			;              break;
			;           case 'c':         // %c  'char'
			;             putchar(variable);
m033	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	CALL  putchar
			;             break;
	GOTO  m037
			;           case '%':
			;             putchar('%');
m034	MOVLW 37
	CALL  putchar
			;             break;
	GOTO  m037
			;           default:          // not implemented
			;             putchar('!');  
m035	MOVLW 33
	CALL  putchar
			;         }  
			;      }
			;      else putchar(k);
	GOTO  m037
m036	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	CALL  putchar
			;   }
m037	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i_2,1
	GOTO  m016
			;}
m038	RETURN

	END


; *** KEY INFO ***

; 0x0053 P0   14 word(s)  0 % : init
; 0x0061 P0   10 word(s)  0 % : initserial
; 0x006B P0   27 word(s)  1 % : putchar
; 0x0086 P0   30 word(s)  1 % : getchar
; 0x00A4 P0   19 word(s)  0 % : delay10
; 0x00B7 P0  207 word(s) 10 % : printf
; 0x0018 P0   59 word(s)  2 % : main
; 0x0001 P0   23 word(s)  1 % : _const1

; RAM usage: 14 bytes (14 local), 242 bytes free
; Maximum call level: 2
;  Codepage 0 has  390 word(s) :  19 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 390 code words (9 %)
