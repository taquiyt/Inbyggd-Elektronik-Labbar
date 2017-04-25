
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  21. Apr 2017  14:02  *************

	processor  16F690
	radix  DEC

	__config 0xD4

TMR0        EQU   0x01
PORTA       EQU   0x05
TRISA       EQU   0x85
PORTB       EQU   0x06
TRISB       EQU   0x86
Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
OPTION_REG  EQU   0x81
PORTC       EQU   0x07
T2CON       EQU   0x12
CCPR1L      EQU   0x15
CCP1CON     EQU   0x17
ADRESH      EQU   0x1E
ADCON0      EQU   0x1F
TRISC       EQU   0x87
PR2         EQU   0x92
ADCON1      EQU   0x9F
EEDATA      EQU   0x10C
EEADR       EQU   0x10D
EEDATH      EQU   0x10E
EEADRH      EQU   0x10F
ANSEL       EQU   0x11E
GO          EQU   1
RD          EQU   0
EEPGD       EQU   7
advalue     EQU   0x20
duty        EQU   0x21
tmp1        EQU   0x22
tmp2        EQU   0x24
C1cnt       EQU   0x26
C2tmp       EQU   0x27
ch          EQU   0x2D
bitCount    EQU   0x2E
ti          EQU   0x2F
string      EQU   0x26
variable    EQU   0x27
i           EQU   0x28
k           EQU   0x29
m           EQU   0x2A
a           EQU   0x2B
b           EQU   0x2C
C3cnt       EQU   0x2D
C4tmp       EQU   0x2E
C5rem       EQU   0x2F
C6cnt       EQU   0x2D
C7tmp       EQU   0x2E
C8cnt       EQU   0x2D
C9tmp       EQU   0x2E
C10rem      EQU   0x2F
C11cnt      EQU   0x2D
C12tmp      EQU   0x2E
n           EQU   0x26
i_2         EQU   0x27
ci          EQU   0x2D

	GOTO main

  ; FILE duty_value.c
			;/* duty_value.c PIC 16F690 reads PWM-duty from POT           */
			;/* prints DutyCycle in percent with UART tool on key-press   */
			;
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;#include "16F690.h"
			;#pragma config |= 0x00D4 
			;
			;void initserial( void );
			;void ADinit( void );
			;void PWMinit( void );
			;void putchar( char );
			;void printf(const char *string, char variable);
			;void delay10( char );
			;
			;
			;void main(void)
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
	ADDLW 34
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
	GOTO  m001
	BSF   0x03,RP1
	MOVF  EEDATA,W
	ANDLW 127
	RETURN
m001	BCF   0x03,RP0
	BSF   0x03,RP1
	RLF   EEDATA,W
	RLF   EEDATH,W
	RETURN
	DW    0x3950
	DW    0x39E5
	DW    0x1073
	DW    0x3AE2
	DW    0x3A74
	DW    0x376F
	DW    0x3A20
	DW    0x106F
	DW    0x3970
	DW    0x3769
	DW    0x1074
	DW    0x3AC4
	DW    0x3CF4
	DW    0x3CE3
	DW    0x3663
	DW    0x6E5
	DW    0xA
	DW    0x21C3
	DW    0x2950
	DW    0x2631
	DW    0x1EA0
	DW    0x12A0
	DW    0x1075
	DW    0x20
	DW    0x3AC4
	DW    0x3CF4
	DW    0x3CC3
	DW    0x3663
	DW    0x1065
	DW    0x103D
	DW    0x3AA5
	DW    0x12A0
	DW    0x6A5
	DW    0xA
main
			;  char advalue, duty;
			;  unsigned long tmp1,tmp2;
			;  TRISC.4 = 0; // lightdiode at RC4 is output
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   TRISC,4
			;  PORTC.4 = 0; // no light
	BCF   0x03,RP0
	BCF   PORTC,4
			;  TRISB.6 = 1; // switch SW is input
	BSF   0x03,RP0
	BSF   TRISB,6
			;
			;  initserial();
	CALL  initserial
			;  ADinit();
	CALL  ADinit
			;  PWMinit();
	CALL  PWMinit
			;  
			;  delay10(100); 
	MOVLW 100
	CALL  delay10
			;  // Header text
			;  printf("Press button to print Dutycycle\r\n",0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  string
	MOVLW 0
	CALL  printf
			;
			;  while(1)
			;   {
			;      /* Now read the POT  */
			;      GO=1;         // start AD
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x1F,GO
			;      while(GO);    // wait for done
m003	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC 0x1F,GO
	GOTO  m003
			;      advalue = ADRESH;    // read result 8 bit
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  ADRESH,W
	MOVWF advalue
			;	  /* copy to CCPR1L */
			;	  CCPR1L = advalue;  /* set DutyCycle with POT */
	MOVF  advalue,W
	MOVWF CCPR1L
			;
			;	  
			;      if(!PORTB.6)  // key is pressed
	BTFSC PORTB,6
	GOTO  m002
			;	    {
			;	       /* display DutyCycle */ 
			;           PORTC.4=1;          // LED indicator 
	BSF   PORTC,4
			;		   
			;           /* Calculate DutyCycle in percent */
			;           tmp1 = advalue * 100L;
	MOVF  advalue,W
	MOVWF C2tmp
	CLRF  tmp1
	MOVLW 8
	MOVWF C1cnt
m004	BCF   0x03,Carry
	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   tmp1,1
	RLF   tmp1+1,1
	RLF   C2tmp,1
	BTFSS 0x03,Carry
	GOTO  m005
	MOVLW 100
	ADDWF tmp1,1
	BTFSC 0x03,Carry
	INCF  tmp1+1,1
m005	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C1cnt,1
	GOTO  m004
			;		   tmp2 = tmp1 / 256L;  /* value in PR2-register */
	MOVF  tmp1+1,W
	MOVWF tmp2
	CLRF  tmp2+1
			;           duty = tmp2.low8; 
	MOVF  tmp2,W
	MOVWF duty
			;		   
			;		   printf("CCPR1L = %u  ",advalue);
	MOVLW 34
	MOVWF string
	MOVF  advalue,W
	CALL  printf
			;           printf("DutyCycle = %u %%\r\n", duty);	
	MOVLW 48
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF string
	MOVF  duty,W
	CALL  printf
			;		   
			;           delay10(1);         // Debounce
	MOVLW 1
	CALL  delay10
			;           PORTC.4=0;          // LED off dutycycle value is printed 
	BCF   0x03,RP0
	BCF   0x03,RP1
	BCF   PORTC,4
			;           while (!PORTB.6) ;  // wait for key released
m006	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS PORTB,6
	GOTO  m006
			;           delay10(1);         // Debounce
	MOVLW 1
	CALL  delay10
			;        }
			;   }
	GOTO  m002
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
			;  // AD setup AN6 at RC2 pin 14
			;  TRISC.2 = 1;  // AN6 input
	BSF   0x03,RP0
	BCF   0x03,RP1
	BSF   TRISC,2
			;  ANSEL.6 = 1;  /* RC2 AN6 analog configurated        */  
	BCF   0x03,RP0
	BSF   0x03,RP1
	BSF   ANSEL,6
			;  ADCON1 = 0b0.101.0000;   /* AD conversion clock 'fosc/16' */
	MOVLW 80
	BSF   0x03,RP0
	BCF   0x03,RP1
	MOVWF ADCON1
			;  ADCON0 = 0b0.0.0110.0.1; /* AD-channel 6 pin 14           */ 
	MOVLW 25
	BCF   0x03,RP0
	MOVWF ADCON0
			;}
	RETURN
			;
			;/* **** CCP PWM function ************** */
			;
			;void PWMinit( void )
			;{
PWMinit
			;   TRISC.5 = 0;              /* CCP1 output      */
	BSF   0x03,RP0
	BCF   0x03,RP1
	BCF   TRISC,5
			;   T2CON   = 0b00000.1.00;   /* prescale 1:1     */
	MOVLW 4
	BCF   0x03,RP0
	MOVWF T2CON
			;   CCP1CON = 0b00.00.1100;   /* PWM-mode         */
	MOVLW 12
	MOVWF CCP1CON
			;   PR2     = 255;            /* max value        */
	MOVLW 255
	BSF   0x03,RP0
	MOVWF PR2
			;   CCPR1L  = 128;            /* Duty 50% initial */
	MOVLW 128
	BCF   0x03,RP0
	MOVWF CCPR1L
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
			;   ANSEL.1 = 0; // No AD on RA1
	BCF   ANSEL,1
			;   PORTA.0 = 1; // marking line
	BCF   0x03,RP1
	BSF   PORTA,0
			;   TRISA.0 = 0; // output to PK2 UART-tool
	BSF   0x03,RP0
	BCF   TRISA,0
			;   TRISA.1 = 1; // input from PK2 UART-tool
	BSF   TRISA,1
			;   return;      
	RETURN
			;}
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
m007	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  bitCount,1
	BTFSC 0x03,Zero_
	GOTO  m009
			;   {
			;     // delay one bit 104 usec at 4 MHz
			;     // 5+18*5-1+1+9=104 without optimization 
			;     ti = 18; do ; while( --ti > 0); nop(); 
	MOVLW 18
	MOVWF ti
m008	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ ti,1
	GOTO  m008
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
	GOTO  m007
			;  return;
m009	RETURN
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
	CLRF  i
			;   {
			;     k = string[i];
m010	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i,W
	ADDWF string,W
	CALL  _const1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF k
			;     if( k == '\0') break;   // at end of string
	MOVF  k,1
	BTFSC 0x03,Zero_
	GOTO  m032
			;     if( k == '%')           // insert variable in string
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	XORLW 37
	BTFSS 0x03,Zero_
	GOTO  m030
			;      {
			;        i++;
	INCF  i,1
			;        k = string[i];
	MOVF  i,W
	ADDWF string,W
	CALL  _const1
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF k
			;        switch(k)
	MOVF  k,W
	XORLW 100
	BTFSC 0x03,Zero_
	GOTO  m011
	XORLW 17
	BTFSC 0x03,Zero_
	GOTO  m014
	XORLW 23
	BTFSC 0x03,Zero_
	GOTO  m023
	XORLW 1
	BTFSC 0x03,Zero_
	GOTO  m027
	XORLW 70
	BTFSC 0x03,Zero_
	GOTO  m028
	GOTO  m029
			;         {
			;           case 'd':         // %d  signed 8bit
			;             if( variable.7 ==1) putchar('-');
m011	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS variable,7
	GOTO  m012
	MOVLW 45
	CALL  putchar
			;             else putchar(' ');
	GOTO  m013
m012	MOVLW 32
	CALL  putchar
			;             if( variable > 127) variable = -variable;  // no break!
m013	MOVLW 128
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF variable,W
	BTFSS 0x03,Carry
	GOTO  m014
	COMF  variable,1
	INCF  variable,1
			;           case 'u':         // %u unsigned 8bit
			;             a = variable/100;
m014	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	MOVWF C4tmp
	CLRF  C5rem
	MOVLW 8
	MOVWF C3cnt
m015	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C4tmp,1
	RLF   C5rem,1
	MOVLW 100
	SUBWF C5rem,W
	BTFSS 0x03,Carry
	GOTO  m016
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C5rem,1
	BSF   0x03,Carry
m016	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C3cnt,1
	GOTO  m015
			;             putchar('0'+a); // print 100's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             b = variable%100;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	MOVWF C7tmp
	CLRF  b
	MOVLW 8
	MOVWF C6cnt
m017	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C7tmp,1
	RLF   b,1
	MOVLW 100
	SUBWF b,W
	BTFSS 0x03,Carry
	GOTO  m018
	MOVLW 100
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF b,1
m018	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C6cnt,1
	GOTO  m017
			;             a = b/10;
	MOVF  b,W
	MOVWF C9tmp
	CLRF  C10rem
	MOVLW 8
	MOVWF C8cnt
m019	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C9tmp,1
	RLF   C10rem,1
	MOVLW 10
	SUBWF C10rem,W
	BTFSS 0x03,Carry
	GOTO  m020
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF C10rem,1
	BSF   0x03,Carry
m020	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   a,1
	DECFSZ C8cnt,1
	GOTO  m019
			;             putchar('0'+a); // print 10's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             a = b%10;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  b,W
	MOVWF C12tmp
	CLRF  a
	MOVLW 8
	MOVWF C11cnt
m021	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   C12tmp,1
	RLF   a,1
	MOVLW 10
	SUBWF a,W
	BTFSS 0x03,Carry
	GOTO  m022
	MOVLW 10
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF a,1
m022	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ C11cnt,1
	GOTO  m021
			;             putchar('0'+a); // print 1's
	MOVLW 48
	ADDWF a,W
	CALL  putchar
			;             break;
	GOTO  m031
			;           case 'b':         // %b BINARY 8bit
			;             for( m = 0 ; m < 8 ; m++ )
m023	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  m
m024	MOVLW 8
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF m,W
	BTFSC 0x03,Carry
	GOTO  m031
			;              {
			;                if (variable.7 == 1) putchar('1');
	BTFSS variable,7
	GOTO  m025
	MOVLW 49
	CALL  putchar
			;                else putchar('0');
	GOTO  m026
m025	MOVLW 48
	CALL  putchar
			;                variable = rl(variable);
m026	BCF   0x03,RP0
	BCF   0x03,RP1
	RLF   variable,1
			;               }
	INCF  m,1
	GOTO  m024
			;              break;
			;           case 'c':         // %c  'char'
			;             putchar(variable);
m027	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  variable,W
	CALL  putchar
			;             break;
	GOTO  m031
			;           case '%':
			;             putchar('%');
m028	MOVLW 37
	CALL  putchar
			;             break;
	GOTO  m031
			;           default:          // not implemented
			;             putchar('!');
m029	MOVLW 33
	CALL  putchar
			;         }
			;      }
			;      else putchar(k);
	GOTO  m031
m030	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  k,W
	CALL  putchar
			;   }
m031	BCF   0x03,RP0
	BCF   0x03,RP1
	INCF  i,1
	GOTO  m010
			;}
m032	RETURN
			;
			;
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
m033	MOVLW 39
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF TMR0,W
	MOVWF i_2
			;        while ( i != TMR0) ;
m034	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  i_2,W
	XORWF TMR0,W
	BTFSS 0x03,Zero_
	GOTO  m034
			;    } while ( --n > 0);
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ n,1
	GOTO  m033
			;}
	RETURN

	END


; *** KEY INFO ***

; 0x00B2 P0   10 word(s)  0 % : initserial
; 0x0095 P0   14 word(s)  0 % : ADinit
; 0x00A3 P0   15 word(s)  0 % : PWMinit
; 0x00BC P0   27 word(s)  1 % : putchar
; 0x00D7 P0  207 word(s) 10 % : printf
; 0x01A6 P0   22 word(s)  1 % : delay10
; 0x0044 P0   81 word(s)  3 % : main
; 0x0001 P0   67 word(s)  3 % : _const1

; RAM usage: 16 bytes (16 local), 240 bytes free
; Maximum call level: 2
;  Codepage 0 has  444 word(s) :  21 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 444 code words (10 %)
