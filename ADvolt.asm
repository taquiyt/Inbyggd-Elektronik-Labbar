
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************   3. Apr 2017  15:26  *************

	processor  16F690
	radix  DEC

	__config 0xD4

INDF        EQU   0x00
TMR0        EQU   0x01
PCL         EQU   0x02
FSR         EQU   0x04
PORTA       EQU   0x05
TRISA       EQU   0x85
PORTB       EQU   0x06
TRISB       EQU   0x86
PCLATH      EQU   0x0A
Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
IRP         EQU   7
OPTION_REG  EQU   0x81
PORTC       EQU   0x07
ADRESH      EQU   0x1E
ADCON0      EQU   0x1F
TRISC       EQU   0x87
ADRESL      EQU   0x9E
ADCON1      EQU   0x9F
ANSEL       EQU   0x11E
GO          EQU   1
advalue     EQU   0x20
C1cnt       EQU   0x22
C2tmp       EQU   0x23
ch          EQU   0x2F
bitCount    EQU   0x30
ti          EQU   0x31
string      EQU   0x22
i           EQU   0x23
k           EQU   0x24
number      EQU   0x22
decimalPlaces EQU   0x24
un_signed   EQU   0
string_2    EQU   0x25
i_2         EQU   0x2C
temp        EQU   0x2D
C3cnt       EQU   0x2F
C4tmp       EQU   0x30
C5cnt       EQU   0x2F
C6tmp       EQU   0x30
C7rem       EQU   0x32
n           EQU   0x22
i_3         EQU   0x23
ci          EQU   0x25

	GOTO main

  ; FILE ADvolt.c
			;/* ADvolt.c 16F690 1 value AD-logg            */
			;/* Sends A2 value to UART-tool on key-press   */
			;
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;#include "16F690.h"
			;#pragma config |= 0x00D4 
			;
			;/* This value is correct for unipolar AD values                      */ 
			;#define OFFSET 0
			;/* The SCALE_FACTOR value is wrong - you should correct it!          */
			;#define SCALE_FACTOR 59 // ska vara 49
			;/* The DECIMALS value is wrong - you should correct it!              */
			;#define DECIMALS 4 //decimal ska vara 4
			;/* This value is correct the AD-value is unsigned (allways positive) */
			;#define UN_SIGNED 1
			;
			;/* Decimal mark: point or comma - what do you like?                   */
			;#define DECIMAL_MARK ','
			;
			;void initserial( void );
			;void ADinit( void );
			;void putchar( char );
			;void string_out( const char * ); 
			;void longDecimal_out(long number, char decimalPlaces, bit un_signed); 
			;void delay10( char );
			;
			;void main(void)
			;{
_const1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF ci
	CLRF  PCLATH
	MOVF  ci,W
	ANDLW 7
	ADDWF PCL,1
	RETLW 85
	RETLW 32
	RETLW 91
	RETLW 86
	RETLW 93
	RETLW 13
	RETLW 10
	RETLW 0
main
			;  unsigned long advalue;
			;  TRISC.0 = 0; // lightdiode at RC0 is output
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   TRISC,0
			;  PORTC.0 = 0; // no light
	BCF   0x03,RP0
	BCF   PORTC,0
			;  TRISB.6 = 1; // switch SW is input
	BSF   0x03,RP0
	BSF   TRISB,6
			;
			;  initserial();
	CALL  initserial
			;  ADinit();
	CALL  ADinit
			;  delay10(100); 
	MOVLW 100
	CALL  delay10
			;
			;  // Header text
			;  string_out("U [V]\r\n");
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  string
	CALL  string_out
			;
			;  while(1)
			;   {
			;     while(PORTB.6) ; // wait for key pressed - new measurement 
m001	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC PORTB,6
	GOTO  m001
			;     PORTC.0=1;       // LED Sampling indicator
	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   PORTC,0
			;	
			;      /* Now measure the Voltage [V]  */
			;      GO=1;         // start AD
	BSF   0x1F,GO
			;      while(GO);    // wait for done
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC 0x1F,GO
	GOTO  m002
			;      advalue = ADRESH*256;    // read result 10 bit
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  ADRESH,W
	MOVWF advalue+1
	CLRF  advalue
			;      advalue += ADRESL;
	BSF   0x03,RP0
	MOVF  ADRESL,W
	BCF   0x03,RP0
	ADDWF advalue,1
	BTFSC 0x03,Carry
	INCF  advalue+1,1
			;	  advalue -= OFFSET;  // no offset needed
			;      // 1024 -> 5,0000 [V]
			;      // multiply with integer scalefactor
			;      // and place the decimal mark correct
			;      // the supplied scalefactor is wrong please correct it!
			;	  advalue *= SCALE_FACTOR ;  
	MOVF  advalue,W
	MOVWF C2tmp
	MOVF  advalue+1,W
	MOVWF C2tmp+1
	MOVLW 16
	MOVWF C1cnt
m003	BCF   0x03,Carry
	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   advalue,1
	RLF   advalue+1,1
	RLF   C2tmp,1
	RLF   C2tmp+1,1
	BTFSS 0x03,Carry
	GOTO  m004
	MOVLW 59
	ADDWF advalue,1
	BTFSC 0x03,Carry
	INCF  advalue+1,1
m004	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C1cnt,1
	GOTO  m003
			;	  advalue=60000-advalue;
	MOVF  advalue+1,W
	SUBLW 234
	MOVWF advalue+1
	MOVF  advalue,W
	SUBLW 96
	MOVWF advalue
	BTFSS 0x03,Carry
	DECF  advalue+1,1
			;	  // the supplied number of decimals is wrong please correct it!
			;      longDecimal_out(advalue, DECIMALS, UN_SIGNED); 
	MOVF  advalue,W
	MOVWF number
	MOVF  advalue+1,W
	MOVWF number+1
	MOVLW 4
	MOVWF decimalPlaces
	BSF   0x2E,un_signed
	CALL  longDecimal_out
			;      putchar('\r'); putchar('\n');
	MOVLW 13
	CALL  putchar
	MOVLW 10
	CALL  putchar
			;
			;      delay10(1);         // Debounce
	MOVLW 1
	CALL  delay10
			;      PORTC.0=0;          // LED off measurement done 
	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   PORTC,0
			;      while (!PORTB.6) ;  // wait for key released
m005	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS PORTB,6
	GOTO  m005
			;      delay10(1);         // Debounce
	MOVLW 1
	CALL  delay10
			;     }
	GOTO  m001
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
			;/* **** ADconverter function ************** */
			;
			;void ADinit( void )
			;{
ADinit
			;  // AD setup 
			;  ANSEL.2 = 1; // RA2 AN2 analog configurated
	BCF   0x03,RP0
	BSF   0x03,RP1
	BSF   ANSEL,2
			;  TRISA.2=1;   // AN2 input
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   TRISA,2
			;
			;  ADCON1 = 0b0.101.0000; // AD conversion clock 'fosc/16'
	MOVLW 80
	MOVWF ADCON1
			;
			;  /* 
			;     1.x.xxxx.x.x  ADRESH:ADRESL is 10 bit right justified
			;     x.0.xxxx.x.x  Vref is Vdd
			;     x.x.0010.x.x  Channel (AN2) 
			;     x.x.xxxx.0.x  Go/!Done - start from program later
			;     x.x.xxxx.x.1  Enable AD-converter
			;  */
			;  ADCON0 = 0b1.0.0010.0.1; 
	MOVLW 137
	BCF   0x03,RP0
	MOVWF ADCON0
			;}
	RETURN
			;
			;
			;/* **** bitbanging serial communication **** */
			;
			;void initserial( void )  /* initialise PIC16F690 bbCom */
			;{
initserial
			;   ANSEL.0 = 0; // No AD on RA0
	BCF   0x03,RP0
	BSF   0x03,RP1
	BCF   ANSEL,0
			;   PORTA.0 = 1; // marking line
	BCF   0x03,RP1
	BSF   PORTA,0
			;   TRISA.0 = 0; // output to PK2 UART-tool
	BSF   0x03,RP0
	BCF   TRISA,0
			;   return;      
	RETURN
			;}
			;
			;
			;void putchar( char ch )  // sends one char bitbanging
			;{
putchar
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF ch
			;  char bitCount, ti;
			;  PORTA.0 = 0; // set startbit
	BCF   PORTA,0
			;  for ( bitCount = 10; bitCount > 0 ; bitCount-- )
	MOVLW 10
	MOVWF bitCount
m006	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  bitCount,1
	BTFSC 0x03,Zero_
	GOTO  m008
			;   {
			;     // delay one bit 104 usec at 4 MHz
			;     // 5+18*5-1+1+9=104 without optimization 
			;     ti = 18; do ; while( --ti > 0); nop(); 
	MOVLW 18
	MOVWF ti
m007	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ ti,1
	GOTO  m007
	NOP  
			;     Carry = 1;     // stopbit
	BSF   0x03,Carry
			;     ch = rr( ch ); // Rotate Right through Carry
	RRF   ch,1
			;     PORTA.0 = Carry;
	BTFSS 0x03,Carry
	BCF   PORTA,0
	BTFSC 0x03,Carry
	BSF   PORTA,0
			;   }
	DECF  bitCount,1
	GOTO  m006
			;  return;
m008	RETURN
			;}
			;
			;void string_out(const char * string)
			;{
string_out
			;  char i, k;
			;  for(i = 0 ; ; i++)
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  i
			;   {
			;     k = string[i];
m009	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i,W
	ADDWF string,W
	CALL  _const1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF k
			;     if( k == '\0') return;   // found end of string
	MOVF  k,1
	BTFSC 0x03,Zero_
	RETURN
			;     putchar(k); 
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	CALL  putchar
			;   }
	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i,1
	GOTO  m009
			;}
			;
			;
			;/* **** print decimal number **** */
			;
			;void longDecimal_out(long number, char decimalPlaces, bit un_signed)
			;{
longDecimal_out
			;   char string[7]; // temporary buffer for reordering characters
			;   char i,temp;
			;   string[6] = '\0';
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  string_2+6
			;   string[0] = '+'; 
	MOVLW 43
	MOVWF string_2
			; if(!un_signed)
	BTFSC 0x2E,un_signed
	GOTO  m010
			;  {
			;    if (number < 0 )
	BTFSS number+1,7
	GOTO  m010
			;     {
			;       string[0] = '-'; 
	MOVLW 45
	MOVWF string_2
			;       number = -number;
	COMF  number+1,1
	COMF  number,1
	INCF  number,1
	BTFSC 0x03,Zero_
	INCF  number+1,1
			;     }
			;  } 
			;  
			;   for (i = 5; ;i--)
m010	MOVLW 5
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF i_2
			;     {
			;       temp = (uns16)number % 10;
m011	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  number,W
	MOVWF C4tmp
	MOVF  number+1,W
	MOVWF C4tmp+1
	CLRF  temp
	MOVLW 16
	MOVWF C3cnt
m012	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C4tmp,1
	RLF   C4tmp+1,1
	RLF   temp,1
	BTFSC 0x03,Carry
	GOTO  m013
	MOVLW 10
	SUBWF temp,W
	BTFSS 0x03,Carry
	GOTO  m014
m013	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF temp,1
m014	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C3cnt,1
	GOTO  m012
			;       temp += '0';
	MOVLW 48
	ADDWF temp,1
			;       string[i]=temp;
	MOVLW 37
	ADDWF i_2,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  temp,W
	MOVWF INDF
			;       if (i==1) break;
	DECF  i_2,W
	BTFSC 0x03,Zero_
	GOTO  m018
			;       (uns16)number /= 10;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  number,W
	MOVWF C6tmp
	MOVF  number+1,W
	MOVWF C6tmp+1
	CLRF  C7rem
	MOVLW 16
	MOVWF C5cnt
m015	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C6tmp,1
	RLF   C6tmp+1,1
	RLF   C7rem,1
	BTFSC 0x03,Carry
	GOTO  m016
	MOVLW 10
	SUBWF C7rem,W
	BTFSS 0x03,Carry
	GOTO  m017
m016	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C7rem,1
	BSF   0x03,Carry
m017	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   number,1
	RLF   number+1,1
	DECFSZ C5cnt,1
	GOTO  m015
			;     }
	DECF  i_2,1
	GOTO  m011
			;   for(i = 0 ; ; i++)
m018	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  i_2
			;     {
			;        if(i==6-decimalPlaces) putchar( DECIMAL_MARK ); 
m019	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  decimalPlaces,W
	SUBLW 6
	XORWF i_2,W
	BTFSS 0x03,Zero_
	GOTO  m020
	MOVLW 44
	CALL  putchar
			;        temp = string[i];
m020	MOVLW 37
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF i_2,W
	MOVWF FSR
	BCF   0x03,IRP
	MOVF  INDF,W
	MOVWF temp
			;        if( temp == '\0') return;   // found end of string
	MOVF  temp,1
	BTFSC 0x03,Zero_
	RETURN
			;        putchar(temp); 
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  temp,W
	CALL  putchar
			;     }
	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i_2,1
	GOTO  m019
			;} 
			;
			;
			;/* **** delay function **** */
			;
			;void delay10( char n)
			;{
delay10
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF n
			;    char i;
			;    OPTION = 7;
	MOVLW 7
	BSF   0x03,RP0
	MOVWF OPTION_REG
			;    do  {  i = TMR0 + 39; /* 256 microsec * 39 = 10 ms */
m021	MOVLW 39
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF TMR0,W
	MOVWF i_3
			;        while ( i != TMR0) ;
m022	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i_3,W
	XORWF TMR0,W
	BTFSS 0x03,Zero_
	GOTO  m022
			;    } while ( --n > 0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ n,1
	GOTO  m021
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x0079 P0    8 word(s)  0 % : initserial
; 0x006D P0   12 word(s)  0 % : ADinit
; 0x0081 P0   27 word(s)  1 % : putchar
; 0x009C P0   22 word(s)  1 % : string_out
; 0x00B2 P0  123 word(s)  6 % : longDecimal_out
; 0x012D P0   22 word(s)  1 % : delay10
; 0x0010 P0   93 word(s)  4 % : main
; 0x0001 P0   15 word(s)  0 % : _const1

; RAM usage: 19 bytes (19 local), 237 bytes free
; Maximum call level: 2
;  Codepage 0 has  323 word(s) :  15 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 323 code words (7 %)
