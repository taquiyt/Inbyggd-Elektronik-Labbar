//Define parameters
#define dt 0.1 //100 ms looptime
#define K 5
#define Td 1
#define Ti 10

float PID_regulator( float setpoint, float actual_position )
{
  static float pre_error = 0;
  static float integral  = 0;
  float error;
  float derivative;
  float output;

  //Caculate P,I,D
  error      = setpoint - actual_position;
  integral   = integral + error*dt;
  derivative = (error - pre_error)/dt;
  
  //Caculate output
  output = Kp*( error + Td*derivative +(1/Ti)*integral );  
  return output;
}

