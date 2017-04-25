/* delays.h Function prototypes for delays.c */


/* 
  Delays a multiple of 1 milliseconds at 4 MHz
  using the TMR0 timer 
*/
void delay( char millisec);


/*
  Delays a multiple of 10 milliseconds using the TMR0 timer
  Clock : 4 MHz   => period T = 0.25 microseconds
  1 IS = 1 Instruction Cycle = 1 microsecond
  error: 0.16 percent
*/
void delay10( char n);

