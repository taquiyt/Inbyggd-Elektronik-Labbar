
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  31. Mar 2017  15:37  *************

	processor  16F690
	radix  DEC

	__config 0xD4

TMR0        EQU   0x01
STATUS      EQU   0x03
PORTA       EQU   0x05
TRISA       EQU   0x85
PORTB       EQU   0x06
TRISB       EQU   0x86
PCLATH      EQU   0x0A
Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
GIE         EQU   7
OPTION_REG  EQU   0x81
PORTC       EQU   0x07
TRISC       EQU   0x87
WPUA        EQU   0x95
IOCA        EQU   0x96
EEDATA      EQU   0x10C
EEADR       EQU   0x10D
EEDATH      EQU   0x10E
EEADRH      EQU   0x10F
ANSEL       EQU   0x11E
EECON2      EQU   0x18D
RABIF       EQU   0
RABIE       EQU   3
EEIF        EQU   4
RD          EQU   0
WR          EQU   1
WREN        EQU   2
EEPGD       EQU   7
X           EQU   0x115
receiver_flag EQU   0
receiver_byte EQU   0x33
svrWREG     EQU   0x70
svrSTATUS   EQU   0x20
svrPCLATH   EQU   0x21
bitCount    EQU   0x22
ti          EQU   0x23
rem         EQU   0x24
choice      EQU   0x25
old_new     EQU   0x26
cnt         EQU   0x27
millisec    EQU   0x7F
n           EQU   0x28
i           EQU   0x29
ch          EQU   0x2F
bitCount_2  EQU   0x30
ti_2        EQU   0x31
string      EQU   0x28
variable    EQU   0x29
i_2         EQU   0x2A
k           EQU   0x2B
m           EQU   0x2C
a           EQU   0x2D
b           EQU   0x2E
C1cnt       EQU   0x2F
C2tmp       EQU   0x30
C3rem       EQU   0x31
C4cnt       EQU   0x2F
C5tmp       EQU   0x30
C6cnt       EQU   0x2F
C7tmp       EQU   0x30
C8rem       EQU   0x31
C9cnt       EQU   0x2F
C10tmp      EQU   0x30
data        EQU   0x28
adress      EQU   0x29
adress_2    EQU   0x28
temp        EQU   0x29
ci          EQU   0x2F

	GOTO main

  ; FILE menu.c
			;/* menu.c  test components on the breadboard                */
			;/* PIC16F690 compiled with B. Knudsen Cc5x Free, not ANSI-C */
			;
			;/*
			;   Use "PICkit2 UART Tool" as a 9600 Baud terminal.
			;   Uncheck "Echo On".
			;   PIC internal UART is not used.
			;*/
			;
			;#include "16F690.h"
			;#include "int16Cxx.h"
			;#pragma config |= 0x00D4
			;#pragma char X @ 0x115
			;
			;void delay( char);
			;void delay10( char);
			;void init_io_ports( void );
			;void init_serial( void );
			;void init_interrupt( void );
			;void putchar( char);
			;void printf(const char *string, char variable);
			;char getchar_eedata( char adress );
			;void putchar_eedata( char data, char adress );
			;
			;
			;bit receiver_flag;   /* Signal-flag used by interrupt routine   */
			;char receiver_byte;  /* Transfer Byte used by interrupt routine */
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
			;  /* New interrupts are automaticaly disabled            */
			;  /* "Interrupt on change" at pin RA1 from PK2 UART-tool */
			;  
			;  if( PORTA.1 == 0 )  /* Interpret this as the startbit  */
	BTFSC PORTA,1
	GOTO  m006
			;    {  /* Receive one full character   */
			;      char bitCount, ti;
			;      /* delay 1,5 bit 156 usec at 4 MHz         */
			;      /* 5+28*5-1+1+2+9=156 without optimization */
			;      ti = 28; do ; while( --ti > 0); nop(); nop2();
	MOVLW 28
	MOVWF ti
m001	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ ti,1
	GOTO  m001
	NOP  
	GOTO  m002
			;      for( bitCount = 8; bitCount > 0 ; bitCount--)
m002	MOVLW 8
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF bitCount
m003	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  bitCount,1
	BTFSC 0x03,Zero_
	GOTO  m005
			;       {
			;         Carry = PORTA.1;
	BCF   0x03,Carry
	BTFSC PORTA,1
	BSF   0x03,Carry
			;         receiver_byte = rr( receiver_byte);  /* rotate carry */
	RRF   receiver_byte,1
			;         /* delay one bit 104 usec at 4 MHz       */
			;         /* 5+18*5-1+1+9=104 without optimization */ 
			;         ti = 18; do ; while( --ti > 0); nop(); 
	MOVLW 18
	MOVWF ti
m004	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ ti,1
	GOTO  m004
	NOP  
			;        }
	DECF  bitCount,1
	GOTO  m003
			;      receiver_flag = 1; /* A full character is now received */
m005	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x32,receiver_flag
			;    }
			;  RABIF = 0;    /* Reset the RABIF-flag before leaving   */
m006	BCF   0x0B,RABIF
			;  int_restore_registers
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  svrPCLATH,W
	MOVWF PCLATH
	SWAPF svrSTATUS,W
	MOVWF STATUS
	SWAPF svrWREG,1
	SWAPF svrWREG,W
			;  /* New interrupts are now enabled */
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
	MOVLW 0
	BSF   0x03,RP1
	MOVWF EEADRH
	BCF   0x03,RP1
	RRF   ci,W
	ANDLW 127
	ADDLW 90
	BSF   0x03,RP1
	MOVWF EEADR
	BTFSC 0x03,Carry
	INCF  EEADRH,1
	BSF   0x03,RP0
	BSF   0x03,RP1
	BSF   0x18C,EEPGD
	BSF   0x18C,RD
	NOP  
	NOP  
	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC ci,0
	GOTO  m007
	BSF   0x03,RP1
	MOVF  EEDATA,W
	ANDLW 127
	RETURN
m007	BCF   0x03,RP0
	BSF   0x03,RP1
	RLF   EEDATA,W
	RLF   EEDATH,W
	RETURN
	DW    0x32CD
	DW    0x3AEE
	DW    0x103A
	DW    0x1631
	DW    0x1920
	DW    0x102C
	DW    0x6B3
	DW    0xA
	DW    0x3225
	DW    0x1280
	DW    0x1063
	DW    0x22CC
	DW    0x1844
	DW    0x3720
	DW    0x3BEF
	DW    0x103A
	DW    0x334F
	DW    0x6E6
	DW    0xA
	DW    0x31A5
	DW    0x2620
	DW    0x2245
	DW    0x1031
	DW    0x37EE
	DW    0x1D77
	DW    0x27A0
	DW    0x6EE
	DW    0xA
	DW    0x31A5
	DW    0x2620
	DW    0x2245
	DW    0x1031
	DW    0x37EE
	DW    0x1D77
	DW    0x27A0
	DW    0x3366
	DW    0x50D
	DW    0x1280
	DW    0x1063
	DW    0x3AC2
	DW    0x3A74
	DW    0x376F
	DW    0x3B20
	DW    0x3661
	DW    0x32F5
	DW    0x34A0
	DW    0x1D73
	DW    0x20
	DW    0x3AA5
	DW    0x50D
	DW    0x1280
	DW    0x1063
	DW    0x22CC
	DW    0x1844
	DW    0x3720
	DW    0x3BEF
	DW    0x103A
	DW    0x274F
	DW    0x50D
	DW    0x1280
	DW    0x1063
	DW    0x37D9
	DW    0x1075
	DW    0x3AED
	DW    0x3A73
	DW    0x31A0
	DW    0x37E8
	DW    0x39EF
	DW    0x1065
	DW    0x32E2
	DW    0x3BF4
	DW    0x32E5
	DW    0x1D6E
	DW    0x18A0
	DW    0x102C
	DW    0x1632
	DW    0x19A0
	DW    0x50D
	DW    0x1280
	DW    0x564
	DW    0x0
main
			;	int rem;
			;  char choice; char old_new = 0; int cnt = 0;
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  old_new
	CLRF  cnt
			;  init_io_ports();
	CALL  init_io_ports
			;  init_serial();
	CALL  init_serial
			;  init_interrupt();
	CALL  init_interrupt
			;
			;  /* You should "connect" PK2 UART-tool in one second after power on! */
			;  delay10(100); 
	MOVLW 100
	CALL  delay10
			;  printf("Menu: 1, 2, 3\r\n",0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  string
	MOVLW 0
	CALL  printf
			;  cnt = getchar_eedata(40);
	MOVLW 40
	CALL  getchar_eedata
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF cnt
			;  printf("%d",cnt);
	MOVLW 16
	MOVWF string
	MOVF  cnt,W
	CALL  printf
			;
			;  while(1)
			;   {
			;     if( receiver_flag ) /* Character received? */ 
m008	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS 0x32,receiver_flag
	GOTO  m018
			;      {
			;        choice = receiver_byte; /* get Character from interrupt routine */
	MOVF  receiver_byte,W
	MOVWF choice
			;        receiver_flag = 0;      /* Character now taken - reset the flag */
	BCF   0x32,receiver_flag
			;
			;        switch (choice)
	MOVF  choice,W
	XORLW 49
	BTFSC 0x03,Zero_
	GOTO  m009
	XORLW 64
	BTFSC 0x03,Zero_
	GOTO  m010
	XORLW 67
	BTFSC 0x03,Zero_
	GOTO  m011
	XORLW 69
	BTFSC 0x03,Zero_
	GOTO  m012
	XORLW 68
	BTFSC 0x03,Zero_
	GOTO  m013
	XORLW 86
	BTFSC 0x03,Zero_
	GOTO  m014
	XORLW 81
	BTFSC 0x03,Zero_
	GOTO  m015
	XORLW 71
	BTFSC 0x03,Zero_
	GOTO  m016
	GOTO  m017
			;         {
			;          case '1':
			;           PORTC.0 = 1;
m009	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   PORTC,0
			;           printf("%c LED0 now: ON\r\n", choice);
	MOVLW 101
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           break;
	GOTO  m018
			;          case 'q':
			;           PORTC.0 = 0;
m010	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   PORTC,0
			;           printf("%c LED0 now: Off\r\n", choice);
	MOVLW 19
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           break;
	GOTO  m018
			;		  case '2':
			;		   PORTC.1 = 1;
m011	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   PORTC,1
			;           printf("%c LED1 now: On\r\n", choice);
	MOVLW 38
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           break;
	GOTO  m018
			;		  case 'w':
			;		   PORTC.1 = 0;
m012	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   PORTC,1
			;           printf("%c LED1 now: Off\r\n", choice);
	MOVLW 56
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           break;
	GOTO  m018
			;		  case '3':
			;		   PORTC.2 = 1;
m013	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   PORTC,2
			;           printf("%c LED1 now: On\r\n", choice);
	MOVLW 38
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           break;
	GOTO  m018
			;		  case 'e':
			;		   PORTC.2 = 0;
m014	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   PORTC,2
			;           printf("%c LED1 now: Off\r\n", choice);
	MOVLW 56
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           break; 
	GOTO  m018
			;          case '4':
			;           printf("%c Button value is: ", choice);
m015	MOVLW 75
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           printf("%u\r\n", (char) PORTB.6);
	MOVLW 96
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF string
	CLRW 
	BTFSC PORTB,6
	MOVLW 1
	CALL  printf
			;           break;
	GOTO  m018
			;			case 's':
			;           putchar_eedata(cnt,40);
m016	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  cnt,W
	MOVWF data
	MOVLW 40
	CALL  putchar_eedata
			;           printf("%c LED0 now: ON\r\n", choice);
	MOVLW 101
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;           break;
	GOTO  m018
			;          default:
			;           printf("%c You must choose between: 1, 2, 3\r\n", choice);
m017	MOVLW 119
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF string
	MOVF  choice,W
	CALL  printf
			;         }
			;      }     
			;     /* if no Character is received we always loop here */
			;	 
			;	 rem = cnt;
m018	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  cnt,W
	MOVWF rem
			;
			;	
			;	 
			;	 /* read encoder new value */
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
			;	  if(rem != cnt){
	MOVF  rem,W
	XORWF cnt,W
	BTFSC 0x03,Zero_
	GOTO  m008
			;		printf("%d\n",cnt);
	MOVLW 157
	MOVWF string
	MOVF  cnt,W
	CALL  printf
			;	 }
			;   }
	GOTO  m008
			;}
			;
			;
			;
			;
			;/* *********************************** */
			;/*            FUNCTIONS                */
			;/* *********************************** */
			;
			;
			;void delay( char millisec)
			;{
delay
	MOVWF millisec
			;    OPTION = 2;  /* prescaler divide by 8        */
	MOVLW 2
	BSF   0x03,RP0
	BCF   0x03,RP1
	MOVWF OPTION_REG
			;    do  {  TMR0 = 0;
m019	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  TMR0
			;           while ( TMR0 < 125)   /* 125 * 8 = 1000  */ ;
m020	MOVLW 125
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF TMR0,W
	BTFSS 0x03,Carry
	GOTO  m020
			;        } while ( -- millisec > 0);
	DECFSZ millisec,1
	GOTO  m019
			;}
	RETURN
			;
			;void delay10( char n)
			;{
delay10
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF n
			;    char i; OPTION = 7;
	MOVLW 7
	BSF   0x03,RP0
	MOVWF OPTION_REG
			;    do  { i = TMR0 + 39; /* 256 microsec * 39 = 10 ms */
m021	MOVLW 39
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF TMR0,W
	MOVWF i
			;           while ( i != TMR0)  ;
m022	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i,W
	XORWF TMR0,W
	BTFSS 0x03,Zero_
	GOTO  m022
			;        } while ( --n > 0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ n,1
	GOTO  m021
			;}
	RETURN
			;
			;void init_io_ports( void )
			;{
init_io_ports
			;  TRISC = 0xF8; /* 11111000 0 is for outputbit  */
	MOVLW 248
	BSF   0x03,RP0
	BCF   0x03,RP1
	MOVWF TRISC
			;  PORTC = 0b000;    /* initial value */
	BCF   0x03,RP0
	CLRF  PORTC
			;
			;  ANSEL =0;     /* not AD-input      */
	BSF   0x03,RP1
	CLRF  ANSEL
			;  TRISA.5 = 1;  /* input rpgA        */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   TRISA,5
			;  TRISA.4 = 1;  /* input rpgB        */
	BSF   TRISA,4
			;  /* Enable week pullup's            */
			;  OPTION.7 = 0; /* !RABPU bit        */
	BCF   OPTION_REG,7
			;  WPUA.5   = 1; /* rpgA pullup       */
	BSF   WPUA,5
			;  WPUA.4   = 1; /* rpgB pullup       */
	BSF   WPUA,4
			;  X.6 = 1;
	BCF   0x03,RP0
	BSF   0x03,RP1
	BSF   X,6
			;  TRISB.6 = 1;  /* PORTB pin 6 input */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   TRISB,6
			;  
			;  return;
	RETURN
			;}
			;
			;void init_serial( void )  /* initialise PIC16F690 bitbang serialcom */
			;{
init_serial
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
			;   receiver_flag = 0 ;
	BCF   0x03,RP0
	BCF   0x32,receiver_flag
			;   return;      
	RETURN
			;}
			;
			;void init_interrupt( void )
			;{
init_interrupt
			;  IOCA.1 = 1; /* PORTA.1 interrupt on change */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   IOCA,1
			;  RABIE =1;   /* interrupt on change         */
	BSF   0x0B,RABIE
			;  GIE = 1;    /* interrupt enable            */
	BSF   0x0B,GIE
			;  return;
	RETURN
			;}
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
	MOVWF bitCount_2
m023	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  bitCount_2,1
	BTFSC 0x03,Zero_
	GOTO  m025
			;   {
			;     /* delay one bit 104 usec at 4 MHz       */
			;     /* 5+18*5-1+1+9=104 without optimization */ 
			;     ti = 18; do ; while( --ti > 0); nop(); 
	MOVLW 18
	MOVWF ti_2
m024	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ ti_2,1
	GOTO  m024
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
	DECF  bitCount_2,1
	GOTO  m023
			;  return;
m025	RETURN
			;}
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
m026	BCF   0x03,RP0
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
	GOTO  m048
			;     if( k == '%')           // insert variable in string
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	XORLW 37
	BTFSS 0x03,Zero_
	GOTO  m046
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
	GOTO  m027
	XORLW 17
	BTFSC 0x03,Zero_
	GOTO  m030
	XORLW 23
	BTFSC 0x03,Zero_
	GOTO  m039
	XORLW 1
	BTFSC 0x03,Zero_
	GOTO  m043
	XORLW 70
	BTFSC 0x03,Zero_
	GOTO  m044
	GOTO  m045
			;         {
			;           case 'd':         // %d  signed 8bit
			;             if( variable.7 ==1) putchar('-');
m027	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS variable,7
	GOTO  m028
	MOVLW 45
	CALL  putchar
			;             else putchar(' ');
	GOTO  m029
m028	MOVLW 32
	CALL  putchar
			;             if( variable > 127) variable = -variable;  // no break!
m029	MOVLW 128
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF variable,W
	BTFSS 0x03,Carry
	GOTO  m030
	COMF  variable,1
	INCF  variable,1
			;           case 'u':         // %u unsigned 8bit
			;             a = variable/100;
m030	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	MOVWF C2tmp
	CLRF  C3rem
	MOVLW 8
	MOVWF C1cnt
m031	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C2tmp,1
	RLF   C3rem,1
	MOVLW 100
	SUBWF C3rem,W
	BTFSS 0x03,Carry
	GOTO  m032
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C3rem,1
	BSF   0x03,Carry
m032	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C1cnt,1
	GOTO  m031
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
m033	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C5tmp,1
	RLF   b,1
	MOVLW 100
	SUBWF b,W
	BTFSS 0x03,Carry
	GOTO  m034
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF b,1
m034	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C4cnt,1
	GOTO  m033
			;             a = b/10;
	MOVF  b,W
	MOVWF C7tmp
	CLRF  C8rem
	MOVLW 8
	MOVWF C6cnt
m035	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C7tmp,1
	RLF   C8rem,1
	MOVLW 10
	SUBWF C8rem,W
	BTFSS 0x03,Carry
	GOTO  m036
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C8rem,1
	BSF   0x03,Carry
m036	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C6cnt,1
	GOTO  m035
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
m037	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C10tmp,1
	RLF   a,1
	MOVLW 10
	SUBWF a,W
	BTFSS 0x03,Carry
	GOTO  m038
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF a,1
m038	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C9cnt,1
	GOTO  m037
			;             putchar('0'+a); // print 1's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             break;
	GOTO  m047
			;           case 'b':         // %b BINARY 8bit
			;             for( m = 0 ; m < 8 ; m++ )
m039	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  m
m040	MOVLW 8
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m047
			;              {
			;                if (variable.7 == 1) putchar('1');
	BTFSS variable,7
	GOTO  m041
	MOVLW 49
	CALL  putchar
			;                else putchar('0');
	GOTO  m042
m041	MOVLW 48
	CALL  putchar
			;                variable = rl(variable);
m042	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   variable,1
			;               }
	INCF  m,1
	GOTO  m040
			;              break;
			;           case 'c':         // %c  'char'
			;             putchar(variable);
m043	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	CALL  putchar
			;             break;
	GOTO  m047
			;           case '%':
			;             putchar('%');
m044	MOVLW 37
	CALL  putchar
			;             break;
	GOTO  m047
			;           default:          // not implemented
			;             putchar('!');
m045	MOVLW 33
	CALL  putchar
			;         }
			;      }
			;      else putchar(k);
	GOTO  m047
m046	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	CALL  putchar
			;   }
m047	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i_2,1
	GOTO  m026
			;}
m048	RETURN
			;
			;void putchar_eedata( char data, char adress )
			;{
putchar_eedata
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF adress
			;/* Put char in specific EEPROM-adress */
			;      /* Write EEPROM-data sequence                          */
			;      EEADR = adress;     /* EEPROM-data adress 0x00 => 0x40 */
	MOVF  adress,W
	BSF   0x03,RP1
	MOVWF EEADR
			;      EEPGD = 0;          /* Data, not Program memory        */  
	BSF   0x03,RP0
	BCF   0x18C,EEPGD
			;      EEDATA = data;      /* data to be written              */
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  data,W
	BSF   0x03,RP1
	MOVWF EEDATA
			;      WREN = 1;           /* write enable                    */
	BSF   0x03,RP0
	BSF   0x18C,WREN
			;      EECON2 = 0x55;      /* first Byte in comandsequence    */
	MOVLW 85
	MOVWF EECON2
			;      EECON2 = 0xAA;      /* second Byte in comandsequence   */
	MOVLW 170
	MOVWF EECON2
			;      WR = 1;             /* write                           */
	BSF   0x18C,WR
			;      while( EEIF == 0) ; /* wait for done (EEIF=1)          */
m049	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS 0x0D,EEIF
	GOTO  m049
			;      WR = 0;
	BSF   0x03,RP0
	BSF   0x03,RP1
	BCF   0x18C,WR
			;      WREN = 0;           /* write disable - safety first    */
	BCF   0x18C,WREN
			;      EEIF = 0;           /* Reset EEIF bit in software      */
	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   0x0D,EEIF
			;      /* End of write EEPROM-data sequence                   */
			;}
	RETURN
			;
			;
			;char getchar_eedata( char adress )
			;{
getchar_eedata
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF adress_2
			;/* Get char from specific EEPROM-adress */
			;      /* Start of read EEPROM-data sequence                */
			;      char temp;
			;      EEADR = adress;  /* EEPROM-data adress 0x00 => 0x40  */ 
	MOVF  adress_2,W
	BSF   0x03,RP1
	MOVWF EEADR
			;      EEPGD = 0;       /* Data not Program -memory         */      
	BSF   0x03,RP0
	BCF   0x18C,EEPGD
			;      RD = 1;          /* Read                             */
	BSF   0x18C,RD
			;      temp = EEDATA;
	BCF   0x03,RP0
	MOVF  EEDATA,W
	BCF   0x03,RP1
	MOVWF temp
			;      RD = 0;
	BSF   0x03,RP0
	BSF   0x03,RP1
	BCF   0x18C,RD
			;      return temp;     /* data to be read                  */
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  temp,W
	RETURN

	END


; *** KEY INFO ***

; 0x0159 P0   17 word(s)  0 % : delay
; 0x016A P0   22 word(s)  1 % : delay10
; 0x0180 P0   22 word(s)  1 % : init_io_ports
; 0x0196 P0   12 word(s)  0 % : init_serial
; 0x01A2 P0    6 word(s)  0 % : init_interrupt
; 0x01A8 P0   27 word(s)  1 % : putchar
; 0x01C3 P0  207 word(s) 10 % : printf
; 0x02B2 P0   20 word(s)  0 % : getchar_eedata
; 0x0292 P0   32 word(s)  1 % : putchar_eedata
; 0x0004 P0   53 word(s)  2 % : int_server
; 0x00AB P0  174 word(s)  8 % : main
; 0x0039 P0  114 word(s)  5 % : _const1

; RAM usage: 21 bytes (19 local), 235 bytes free
; Maximum call level: 2 (+1 for interrupt)
;  Codepage 0 has  707 word(s) :  34 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 707 code words (17 %)
