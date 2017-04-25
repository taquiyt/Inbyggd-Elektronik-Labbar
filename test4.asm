
; CC5X Version 3.4H, Copyright (c) B Knudsen Data
; C compiler for the PICmicro family
; ************  23. Mar 2017  11:01  *************

	processor  16F690
	radix  DEC

	__config 0xD4

Carry       EQU   0
Zero_       EQU   2
RP0         EQU   5
RP1         EQU   6
FpFlags     EQU   0x35
FpOverflow  EQU   1
FpUnderFlow EQU   2
FpDomainError EQU   5
FpRounding  EQU   6
arg1f24     EQU   0x26
arg2f24     EQU   0x29
aarg        EQU   0x31
sign        EQU   0x33
counter     EQU   0x34
xtra        EQU   0x31
temp        EQU   0x32
expo        EQU   0x33
sign_3      EQU   0x34
cexp        EQU   0x2C
savedFLAGS  EQU   0x2D
d_5         EQU   0x2E
a           EQU   0x20
b           EQU   0x23

	GOTO main

  ; FILE math24f.h
			;// *************************************************
			;// 24 bit basic floating point math operations
			;// Copyright (c) B Knudsen Data, Norway, 2000 - 2009
			;// *************************************************
			;
			;#pragma library 1
			;/* PROTOTYPES for page definition in application header file:
			;float24 operator* _fmul24( float24 arg1f24, float24 arg2f24);
			;float24 operator/ _fdiv24( float24 arg1f24, float24 arg2f24);
			;float24 operator+ _fadd24( float24 arg1f24, float24 arg2f24);
			;float24 operator- _fsub24( float24 arg1f24, float24 arg2f24);
			;float24 operator= _int24ToFloat24( int24 arg1f24);
			;float24 operator= _int32ToFloat24( int32 arg32);
			;int24 operator= _float24ToInt24( float24 arg1f24);
			;bit operator< _f24_LT_f24( float24 arg1f24, float24 arg2f24);
			;bit operator>= _f24_GE_f24( float24 arg1f24, float24 arg2f24);
			;bit operator> _f24_GT_f24( float24 arg1f24, float24 arg2f24);
			;bit operator<= _f24_LE_f24( float24 arg1f24, float24 arg2f24);
			;*/
			;
			;// DEFINABLE SYMBOLS (in the application code):
			;//#define FP_OPTIM_SPEED  // optimize for SPEED: default
			;//#define FP_OPTIM_SIZE   // optimize for SIZE
			;//#define DISABLE_ROUNDING   // disable rounding and save code space
			;
			;#define float24ToIEEE754(a) { a.mid8=rl(a.mid8); a.high8=rr(a.high8);\
			;                              a.mid8=rr(a.mid8); }
			;#define IEEE754ToFloat24(a) { a.mid8=rl(a.mid8); a.high8=rl(a.high8);\
			;                              a.mid8=rr(a.mid8); }
			;
			;
			;/*  24 bit floating point format:
			;
			;  address  ID
			;    X      a.low8  : LSB, bit 0-7 of mantissa
			;    X+1    a.mid8  : bit 8-14 of mantissa, bit 15 is the sign bit
			;    X+2    a.high8 : MSB, bit 0-7 of exponent, with bias 0x7F
			;
			;    bit 15 of mantissa is a hidden bit, always equal to 1
			;    zero (0.0) :  a.high8 = 0 (mantissa & sign ignored)
			;
			;   MSB    LSB
			;    7F 00 00  : 1.0   =  1.0  * 2**(0x7F-0x7F) = 1.0 * 1
			;    7F 80 00  : -1.0  = -1.0  * 2**(0x7F-0x7F) = -1.0 * 1
			;    80 00 00  : 2.0   =  1.0  * 2**(0x80-0x7F) = 1.0 * 2
			;    80 40 00  : 3.0   =  1.5  * 2**(0x80-0x7F) = 1.5 * 2
			;    7E 60 00  : 0.875 =  1.75 * 2**(0x7E-0x7F) = 1.75 * 0.5
			;    7F 60 00  : 1.75  =  1.75 * 2**(0x7E-0x7F) = 1.75 * 1
			;    7F 7F FF  : 1.999969482
			;    00 7C 5A  : 0.0 (mantissa & sign ignored)
			;    01 00 00  : 1.17549435e-38 =  1.0 * 2**(0x01-0x7F)
			;    FE 7F FF  : 3.40277175e+38 =  1.999969482 * 2**(0xFE-0x7F)
			;    FF 00 00  : +INF : positive infinity
			;    FF 80 00  : -INF : negative infinity
			;*/                 
			;
			;#define  FpBIAS  0x7F
			;
			;#ifndef FpFlags_defined
			; #define FpFlags_defined
			;
			; char FpFlags;
			; //bit IOV         @ FpFlags.0; // integer overflow flag: NOT USED
			; bit FpOverflow    @ FpFlags.1; // floating point overflow flag
			; bit FpUnderFlow   @ FpFlags.2; // floating point underflow flag
			; bit FpDiv0        @ FpFlags.3; // floating point divide by zero flag
			; //bit FpNAN       @ FpFlags.4; // not-a-number exception flag: NOT USED
			; bit FpDomainError @ FpFlags.5; // domain error exception flag
			; bit FpRounding    @ FpFlags.6; // floating point rounding flag, 0=truncation
			;                                // 1 = unbiased rounding to nearest LSB
			; //bit FpSaturate  @ FpFlags.7; // floating point saturate flag: NOT USED
			;
			; #pragma floatOverflow FpOverflow
			; #pragma floatUnderflow FpUnderFlow
			;
			; #define InitFpFlags()  FpFlags = 0x40 /* enable rounding as default */
			;#endif
			;
			;#ifdef DISABLE_ROUNDING
			; #pragma floatRounding 0
			;#endif
			;
			;
			;#if __CoreSet__ < 1410
			; #define genAdd(r,a) W=a; btsc(Carry); W=incsz(a); r+=W
			; #define genSub(r,a) W=a; btss(Carry); W=incsz(a); r-=W
			; #define genAddW(r,a) W=a; btsc(Carry); W=incsz(a); W=r+W
			; #define genSubW(r,a) W=a; btss(Carry); W=incsz(a); W=r-W
			;#else
			; #define genAdd(r,a) W=a; r=addWFC(r)
			; #define genSub(r,a) W=a; r=subWFB(r)
			; #define genAddW(r,a) W=a; W=addWFC(r)
			; #define genSubW(r,a) W=a; W=subWFB(r)
			;#endif
			;
			;
			;
			;float24 operator* _fmul24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_fmul24
			;    uns16 aarg;
			;    W = arg1f24.mid8;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24+1,W
			;    aarg.high8 = W;
	MOVWF aarg+1
			;
			;    // save sign
			;    char sign = arg2f24.mid8 ^ W;  // before first overflow test
	XORWF arg2f24+1,W
	MOVWF sign
			;
			;    W = arg1f24.high8;
	MOVF  arg1f24+2,W
			;    if (!Zero_)
	BTFSS 0x03,Zero_
			;        W = arg2f24.high8;
	MOVF  arg2f24+2,W
			;    if (Zero_)
	BTFSC 0x03,Zero_
			;        goto RES0;
	GOTO  m007
			;
			;    arg1f24.high8 += W /* arg2f24.high8 */;
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF arg1f24+2,1
			;    W = FpBIAS-1;
	MOVLW 126
			;    if (Carry)  {
	BTFSS 0x03,Carry
	GOTO  m001
			;        arg1f24.high8 -= W;
	SUBWF arg1f24+2,1
			;        if (Carry)
	BTFSS 0x03,Carry
	GOTO  m002
			;            goto OVERFLOW;
	GOTO  m008
			;    }
			;    else  {
			;        arg1f24.high8 -= W;
m001	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF arg1f24+2,1
			;        if (!Carry)
	BTFSS 0x03,Carry
			;            goto UNDERFLOW;
	GOTO  m006
			;    }
			;    aarg.low8 = arg1f24.low8;
m002	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24,W
	MOVWF aarg
			;
			;    aarg.15 = 1;
	BSF   aarg+1,7
			;    arg2f24.15 = 1;
	BSF   arg2f24+1,7
			;
			;    arg1f24.low16 = 0;
	CLRF  arg1f24
	CLRF  arg1f24+1
			;
			;    char counter = sizeof(aarg)*8;
	MOVLW 16
	MOVWF counter
			;
			;    do  {
			;        aarg = rr( aarg);
m003	BCF   0x03,RP0
	BCF   0x03,RP1
	RRF   aarg+1,1
	RRF   aarg,1
			;        if (Carry)  {
	BTFSS 0x03,Carry
	GOTO  m004
			;            arg1f24.low8 += arg2f24.low8;
	MOVF  arg2f24,W
	ADDWF arg1f24,1
			;            genAdd( arg1f24.mid8, arg2f24.mid8);
	MOVF  arg2f24+1,W
	BTFSC 0x03,Carry
	INCFSZ arg2f24+1,W
	ADDWF arg1f24+1,1
			;        }
			;        arg1f24.low16 = rr( arg1f24.low16);
m004	BCF   0x03,RP0
	BCF   0x03,RP1
	RRF   arg1f24+1,1
	RRF   arg1f24,1
			;    } while (-- counter > 0);
	DECFSZ counter,1
	GOTO  m003
			;
			;    if (!arg1f24.15)  {
	BTFSC arg1f24+1,7
	GOTO  m005
			;        // catch Carry bit that was shifted out previously
			;        arg1f24.low16 = rl( arg1f24.low16);
	RLF   arg1f24,1
	RLF   arg1f24+1,1
			;        if (arg1f24.high8 == 0)
	MOVF  arg1f24+2,1
	BTFSC 0x03,Zero_
			;            goto UNDERFLOW;
	GOTO  m006
			;        arg1f24.high8 -= 1;
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECF  arg1f24+2,1
			;        W = rl( aarg.high8);
	RLF   aarg+1,W
			;        // restore bit behind LSB in Carry
			;    }
			;
			;   #ifndef DISABLE_ROUNDING
			;    if (FpRounding  &&  Carry)  {
m005	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS 0x35,FpRounding
	GOTO  m010
	BTFSS 0x03,Carry
	GOTO  m010
			;        arg1f24.low8 += 1;
	INCFSZ arg1f24,1
			;        if (!arg1f24.low8)  {
	GOTO  m010
			;            arg1f24.mid8 += 1;
	INCFSZ arg1f24+1,1
			;            if (!arg1f24.mid8)  {
	GOTO  m010
			;                // Carry = 1; //OK
			;                arg1f24.low16 = rr( arg1f24.low16);
	RRF   arg1f24+1,1
	RRF   arg1f24,1
			;                arg1f24.high8 += 1;
	INCFSZ arg1f24+2,1
			;                if (Zero_)
	GOTO  m010
			;                    goto OVERFLOW;
	GOTO  m008
			;            }
			;        }
			;    }
			;   #endif
			;    goto SET_SIGN;
			;
			;  UNDERFLOW:
			;    FpUnderFlow = 1;
m006	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x35,FpUnderFlow
			;  RES0:
			;    arg1f24.high8 = 0;
m007	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  arg1f24+2
			;    goto MANTISSA;
	GOTO  m009
			;
			;  OVERFLOW:
			;    FpOverflow = 1;
m008	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x35,FpOverflow
			;    arg1f24.high8 = 0xFF;
	MOVLW 255
	MOVWF arg1f24+2
			;  MANTISSA:
			;    arg1f24.low16 = 0x8000;
m009	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  arg1f24
	MOVLW 128
	MOVWF arg1f24+1
			;
			;  SET_SIGN:
			;    if (!(sign & 0x80))
m010	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS sign,7
			;        arg1f24.15 = 0;
	BCF   arg1f24+1,7
			;    return arg1f24;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24,W
	RETURN
			;}
			;
			;
			;
			;float24 operator/ _fdiv24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_fdiv24
			;    uns16 aarg;
			;    W = arg1f24.mid8;
			;    aarg.high8 = W;
			;
			;    // save sign
			;    char sign = arg2f24.mid8 ^ W;  // before first overflow test
			;
			;    W = arg2f24.high8;
			;    if (Zero_)
			;        goto Div0;
			;    if (!arg1f24.high8)
			;        goto RES0;
			;
			;    arg1f24.high8 -= arg2f24.high8;
			;    W = FpBIAS;
			;    if (!Carry)  {
			;        arg1f24.high8 += W;
			;        if (!Carry)
			;            goto UNDERFLOW;
			;    }
			;    else  {
			;        arg1f24.high8 += W;
			;        if (Carry)
			;            goto OVERFLOW;
			;    }
			;
			;    aarg.low8 = arg1f24.low8;
			;    aarg.15 = 1;
			;    arg2f24.15 = 1;
			;
			;    // division: shift & add
			;    char counter = 16;
			;    arg1f24.low16 = 0;  // speedup
			;
			;#if defined FP_OPTIM_SPEED || !defined FP_OPTIM_SIZE  // SPEED
			;
			;    goto START_ML;
			;
			;  TEST_ZERO_L:
			;    W = aarg.low8 - arg2f24.low8;
			;    if (!Carry)
			;        goto SHIFT_IN_CARRY;
			;    aarg.low8 = W;
			;    aarg.high8 = 0;
			;    goto SET_AND_SHIFT_IN_CARRY;
			;
			;// MAIN LOOP
			;    do  {
			;      LOOP_ML:
			;        if (!Carry)  {
			;           START_ML:
			;            W = aarg.high8 - arg2f24.mid8;
			;            if (Zero_)
			;                goto TEST_ZERO_L;
			;            if (!Carry)
			;                goto SHIFT_IN_CARRY;
			;        }
			;        aarg.low8 -= arg2f24.low8;
			;        genSub( aarg.high8, arg2f24.mid8);
			;      SET_AND_SHIFT_IN_CARRY:
			;        Carry = 1;
			;      SHIFT_IN_CARRY:
			;        arg1f24.low16 = rl( arg1f24.low16);
			;        // Carry = 0;  // ok, speedup
			;        aarg = rl( aarg);
			;    } while (-- counter > 0);
			;
			;
			;
			;#else  // SIZE
			;
			;    goto START_ML;
			;
			;// MAIN LOOP
			;    do  {
			;      LOOP_ML:
			;        if (Carry)
			;            goto SUBTRACT;
			;      START_ML:
			;        W = aarg.low8 - arg2f24.low8;
			;        genSubW( aarg.high8, arg2f24.mid8);
			;        if (!Carry)
			;            goto SKIP_SUB;
			;       SUBTRACT:
			;        aarg.low8 -= arg2f24.low8;
			;        genSub( aarg.high8, arg2f24.mid8);
			;        Carry = 1;
			;       SKIP_SUB:
			;        arg1f24.low16 = rl( arg1f24.low16);
			;        // Carry = 0;  // ok
			;        aarg = rl( aarg);
			;    } while (-- counter > 0);
			;
			;#endif
			;
			;    if (!arg1f24.15)  {
			;        if (!arg1f24.high8)
			;            goto UNDERFLOW;
			;        arg1f24.high8 --;
			;        counter ++;
			;        goto LOOP_ML;
			;    }
			;
			;   #ifndef DISABLE_ROUNDING
			;    if (FpRounding)  {
			;        if (Carry)
			;            goto ADD_1;
			;        aarg.low8 -= arg2f24.low8;
			;        genSub( aarg.high8, arg2f24.mid8);
			;        if (Carry)  {
			;          ADD_1:
			;            arg1f24.low8 += 1;
			;            if (!arg1f24.low8)  {
			;                arg1f24.mid8 ++;
			;                if (!arg1f24.mid8)  {
			;                    arg1f24.low16 = rr( arg1f24.low16);
			;                    arg1f24.high8 ++;
			;                    if (!arg1f24.high8)
			;                        goto OVERFLOW;
			;                }
			;            }
			;        }
			;    }
			;   #endif
			;    goto SET_SIGN;
			;
			;  Div0:
			;    FpDiv0 = 1;
			;    goto SATURATE;
			;
			;  UNDERFLOW:
			;    FpUnderFlow = 1;
			;  RES0:
			;    arg1f24.high8 = 0;
			;    goto MANTISSA;
			;
			;  OVERFLOW:
			;    FpOverflow = 1;
			;  SATURATE:
			;    arg1f24.high8 = 0xFF;
			;  MANTISSA:
			;    arg1f24.low16 = 0x8000;
			;
			;  SET_SIGN:
			;    if (!(sign & 0x80))
			;        arg1f24.15 = 0;
			;    return arg1f24;
			;}
			;
			;
			;float24 operator+ _fadd24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_fadd24
			;    char xtra, temp;
			;    char expo = arg1f24.high8 - arg2f24.high8;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg2f24+2,W
	SUBWF arg1f24+2,W
	MOVWF expo
			;    if (!Carry)  {
	BTFSC 0x03,Carry
	GOTO  m011
			;        expo = -expo;
	COMF  expo,1
	INCF  expo,1
			;        temp = arg1f24.high8;
	MOVF  arg1f24+2,W
	MOVWF temp
			;        arg1f24.high8 = arg2f24.high8;
	MOVF  arg2f24+2,W
	MOVWF arg1f24+2
			;        arg2f24.high8 = temp;
	MOVF  temp,W
	MOVWF arg2f24+2
			;        temp = arg1f24.mid8;
	MOVF  arg1f24+1,W
	MOVWF temp
			;        arg1f24.mid8 = arg2f24.mid8;
	MOVF  arg2f24+1,W
	MOVWF arg1f24+1
			;        arg2f24.mid8 = temp;
	MOVF  temp,W
	MOVWF arg2f24+1
			;        temp = arg1f24.low8;
	MOVF  arg1f24,W
	MOVWF temp
			;        arg1f24.low8 = arg2f24.low8;
	MOVF  arg2f24,W
	MOVWF arg1f24
			;        arg2f24.low8 = temp;
	MOVF  temp,W
	MOVWF arg2f24
			;    }
			;    if (expo > sizeof(arg1f24)*8-7)
m011	MOVLW 18
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF expo,W
	BTFSC 0x03,Carry
			;        goto _RETURN_MF;
	GOTO  m029
			;    if (!arg2f24.high8)
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg2f24+2,1
	BTFSC 0x03,Zero_
			;        goto _RETURN_MF;   // result is arg1f24
	GOTO  m029
			;
			;    xtra = 0;
	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  xtra
			;
			;    temp = arg1f24.mid8;
	MOVF  arg1f24+1,W
	MOVWF temp
			;    char sign = arg2f24.mid8 ^ arg1f24.mid8;
	MOVF  arg1f24+1,W
	XORWF arg2f24+1,W
	MOVWF sign_3
			;    arg1f24.15 = 1;
	BSF   arg1f24+1,7
			;    arg2f24.15 = 1;
	BSF   arg2f24+1,7
			;
			;    while (1)  {
			;        W = 8;
m012	MOVLW 8
			;        expo -= W;
	BCF   0x03,RP0
	BCF   0x03,RP1
	SUBWF expo,1
			;        if (!Carry)
	BTFSS 0x03,Carry
			;            break;
	GOTO  m013
			;        xtra = arg2f24.low8;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg2f24,W
	MOVWF xtra
			;        arg2f24.low8 = arg2f24.mid8;
	MOVF  arg2f24+1,W
	MOVWF arg2f24
			;        arg2f24.mid8 = 0;
	CLRF  arg2f24+1
			;    }
	GOTO  m012
			;    expo += W;
m013	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF expo,1
			;    if (expo)  {
	BTFSC 0x03,Zero_
	GOTO  m015
			;        do  {
			;            Carry = 0;
m014	BCF   0x03,Carry
			;            arg2f24.low16 = rr( arg2f24.low16);
	BCF   0x03,RP0
	BCF   0x03,RP1
	RRF   arg2f24+1,1
	RRF   arg2f24,1
			;            xtra = rr( xtra);
	RRF   xtra,1
			;        } while (--expo > 0);
	DECFSZ expo,1
	GOTO  m014
			;    }
			;
			;
			;    if (sign & 0x80)  {
m015	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS sign_3,7
	GOTO  m021
			;        // SUBTRACT
			;        arg1f24.low8 -= arg2f24.low8;
	MOVF  arg2f24,W
	SUBWF arg1f24,1
			;        genSub( arg1f24.mid8, arg2f24.mid8);
	MOVF  arg2f24+1,W
	BTFSS 0x03,Carry
	INCFSZ arg2f24+1,W
	SUBWF arg1f24+1,1
			;        if (!Carry)  {  // arg2f24 > arg1f24
	BTFSC 0x03,Carry
	GOTO  m016
			;            arg1f24.low16 = -arg1f24.low16;
	COMF  arg1f24+1,1
	COMF  arg1f24,1
	INCF  arg1f24,1
	BTFSC 0x03,Zero_
	INCF  arg1f24+1,1
			;            // xtra == 0 because arg1f24.exp == arg2f24.exp
			;            temp ^= 0x80;  // invert sign
	MOVLW 128
	XORWF temp,1
			;        }
			;        xtra = -xtra;
m016	BCF   0x03,RP0
	BCF   0x03,RP1
	COMF  xtra,1
	INCF  xtra,1
			;        if (xtra)
	BTFSC 0x03,Zero_
	GOTO  m017
			;            arg1f24.low16 --;
	DECF  arg1f24,1
	INCF  arg1f24,W
	BTFSC 0x03,Zero_
	DECF  arg1f24+1,1
			;        // adjust result left
			;       #define counter expo
			;        counter = 3;
m017	MOVLW 3
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF expo
			;        while (!arg1f24.mid8)  {
m018	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24+1,1
	BTFSS 0x03,Zero_
	GOTO  m019
			;            arg1f24.mid8 = arg1f24.low8;
	MOVF  arg1f24,W
	MOVWF arg1f24+1
			;            arg1f24.low8 = xtra;
	MOVF  xtra,W
	MOVWF arg1f24
			;            xtra = 0;
	CLRF  xtra
			;            arg1f24.high8 -= 8;
	MOVLW 8
	SUBWF arg1f24+2,1
			;            if (!Carry)
	BTFSS 0x03,Carry
			;                goto RES0;
	GOTO  m025
			;            if (--counter == 0)  // max 2 iterations
	BCF   0x03,RP0
	BCF   0x03,RP1
	DECFSZ expo,1
	GOTO  m018
			;                goto RES0;
	GOTO  m025
			;        }
			;       #undef counter
			;        while (!arg1f24.15)  {
m019	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC arg1f24+1,7
	GOTO  m020
			;            Carry = 0;
	BCF   0x03,Carry
			;            xtra = rl( xtra);
	RLF   xtra,1
			;            arg1f24.low16 = rl( arg1f24.low16);
	RLF   arg1f24,1
	RLF   arg1f24+1,1
			;            arg1f24.high8 --;
	DECFSZ arg1f24+2,1
			;            if (!arg1f24.high8)
	GOTO  m019
			;                goto RES0;   // UNDERFLOW?
	GOTO  m025
			;        }
			;       #ifndef DISABLE_ROUNDING
			;        if (FpRounding  &&  (xtra & 0x80))  {
m020	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS 0x35,FpRounding
	GOTO  m028
	BTFSS xtra,7
	GOTO  m028
			;            xtra = 0; // disable recursion
	CLRF  xtra
			;            goto INCREMENT;
	GOTO  m024
			;        }
			;       #endif
			;    }
			;    else  {
			;        // ADD arg1f24 and arg2f24
			;        arg1f24.low8 += arg2f24.low8;
m021	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg2f24,W
	ADDWF arg1f24,1
			;        genAdd( arg1f24.mid8, arg2f24.mid8);
	MOVF  arg2f24+1,W
	BTFSC 0x03,Carry
	INCFSZ arg2f24+1,W
	ADDWF arg1f24+1,1
			;        if (Carry)  {
	BTFSS 0x03,Carry
	GOTO  m023
			;          ADJUST_RIGHT:
			;            arg1f24.low16 = rr( arg1f24.low16);
m022	BCF   0x03,RP0
	BCF   0x03,RP1
	RRF   arg1f24+1,1
	RRF   arg1f24,1
			;            xtra = rr( xtra);
	RRF   xtra,1
			;            arg1f24.high8 += 1;  // exp
	INCF  arg1f24+2,1
			;            if (!arg1f24.high8)
	BTFSC 0x03,Zero_
			;                goto OVERFLOW;
	GOTO  m026
			;        }
			;       #ifndef DISABLE_ROUNDING
			;        if (FpRounding  &&  (xtra & 0x80))  {
m023	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS 0x35,FpRounding
	GOTO  m028
	BTFSS xtra,7
	GOTO  m028
			;          INCREMENT:
			;            arg1f24.low8 += 1;
m024	BCF   0x03,RP0
	BCF   0x03,RP1
	INCFSZ arg1f24,1
			;            if (!arg1f24.low8)  {
	GOTO  m028
			;                arg1f24.mid8 += 1;
	INCFSZ arg1f24+1,1
			;                if (!arg1f24.mid8)  {
	GOTO  m028
			;                    Carry = 1; // prepare for shift
	BSF   0x03,Carry
			;                    arg1f24.0 = 0;  // disable recursion
	BCF   arg1f24,0
			;                    goto ADJUST_RIGHT;
	GOTO  m022
			;                }
			;            }
			;        }
			;       #endif
			;    }
			;    goto SET_SIGN;
			;
			;//  UNDERFLOW:
			;//    FpUnderFlow = 1;
			;  RES0:
			;    arg1f24.high8 = 0;
m025	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  arg1f24+2
			;    goto MANTISSA;
	GOTO  m027
			;
			;  OVERFLOW:
			;    FpOverflow = 1;
m026	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x35,FpOverflow
			;    arg1f24.high8 = 0xFF;
	MOVLW 255
	MOVWF arg1f24+2
			;  MANTISSA:
			;    arg1f24.low16 = 0x8000;
m027	BCF   0x03,RP0
	BCF   0x03,RP1
	CLRF  arg1f24
	MOVLW 128
	MOVWF arg1f24+1
			;
			;  SET_SIGN:
			;    if (!(temp & 0x80))
m028	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSS temp,7
			;        arg1f24.15 = 0;
	BCF   arg1f24+1,7
			;
			;  _RETURN_MF:
			;    return arg1f24;
m029	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24,W
	RETURN
			;}
			;
			;
			;// SUBTRACTION
			;
			;float24 operator- _fsub24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_fsub24
			;    arg2f24.mid8 ^= 0x80;
			;    arg1f24 += arg2f24;
			;    return arg1f24;
			;}
			;
			;
			;float24 operator=( int8 arg) @
			;float24 operator=( uns8 arg) @
			;float24 operator=( int16 arg) @
			;float24 operator=( uns16 arg) @
			;float24 operator= _int24ToFloat24( sharedM int24 arg1f24)
			;{
_int24ToFloat24
			;    sharedM float24 arg2f24;   // unused, but required
			;    char expo = FpBIAS + 16 - 1;
			;    char xtra = 0;
			;    char sign = 0;
			;    if (arg1f24 < 0)  {
			;        arg1f24 = -arg1f24;
			;        sign |= 0x80;
			;    }
			;    if (arg1f24.high8)  {
			;        expo += 8;
			;        xtra = arg1f24.low8;
			;        arg1f24.low8 = arg1f24.mid8;
			;        arg1f24.mid8 = arg1f24.high8;
			;    }
			;    else if (!arg1f24.mid8)  {
			;        expo -= 8;
			;        W = arg1f24.low8;
			;        if (!W)
			;            goto _RETURN_MF;
			;        arg1f24.mid8 = W;
			;        arg1f24.low8 = 0;
			;    }
			;
			;    // arg1f24.mid8 != 0
			;    goto TEST_ARG1_B15;
			;    do  {
			;        xtra = rl( xtra);
			;        arg1f24.low16 = rl( arg1f24.low16);
			;        expo --;
			;      TEST_ARG1_B15:
			;    } while (!arg1f24.15);
			;
			;   #ifndef DISABLE_ROUNDING
			;    if (FpRounding && (xtra & 0x80))  {
			;        arg1f24.low8 += 1;
			;        if (!arg1f24.low8)  {
			;            arg1f24.mid8 += 1;
			;            if (!arg1f24.mid8)  {
			;                Carry = 1;
			;                arg1f24.low16 = rr( arg1f24.low16);
			;                expo ++;
			;            }
			;        }
			;    }
			;   #endif
			;
			;    arg1f24.high8 = expo;
			;    if (!(sign & 0x80))
			;        arg1f24.15 = 0;
			;
			;  _RETURN_MF:
			;    float24 rval @ arg1f24;
			;    rval.low24 = arg1f24.low24;
			;    return rval;
			;}
			;
			;
			;float24 operator=( uns24 arg) @
			;float24 operator= _int32ToFloat24( int32 arg32)
			;{
_int32ToFloat24
			;    char expo = FpBIAS + 16 - 1;
			;    char xtra @ arg32.high8;
			;    char sign = 0;
			;    if (arg32 < 0)  {
			;        arg32 = -arg32;
			;        sign |= 0x80;
			;    }
			;    if (arg32.high8)  {
			;        expo += 8;
			;        arg32.low8 = arg32.midL8;
			;        arg32.midL8 = arg32.midH8;
			;        arg32.midH8 = arg32.high8;
			;        arg32.high8 = 0;
			;    }
			;    if (arg32.midH8)  {
			;        expo += 8;
			;        xtra = arg32.low8;
			;        arg32.low8 = arg32.midL8;
			;        arg32.midL8 = arg32.midH8;
			;    }
			;    else if (!arg32.midL8)  {
			;        expo -= 8;
			;        W = arg32.low8;
			;        if (!W)
			;            goto _RETURN_MF;
			;        arg32.midL8 = W;
			;        arg32.low8 = 0;
			;    }
			;
			;    // arg32.midL8 != 0
			;    goto TEST_ARG_B15;
			;    do  {
			;        xtra = rl( xtra);
			;        arg32.low16 = rl( arg32.low16);
			;        expo --;
			;      TEST_ARG_B15:
			;    } while (!arg32.15);
			;
			;   #ifndef DISABLE_ROUNDING
			;    if (FpRounding && (xtra & 0x80))  {
			;        arg32.low8 += 1;
			;        if (!arg32.low8)  {
			;            arg32.midL8 += 1;
			;            if (!arg32.midL8)  {
			;                Carry = 1;
			;                arg32.low16 = rr( arg32.low16);
			;                expo ++;
			;            }
			;        }
			;    }
			;   #endif
			;
			;    arg32.midH8 = expo;
			;    if (!(sign & 0x80))
			;        arg32.15 = 0;
			;
			;  _RETURN_MF:
			;    float24 rval @ arg32;
			;    rval.low24 = arg32.low24;
			;    return rval;
			;}
			;
			;
			;uns8 operator=( sharedM float24 arg1f24) @
			;int8 operator=( sharedM float24 arg1f24) @
			;uns16 operator=( sharedM float24 arg1f24) @
			;int16 operator=( sharedM float24 arg1f24) @
			;int24 operator= _float24ToInt24( sharedM float24 arg1f24)
			;{
_float24ToInt24
			;    sharedM float24 arg2f24;   // unused, but required
			;    char sign = arg1f24.mid8;
			;    char expo = arg1f24.high8 - (FpBIAS-1);
			;    if (!Carry)
			;        goto RES0;
			;    arg1f24.15 = 1;
			;
			;    arg1f24.high8 = 0;
			;   #ifndef DISABLE_ROUNDING
			;    char xtra = 0;
			;   #endif
			;
			;    // (a): expo = 0..8 : shift 1 byte to the right
			;    // (b): expo = 9..16: shift 0 byte
			;    // (c): expo = 17..24: shift 1 byte to the left
			;   #if __CoreSet__ / 100 == 12
			;    expo -= 17;
			;    expo = 0xFF - expo;  // COMF (Carry unchanged)
			;    if (Carry)  {  // (c)
			;   #else
			;    expo = 16 - expo;
			;    if (!Carry)  {  // (c)
			;   #endif
			;        expo += 8;
			;        if (!Carry)
			;            goto OVERFLOW;
			;        arg1f24.high8 = arg1f24.mid8;
			;        arg1f24.mid8 = arg1f24.low8;
			;        arg1f24.low8 = 0;
			;    }
			;    else  {  // (a) (b)
			;        // expo = 0 .. 16
			;        W = expo - 8;
			;        if (Carry)  {  // (a)
			;            expo = W;
			;           #ifndef DISABLE_ROUNDING
			;            xtra = arg1f24.low8;
			;           #endif
			;            arg1f24.low8 = arg1f24.mid8;
			;            arg1f24.mid8 = 0;
			;        }
			;    }
			;    if (expo)  {
			;        do  {
			;            Carry = 0;
			;            arg1f24.high8 = rr( arg1f24.high8);
			;            arg1f24.low16 = rr( arg1f24.low16);
			;           #ifndef DISABLE_ROUNDING
			;            xtra = rr( xtra);
			;           #endif
			;        } while (--expo);
			;    }
			;    if (arg1f24.23)  {
			;       OVERFLOW:
			;        FpOverflow = 1;
			;        W = 0xFF;
			;        goto ASSIGNW;
			;       RES0:
			;        W = 0;
			;       ASSIGNW:
			;        arg1f24.low8 = W;
			;        arg1f24.mid8 = W;
			;        arg1f24.high8 = W;
			;        arg1f24.23 = 0;
			;    }
			;    else  {
			;       #ifndef DISABLE_ROUNDING
			;        if (FpRounding && (xtra & 0x80))  {
			;            arg1f24.low8 += 1;
			;            if (!arg1f24.low8)
			;                arg1f24.mid8 += 1;
			;        }
			;       #endif
			;        if (sign & 0x80)
			;            arg1f24.low24 = -arg1f24.low24;
			;    }
			;    int24 rval @ arg1f24;
			;    rval = arg1f24.low24;
			;    return rval;
			;}
			;
			;
			;bit operator< _f24_LT_f24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_f24_LT_f24
			;    Carry = 0;
			;    if (!(arg1f24.high8 | arg2f24.high8))
			;        return Carry;
			;    if (!arg1f24.15)  {
			;        if (arg2f24.15)
			;            return Carry;
			;        W = arg1f24.low8 - arg2f24.low8;
			;        genSubW( arg1f24.mid8, arg2f24.mid8);
			;        genSubW( arg1f24.high8, arg2f24.high8);
			;        goto _RETURN_MF;
			;    }
			;    if (!arg2f24.15)
			;        goto _RETURN_MF;
			;    W = arg2f24.low8 - arg1f24.low8;
			;    genSubW( arg2f24.mid8, arg1f24.mid8);
			;    genSubW( arg2f24.high8, arg1f24.high8);
			;  _RETURN_MF:
			;    if (Carry)
			;        return 0;
			;    return 1;
			;}
			;
			;
			;bit operator>= _f24_GE_f24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_f24_GE_f24
			;    Carry = 1;
			;    if (!(arg1f24.high8 | arg2f24.high8))
			;        return Carry;
			;    if (!arg1f24.15)  {
			;        if (arg2f24.15)
			;            return Carry;
			;        W = arg1f24.low8 - arg2f24.low8;
			;        genSubW( arg1f24.mid8, arg2f24.mid8);
			;        genSubW( arg1f24.high8, arg2f24.high8);
			;        return Carry;
			;    }
			;    Carry = 0;
			;    if (!arg2f24.15)
			;        return Carry;
			;    W = arg2f24.low8 - arg1f24.low8;
			;    genSubW( arg2f24.mid8, arg1f24.mid8);
			;    genSubW( arg2f24.high8, arg1f24.high8);
			;    return Carry;
			;}
			;
			;
			;
			;bit operator> _f24_GT_f24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_f24_GT_f24
			;    Carry = 0;
			;    if (!(arg1f24.high8 | arg2f24.high8))
			;        return Carry;
			;    if (!arg1f24.15)  {
			;        if (arg2f24.15)
			;            goto _RETURN_MF;
			;        W = arg2f24.low8 - arg1f24.low8;
			;        genSubW( arg2f24.mid8, arg1f24.mid8);
			;        genSubW( arg2f24.high8, arg1f24.high8);
			;        goto _RETURN_MF;
			;    }
			;    if (!arg2f24.15)
			;        return Carry;
			;    W = arg1f24.low8 - arg2f24.low8;
			;    genSubW( arg1f24.mid8, arg2f24.mid8);
			;    genSubW( arg1f24.high8, arg2f24.high8);
			;  _RETURN_MF:
			;    if (Carry)
			;        return 0;
			;    return 1;
			;}
			;
			;
			;
			;bit operator<= _f24_LE_f24( sharedM float24 arg1f24, sharedM float24 arg2f24)
			;{
_f24_LE_f24
			;    Carry = 1;
			;    if (!(arg1f24.high8 | arg2f24.high8))
			;        return Carry;
			;    if (!arg1f24.15)  {
			;        Carry = 0;
			;        if (arg2f24.15)
			;            return Carry;
			;        W = arg2f24.low8 - arg1f24.low8;
			;        genSubW( arg2f24.mid8, arg1f24.mid8);
			;        genSubW( arg2f24.high8, arg1f24.high8);
			;        return Carry;
			;    }
			;    if (!arg2f24.15)
			;        return Carry;
			;    W = arg1f24.low8 - arg2f24.low8;
			;    genSubW( arg1f24.mid8, arg2f24.mid8);
			;    genSubW( arg1f24.high8, arg2f24.high8);
			;    return Carry;

  ; FILE math24lb.h
			;// *************************************************
			;// 24 bit floating point math functions
			;// Copyright (c) B Knudsen Data, Norway, 2000 - 2009
			;// *************************************************
			;
			;#pragma library 1
			;/* PROTOTYPES for page definition in application header file:
			;float24 log( float24 arg1f24);
			;float24 log10( float24 arg1f24);
			;float24 exp10( float24 arg1f24);
			;float24 exp( float24 arg1f24);
			;float24 cos( float24 arg1f24);
			;float24 sin( float24 arg1f24);
			;float24 sqrt( float24 arg1f24);
			;*/
			;
			;#ifndef FpFlags_defined
			; #error The basic 24 bit floating point math library must be included first
			;#endif
			;
			;#if __CoreSet__ / 100 == 12
			; #error Math functions (exp,log,..) are not adapted to 12 bit core devices
			;#endif
			;
			;#if __CoreSet__ < 1410
			; #define genAdd(r,a) W=a; btsc(Carry); W=incsz(a); r+=W
			; #define genSub(r,a) W=a; btss(Carry); W=incsz(a); r-=W
			; #define genAddW(r,a) W=a; btsc(Carry); W=incsz(a); W=r+W
			; #define genSubW(r,a) W=a; btss(Carry); W=incsz(a); W=r-W
			;#else
			; #define genAdd(r,a) W=a; r=addWFC(r)
			; #define genSub(r,a) W=a; r=subWFB(r)
			; #define genAddW(r,a) W=a; W=addWFC(r)
			; #define genSubW(r,a) W=a; W=subWFB(r)
			;#endif
			;
			;
			;float24 log( sharedM float24 arg1f24)
			;{
log
			;    sharedM float24 arg2f24;
			;
			;    if (arg1f24.mid8 & 0x80)  //  test for negative argument
			;        goto _DOMERR32;
			;    if (!arg1f24.high8)   //  test for zero argument
			;        goto _DOMERR32;
			;
			;    char savedFlags = FpFlags;   //  save rounding flag
			;    FpFlags |= 0x40;  //  enable rounding
			;
			;    char xexp = arg1f24.high8 - (FpBIAS-1);
			;    arg1f24.high8 = FpBIAS-1;
			;
			;    arg2f24 = 1.0;
			;
			;    //  .70710678118655 = 7E3504F3
			;    W = arg1f24.low8 - 0x05;
			;    W = 0x35;
			;    if (!Carry)
			;        W = 0x35+1;
			;    W = arg1f24.mid8 - W;
			;
			;    if (Carry)
			;        arg1f24 -= arg2f24;
			;    else  {
			;        arg1f24.high8 += 1;  /* arg1f24 *= 2; */
			;        arg1f24 -= arg2f24;
			;        xexp -= 1;
			;    }
			;
			;    float24 d = arg1f24;  //  save z
			;
			;    // POLL132  LOG32Q,2,0  ; Q(z)
			;    arg1f24 += 0.33339502905E+1; /* LOG32Q1 */
			;    arg1f24 *= d;
			;    arg1f24 += 0.24993759223E1;  /* LOG32Q0 */
			;    float24 c = arg1f24;
			;
			;     //   minimax rational approximation  z-.5*z*z+z*(z*z*P(z)/Q(z))
			;    // POL32  LOG32P,1,0  ; P(z)
			;    arg1f24 = d;
			;    arg1f24 *= 0.48646956294; /* LOG32P1 */
			;    arg1f24 += 0.83311400452; /* LOG32P0 */
			;
			;    c = arg1f24 / c;   //  P(z)/Q(z)
			;
			;    arg1f24.high8 = d.high8;
			;    arg2f24.high8 = d.high8;
			;    arg1f24.mid8 = d.mid8;
			;    arg2f24.mid8 = d.mid8;
			;    arg1f24.low8 = d.low8;
			;    arg2f24.low8 = d.low8;
			;    arg1f24 *= arg2f24;       // z * z;
			;
			;    float24 e = arg1f24;
			;    arg1f24 *= c;          //  z*z*P(z)/Q(z)
			;    arg1f24 *= d;          //  z*(z*z*P(z)/Q(z))
			;
			;    arg2f24 = e;
			;    if (arg2f24.high8)
			;        arg2f24.high8 --;  // arg2f24 *= 0.5;
			;    arg1f24 -= arg2f24;       //  -.5*z*z + z*(z*z*P(z)/Q(z))
			;    arg1f24 += d;          //  z -.5*z*z + z*(z*z*P(z)/Q(z))
			;
			;    if (!xexp)
			;        goto _RETURN_MF;
			;
			;    e = arg1f24;  //  save
			;
			;    // integer to floating point conversion
			;    arg1f24 = (int8) xexp;
			;
			;    d = arg1f24;  //  save k
			;
			;    arg1f24 *= -0.000212194440055;
			;
			;    arg1f24 += e;   //  log(1+z) + k*log(2)
			;
			;    e = arg1f24;  //  save
			;
			;    arg1f24 = d * 0.693359375;
			;
			;    arg1f24 += e;      //  log(1+z) + k*log(2)
			;
			;    if (!(savedFlags & 0x40))
			;        FpFlags &= ~0x40;   //  restore rounding flag
			;    goto _RETURN_MF;
			;
			;  _DOMERR32:
			;    FpDomainError = 1;   //  domain error
			;
			;  _RETURN_MF:
			;    return arg1f24;
			;}
			;
			;
			;
			;float24 log10( sharedM float24 arg1f24)
			;{
log10
			;    sharedM float24 arg2f24;      // allocation 'trick'
			;
			;    char flags = FpFlags;
			;    FpFlags |= 0x40;
			;
			;    arg1f24 = log( arg1f24);
			;
			;    arg1f24 *= 0.43429448190325;  //  log10(e);
			;
			;    if (!(flags & 0x40))
			;        FpFlags &= ~0x40;
			;
			;    return arg1f24;
			;}
			;
			;
			;
			;char floorMaskTable24( char i)
			;{
floorMaskTable24
			;    if (i & 4)  {
			;        if (i & 2)  {
			;            if (i & 1)
			;                return 128;
			;            return 192;
			;        }
			;        if (i & 1)
			;            return 224;
			;        return 240;
			;    }
			;    if (i & 2)  {
			;        if (i & 1)
			;            return 248;
			;        return 252;
			;    }
			;    if (i & 1)
			;        return 254;
			;    return 255;
			;}
			;
			;float24 floor24( sharedM float24 arg1f24)
			;{
floor24
			;    if (!arg1f24.high8)
			;        goto _RETURN_MF;
			;
			;    uns16 ma = arg1f24.low16;  //  save mantissa
			;
			;    W = arg1f24.high8 - 127;
			;    char tmp = W;
			;    if (tmp & 0x80)
			;        goto FLOOR24ZERO;
			;
			;    //  save number of zero bits
			;    W = 15 - W;
			;
			;    char tmpa = W;
			;    tmp = W;
			;
			;    if (tmp & 0x8)  // LSB+3		; divide by eight
			;        goto FLOOR24MASKH;
			;
			;
			;    W = floorMaskTable24( tmpa);    //  get mask
			;    arg1f24.low8 &= W;
			;    if (!(arg1f24.mid8 & 0x80))  //  if negative, round down
			;        goto _RETURN_MF;
			;
			;    char arg1B7 = W;
			;    if (!(arg1f24.low8 - ma.low8))
			;        goto _RETURN_MF;
			;
			;    tmp = ~arg1B7;
			;    arg1f24.low8 += tmp + 1;
			;    if (Zero_)
			;        arg1f24.mid8 += 1;
			;
			;    //  has rounding caused carryout?
			;    if (!Zero_)
			;        goto _RETURN_MF;
			;    arg1f24.mid8 = rr( arg1f24.mid8);
			;    arg1f24.low8 = rr( arg1f24.low8);
			;
			;    //  check for overflow
			;    arg1f24.high8 = incsz( arg1f24.high8);
			;    goto _RETURN_MF;
			;    goto OVERFLOW;
			;
			;
			;  FLOOR24MASKH:
			;    W = floorMaskTable24( tmpa);  //  get mask
			;    arg1f24.mid8 &= W;
			;    arg1f24.low8 = 0;
			;
			;    //  if negative, round down
			;    if (!(arg1f24.mid8 & 0x80))
			;        goto _RETURN_MF;
			;
			;    arg1B7 = W;
			;    if (( arg1f24.low8 - ma.low8) != 0)
			;        goto FLOOR24RNDH;
			;    if (!(arg1f24.mid8 - ma.mid8))
			;        goto _RETURN_MF;
			;
			;  FLOOR24RNDH:
			;    tmp = ~arg1B7;
			;    arg1f24.mid8 += tmp + 1;
			;
			;    //  has rounding caused carryout?
			;    if (!Carry)
			;        goto _RETURN_MF;
			;    arg1f24.mid8 = rr( arg1f24.mid8);
			;    arg1f24.low8 = rr( arg1f24.low8);
			;
			;    //  check for overflow
			;    arg1f24.high8 = incsz( arg1f24.high8);
			;    goto _RETURN_MF;
			;    goto OVERFLOW;
			;
			;
			;  FLOOR24ZERO:
			;    if (!(arg1f24.mid8 & 0x80))
			;        goto RES0;
			;    return -1.0;
			;
			;  RES0:
			;    W = 0;
			;    goto ASSIGNW;
			;
			;  OVERFLOW:
			;    FpOverflow = 1;
			;    W = 0xFF;
			;  ASSIGNW:
			;    arg1f24.low8 = W;
			;    arg1f24.mid8 = W;
			;    arg1f24.high8 = W;
			;
			;  _RETURN_MF:
			;    return arg1f24;
			;}
			;
			;
			;
			;float24 exp10( sharedM float24 arg1f24)
			;{
exp10
			;    sharedM float24 arg2f24;      // allocation 'trick'
			;    float24 c, d;
			;    char xexp;
			;
			;    if (( arg1f24.high8 - 100) & 0x80)
			;        goto EXP1;   //  return e**x = 1
			;
			;    W = 132 - arg1f24.high8;
			;    if (!Carry)
			;        goto _DOMERR;
			;    if (!Zero_)
			;        goto ARGOK;
			;
			;    if (!(arg1f24.mid8 & 0x80))  {
			;        //  positive domain check
			;        W = 26 - arg1f24.mid8;
			;        if (!Carry)
			;            goto _DOMERR;
			;        if (!Zero_)
			;            goto ARGOK;
			;
			;        W = 33 - arg1f24.low8;
			;        if (!Carry)
			;            goto _DOMERR;
			;    }
			;    else  {
			;
			;        W = 151 - arg1f24.mid8;
			;        if (!Carry)
			;            goto _DOMERR;
			;        if (!Zero_)
			;            goto ARGOK;
			;
			;        W = 184 - arg1f24.low8;
			;        if (!Carry)
			;            goto _DOMERR;
			;    }
			;
			;  ARGOK:
			;
			;    char savedFlags = FpFlags;
			;    FpFlags |= 0x40;  //  enable rounding
			;
			;    c = arg1f24;  //  save x
			;    arg1f24 *= 3.32192809489;  //  1/log10(2) = 3.32192809489
			;    arg1f24 += 0.5;  //  k = [ x / log10(2) + .5 ]
			;    arg1f24 = floor24( arg1f24);
			;
			;    float24 e = arg1f24; //  save float k
			;    FpFlags &= ~0x40;
			;    //floating point to integer conversion
			;    xexp = arg1f24; //  k = [ x / ln(2) + .5 ]
			;    FpFlags |= 0x40;
			;    arg1f24 = e * -0.30078125; //  c1
			;    d = arg1f24 + c;
			;    arg1f24 = e * -2.487456637421670e-04;  // c2
			;    arg1f24 += d;
			;    d = arg1f24;  //  save f
			;
			;    if (!(d.mid8 & 0x80))  {
			;        // POL32  EXP1032H,5,4   ; minimax approximation on [0,log10(2)/2]
			;        arg1f24 *= 6.388992868121E-1;/* EXP1032H5 */
			;        arg1f24 += 1.154596329197E0; /* EXP1032H4 */
			;        arg1f24 *= d;
			;        arg1f24 += 2.035920309947E0; /* EXP1032H3 */
			;        arg1f24 *= d;
			;        arg1f24 += 2.650909138708E0; /* EXP1032H2 */
			;        arg1f24 *= d;
			;        arg1f24 += 2.302585504840E0; /* EXP1032H1 */
			;    }
			;    else  {
			;        // POL32 EXP1032L,5,4  ; minimax approximation on [-log10(2)/2,0]
			;        arg1f24 *= 4.544952589676E-1;/* EXP1032L5 */
			;        arg1f24 += 1.157459289066E0; /* EXP1032L4 */
			;        arg1f24 *= d;
			;        arg1f24 += 2.033640565225E0; /* EXP1032L3 */
			;        arg1f24 *= d;
			;        arg1f24 += 2.650914554552E0; /* EXP1032L2 */
			;        arg1f24 *= d;
			;        arg1f24 += 2.302584716116E0; /* EXP1032L1 */
			;    }
			;    arg1f24 *= d;
			;    if (!(savedFlags & 0x40))
			;        FpFlags &= ~0x40;
			;    arg1f24 += 1.0; /* EXP1032H0/EXP1032L0 */
			;
			;    arg1f24.high8 += xexp;
			;    goto _RETURN_MF;
			;
			;  EXP1:
			;    arg1f24 = 1.0;   //  return 10**x = 1.0
			;    goto _RETURN_MF;
			;
			;  _DOMERR:
			;    FpDomainError = 1;   //  domain error
			;
			;  _RETURN_MF:
			;    return arg1f24;
			;}
			;
			;
			;
			;float24 exp( sharedM float24 arg1f24)
			;//     Maximum argument : 88.7228391117 = log(2**128)
			;//     Minimum argument : -87.3365447506 = log(2**-126)
			;{
exp
			;    sharedM float24 arg2f24;
			;    float24 c, d;
			;    char xexp;
			;
			;    if (( arg1f24.high8 - 94) & 0x80)
			;        goto EXP1;   //  return e**x = 1
			;
			;    W = 133 - arg1f24.high8;
			;    if (!Carry)
			;        goto _DOMERR;
			;    if (!Zero_)
			;        goto ARGOK;
			;
			;    if (!(arg1f24.mid8 & 0x80))  {
			;
			;        W = 49 - arg1f24.mid8;
			;        if (!Carry)
			;            goto _DOMERR;
			;        if (!Zero_)
			;            goto ARGOK;
			;
			;        W = 114 - arg1f24.midL8;
			;        if (!Carry)
			;            goto _DOMERR;
			;    }
			;    else {
			;
			;        W = 174 - arg1f24.mid8;
			;        if (!Carry)
			;            goto _DOMERR;
			;        if (!Zero_)
			;            goto ARGOK;
			;
			;        W = 172 - arg1f24.midL8;
			;        if (!Carry)
			;            goto _DOMERR;
			;    }
			;
			;  ARGOK:
			;
			;    char savedFlags = FpFlags;
			;    FpFlags |= 0x40;  //  enable rounding
			;
			;    c = arg1f24;  //  save x
			;    arg1f24 *= 1.44269504089;
			;    arg1f24 += 0.5; //  k = [ x / ln(2) + .5 ]
			;    arg1f24 = floor24( arg1f24);
			;
			;    float24 e = arg1f24;
			;    xexp = arg1f24;   //  k = [ x / ln(2) + .5 ]
			;    arg1f24 = e * -0.69140625; // c1
			;    d = arg1f24 + c;
			;    arg1f24 = e * -1.740930559945286e-03;  // c2
			;    arg1f24 += d;
			;    d = arg1f24;  //  save f
			;
			;    if (!(d.mid8 & 0x80))  {
			;        // POL32   EXP32H,5,0
			;        arg1f24 *= 0.989943653774E-2; /* EXP32H5 */
			;        arg1f24 += 0.410473706887E-1; /* EXP32H4 */
			;        arg1f24 *= d;
			;        arg1f24 += 0.166777360103;    /* EXP32H3 */
			;        arg1f24 *= d;
			;        arg1f24 += 0.499991163105;    /* EXP32H2 */
			;        arg1f24 *= d;
			;        arg1f24 += 1.00000025499;     /* EXP32H1 */
			;    }
			;    else  {
			;        // POL32   EXP32L,5,0
			;        arg1f24 *= 0.699995870637E-2; /* EXP32L5 */
			;        arg1f24 += 0.411548782678E-1; /* EXP32L4 */
			;        arg1f24 *= d;
			;        arg1f24 += 0.166574299807;    /* EXP32L3 */
			;        arg1f24 *= d;
			;        arg1f24 += 0.499992371926;    /* EXP32L2 */
			;        arg1f24 *= d;
			;        arg1f24 += 0.999999766814;    /* EXP32L1 */
			;    }
			;    arg1f24 *= d;
			;    arg1f24 += 1.0;   /* EXP32H0 or EXP32L0 */
			;    arg1f24.high8 += xexp;
			;
			;    if (!(savedFlags & 0x40))
			;        FpFlags &= ~0x40;   //  restore rounding flag
			;    goto _RETURN_MF;
			;
			;  EXP1:
			;    arg1f24 = 1.0;   //  return 10**x = 1.0
			;    goto _RETURN_MF;
			;
			;  _DOMERR:
			;    FpDomainError = 1;   //  domain error
			;
			;  _RETURN_MF:
			;    return arg1f24;
			;}
			;
			;
			;
			;
			;
			;
			;float24 cosin24( sharedM float24 arg1f24, sharedM float24 arg2f24, char cosinus)
			;{
cosin24
			;    float24 c, d;
			;    char j;
			;
			;    char savedFlags = FpFlags;  //  save rounding flag
			;    FpFlags |= 0x40;  //  enable rounding
			;
			;    char csign = 0;    //  initialize sign
			;
			;    if (!cosinus  &&  (arg1f24.mid8 & 0x80))
			;        csign |= 0x80;
			;
			;    arg1f24.mid8 &= ~0x80;  //  use |x|
			;
			;    //  loss threshold check
			;    // arg1f24 <= +512.0
			;    // arg1f24 >= -512.0
			;    if (arg1f24.high8 >= 0x88)
			;        FpDomainError = 1;   //  domain error
			;
			;    c = arg1f24;  //  save |x|
			;
			;    // fixed point multiplication by 4/pi
			;    arg1f24 *= 1.27323954474;   // 4/pi
			;
			;    FpFlags &= ~0x40;
			;
			;    //  y = [ |x| * (4/pi) ]
			;    arg1f24.low16 = arg1f24;  // floating point to integer conversion
			;
			;    FpFlags |= 0x40;
			;
			;    if (arg1f24.low8 & 0x1)
			;        arg1f24.low16 += 1;  // make arg1f24 even
			;
			;    //  j = y mod 8
			;    j = arg1f24.low8 & 7;  // 0,2,4,6
			;    if (j >= 4)  {
			;        csign ^= 128;
			;        j -= 4;
			;    }
			;
			;    arg1f24 = arg1f24.low16;  // integer to floating point conversion
			;
			;    //  save y in DARG
			;    d.high8 = arg1f24.high8;
			;    if (Zero_)
			;        goto ZEQX;
			;    d.low16 = arg1f24.low16;
			;
			;    arg1f24 *= -7.851562500000000e-01;
			;    c = arg1f24 + c;    //  z1 = |x| - y * (p1)
			;    arg1f24 = d * -2.419133974475018e-04;
			;    arg1f24 += c;
			;
			;    //  save z in c
			;    c.high8 = arg1f24.high8;
			;    arg2f24.high8 = arg1f24.high8;
			;    c.mid8 = arg1f24.mid8;
			;    arg2f24.mid8 = arg1f24.mid8;
			;    c.low8 = arg1f24.low8;
			;    arg2f24.low8 = arg1f24.low8;
			;
			;    goto POLYNOM;
			;
			;   ZEQX:
			;    arg1f24.high8 = c.high8;
			;    arg2f24.high8 = c.high8;
			;    arg1f24.mid8 = c.mid8;
			;    arg2f24.mid8 = c.mid8;
			;    arg1f24.low8 = c.low8;
			;    arg2f24.low8 = c.low8;
			;
			;   POLYNOM:
			;
			;
			;
			;    arg1f24 *= arg2f24;   // z * z
			;    d = arg1f24;   //  save z * z
			;
			;    if ((( rr( j) ^ j) & 0x1) ^ cosinus)  {
			;        // POL24  COS24,3,0
			;
			;        arg1f24 *= -1.35859090e-03;  // 117,178,18,191
			;        arg1f24 += 4.16550264e-02;   // 122,42,158,118
			;        arg1f24 *= d;
			;        arg1f24 += -4.99998569e-01;  // 125,255,255,208
			;        arg1f24 *= d;
			;        arg1f24 += 1.0;
			;    }
			;    else  {
			;        /// POL24  SIN24,2,0
			;        arg1f24 *= 8.12155753e-03;   // 120,5,16,72
			;        arg1f24 += -1.66601613e-01;  // 124,170,153,157
			;        arg1f24 *= d;
			;        arg1f24 += 9.99994993e-01;   // 126,127,255,172
			;        arg1f24 *= c;
			;    }
			;
			;    W = 128;  // LSB+1
			;    if (cosinus  &&  (j & 0x2))
			;        csign ^= W;
			;    if (csign & 0x80)
			;        arg1f24.mid8 ^= W;
			;
			;    if (savedFlags & 0x40)
			;        FpFlags |= 0x40;  //  restore rounding flag
			;    return arg1f24;
			;}
			;
			;
			;float24 cos( sharedM float24 arg1f24)
			;{
cos
			;    sharedM float24 arg2f24;      // allocation 'trick'
			;    arg1f24 = cosin24( arg1f24, arg2f24, 1);
			;    return arg1f24;
			;}
			;
			;
			;float24 sin( sharedM float24 arg1f24)
			;{
sin
			;    sharedM float24 arg2f24;      // allocation 'trick'
			;    arg1f24 = cosin24( arg1f24, arg2f24, 0);
			;    return arg1f24;
			;}
			;
			;
			;#if !defined __CC5XFREE__
			;
			;float24 sqrt( float24 arg)
			;// Copyright (c) Jim van Zee, Seattle, WA., 2004
			;{
			;    uns8 arg_exp @ arg.high8;    // arg exponent (offset by FpBIAS)
			;    uns24 root = 0;              // result (treated as an integer)
			;    float24 sqrtf @ root;        // result (treated as a float)
			;    uns24 remain;
			;    uns8 nr_bits;
			;
			;    if (arg.mid8 & 0x80) {  // test for negative argument
			;        FpDomainError=1;
			;        goto END;           // negative #s return '0'
			;    }
			;    if (!arg_exp)
			;        goto END;           // 0->0 (all bytes are 0)
			;
			;    arg.15 = 1;             // restore hidden bit
			;    remain = 0;             // clear remainder
			;    nr_bits = 16;           // initialize bit count
			;
			;    // Here's a 'tricky bit': 'even' exponents work out OK, but 'odd'
			;    // exponents need one less shift initially in order to align the
			;    // bits in a 'powers-of-four' pattern (two-bits-at-a-time).
			;
			;    btss(arg_exp.0);          // skip if exponent is odd
			;    do {
			;        remain.23=1;          // set 2x shift flag
			;        root = rl(root);        // exponent= 'spill byte'
			;        root.0=1;               // add '1' to form '2N+1'
			;        root.1=0;               // clear next root bit
			;        do {
			;            arg.low16 = rl(arg.low16); // shift mantissa into 'remain'
			;            remain = rl(remain);       // two-bits-at-a-time (add 0's)
			;        } while(Carry);         // Carry=1 the first time
			;        arg.0=0;                // clear the carry-in bit
			;
			;        // now compare root and remainder; if remain >= root, subtract
			;        // to get the new remainder & set bit=1; otherwise leave bit=0.
			;
			;        //        if (remain >= root) // 3-byte compare
			;        //        {   remain -= root; // update remainder
			;        //            root.1 = 1;   } // set this bit = 1
			;
			;        W = remain.low8 - root.low8;  // compare remain w/root
			;        genSubW( remain.mid8, root.mid8);
			;        genSubW( remain.high8, root.high8);
			;
			;        // If remain >= root, the next bit is '1', otherwise '0'
			;        if (Carry) {          // remain -= root;
			;            remain.high8 = W;   // save 'spill byte'
			;            remain.low8 -= root.low8;   // do subtraction
			;            genSub( remain.mid8, root.mid8);
			;            root.1 = 1; // note: lsb is bit1, not bit0!
			;        }
			;
			;    } while (--nr_bits); // 16 bit mantissa
			;
			;    // Finally unshift root (only need to do 16 bits, since msb->0!)
			;    root.low16 = rr(root.low16);       // '2N+1' -> 'N'
			;    root.15 = 0;            // clear hidden bit
			;
			;    // and set exponent = arg_exp/2 (we used this as the spill byte)
			;    arg_exp += FpBIAS;      // double the bias
			;    root.high8=rr(arg_exp); // root exp = arg_exp/2+FpBIAS
			;  END:
			;    return sqrtf;           // neg & zero args return 0
			;}
			;
			;#else
			;
			;float24 sqrt( sharedM float24 arg1f24)
			;{
sqrt
			;    sharedM float24 arg2f24;      // allocation 'trick'
			;
			;    if (arg1f24.mid8 & 0x80)     // test for negative argument
	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC arg1f24+1,7
			;        goto _DOMERR;
	GOTO  m033
			;    if (!arg1f24.high8)          // return if argument zero
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24+2,1
	BTFSC 0x03,Zero_
			;        goto _RETURN_MF;
	GOTO  m034
			;
			;    char cexp = arg1f24.high8;    // save exponent
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24+2,W
	MOVWF cexp
			;    char savedFLAGS = FpFlags;
	MOVF  FpFlags,W
	MOVWF savedFLAGS
			;    FpFlags |= 0x40;           // enable rounding
	BSF   FpFlags,6
			;
			;    arg1f24.high8 = FpBIAS;   // compute z
	MOVLW 127
	MOVWF arg1f24+2
			;    float24 d = arg1f24;
	MOVF  arg1f24,W
	MOVWF d_5
	MOVF  arg1f24+1,W
	MOVWF d_5+1
	MOVF  arg1f24+2,W
	MOVWF d_5+2
			;
			;    if (arg1f24.mid8 & 0x40)  {
	BTFSS arg1f24+1,6
	GOTO  m030
			;        // POL24  SQRT24H,4,0
			;        arg1f24 *= -5.6351436252E-3;  // SQRT24H4
	MOVLW 167
	MOVWF arg2f24
	MOVLW 184
	MOVWF arg2f24+1
	MOVLW 119
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += 5.5047377031E-2; // SQRT24H3
	MOVLW 121
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 97
	MOVWF arg2f24+1
	MOVLW 122
	MOVWF arg2f24+2
	CALL  _fadd24
			;        arg1f24 *= d;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  d_5,W
	MOVWF arg2f24
	MOVF  d_5+1,W
	MOVWF arg2f24+1
	MOVF  d_5+2,W
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += -2.3944355047E-1;  // SQRT24H2
	MOVLW 49
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 245
	MOVWF arg2f24+1
	MOVLW 124
	MOVWF arg2f24+2
	CALL  _fadd24
			;        arg1f24 *= d;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  d_5,W
	MOVWF arg2f24
	MOVF  d_5+1,W
	MOVWF arg2f24+1
	MOVF  d_5+2,W
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += 8.3106978456E-1; // SQRT24H1
	MOVLW 193
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 84
	MOVWF arg2f24+1
	MOVLW 126
	MOVWF arg2f24+2
	CALL  _fadd24
			;        arg1f24 *= d;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  d_5,W
	MOVWF arg2f24
	MOVF  d_5+1,W
	MOVWF arg2f24+1
	MOVF  d_5+2,W
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += 3.5963132863E-1;  // SQRT24H0
	MOVLW 34
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 56
	MOVWF arg2f24+1
	MOVLW 125
	MOVWF arg2f24+2
	CALL  _fadd24
			;    }
			;    else  {
	GOTO  m031
			;        // POL24  SQRT24L,4,0
			;        arg1f24 *= -1.8702682470E-2;  // SQRT24L4
m030	MOVLW 54
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 153
	MOVWF arg2f24+1
	MOVLW 121
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += 1.3009144111E-1; // SQRT24L3
	MOVLW 55
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 5
	MOVWF arg2f24+1
	MOVLW 124
	MOVWF arg2f24+2
	CALL  _fadd24
			;        arg1f24 *= d;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  d_5,W
	MOVWF arg2f24
	MOVF  d_5+1,W
	MOVWF arg2f24+1
	MOVF  d_5+2,W
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += -4.0192034196E-1;  // SQRT24L2
	MOVLW 201
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 205
	MOVWF arg2f24+1
	MOVLW 125
	MOVWF arg2f24+2
	CALL  _fadd24
			;        arg1f24 *= d;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  d_5,W
	MOVWF arg2f24
	MOVF  d_5+1,W
	MOVWF arg2f24+1
	MOVF  d_5+2,W
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += 9.8831235597E-1;  // SQRT24L1
	MOVLW 2
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 125
	MOVWF arg2f24+1
	MOVLW 126
	MOVWF arg2f24+2
	CALL  _fadd24
			;        arg1f24 *= d;
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  d_5,W
	MOVWF arg2f24
	MOVF  d_5+1,W
	MOVWF arg2f24+1
	MOVF  d_5+2,W
	MOVWF arg2f24+2
	CALL  _fmul24
			;        arg1f24 += 3.0221977303E-1;  // SQRT24L0
	MOVLW 189
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVWF arg2f24
	MOVLW 26
	MOVWF arg2f24+1
	MOVLW 125
	MOVWF arg2f24+2
	CALL  _fadd24
			;    }
			;
			;    if (!(cexp & 0x1))      // is cexp even or odd?
m031	BCF   0x03,RP0
	BCF   0x03,RP1
	BTFSC cexp,0
	GOTO  m032
			;        arg1f24 *= 1.41421356237;  // sqrt(2)
	MOVLW 5
	MOVWF arg2f24
	MOVLW 53
	MOVWF arg2f24+1
	MOVLW 127
	MOVWF arg2f24+2
	CALL  _fmul24
			;
			;    // divide exponent by two
			;    cexp += 127;
m032	MOVLW 127
	BCF   0x03,RP0
	BCF   0x03,RP1
	ADDWF cexp,1
			;    arg1f24.high8 = rr( cexp);
	RRF   cexp,W
	MOVWF arg1f24+2
			;
			;    if (!(savedFLAGS & 0x40))
	BTFSC savedFLAGS,6
	GOTO  m034
			;        FpFlags &= ~0x40;
	BCF   FpFlags,6
			;
			;    goto _RETURN_MF;
	GOTO  m034
			;
			;  _DOMERR:
			;    FpDomainError = 1;   //  domain error
m033	BCF   0x03,RP0
	BCF   0x03,RP1
	BSF   0x35,FpDomainError
			;
			;  _RETURN_MF:
			;    return arg1f24;
m034	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24,W
	RETURN

  ; FILE test4.c
			;/* test4.c  float square root             */
			;/* No hardware needed                     */
			;/* B Knudsen Cc5x C-compiler - not ANSI-C */
			;
			;#include "16F690.h"
			;#include "math24f.h"
			;#include "math24lb.h"
			;#pragma config |= 0x00D4
			;
			;void main( void)
			;{
main
			;  float a,b;
			;  b = sqrt(a);
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  a,W
	MOVWF arg1f24
	MOVF  a+1,W
	MOVWF arg1f24+1
	MOVF  a+2,W
	MOVWF arg1f24+2
	CALL  sqrt
	BCF   0x03,RP0
	BCF   0x03,RP1
	MOVF  arg1f24,W
	MOVWF b
	MOVF  arg1f24+1,W
	MOVWF b+1
	MOVF  arg1f24+2,W
	MOVWF b+2
			;}
	SLEEP
	GOTO main

	END


; *** KEY INFO ***

; 0x0001 P0  105 word(s)  5 % : _fmul24
; 0x006A P0  201 word(s)  9 % : _fadd24
; 0x0133 P0  197 word(s)  9 % : sqrt
; 0x01F8 P0   19 word(s)  0 % : main

; RAM usage: 22 bytes (21 local), 234 bytes free
; Maximum call level: 2
;  Codepage 0 has  523 word(s) :  25 %
;  Codepage 1 has    0 word(s) :   0 %
; Total of 523 code words (12 %)
