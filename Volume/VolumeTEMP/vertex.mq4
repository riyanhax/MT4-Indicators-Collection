//  Vertex.mq4 версия 0.1а 

#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_minimum 0
#property indicator_maximum 1.1

#property indicator_color1 Gray
#property indicator_width1 1

#property indicator_color2 Red
#property indicator_width2 2

#property indicator_color3 DodgerBlue
#property indicator_width3 2

extern int TrendPeriod = 20;
extern int ForcePeriod = 60;    // для аналогии с TD&FI устанавливаем ForcePeriod = 3 * TrendPeriod

extern double LineValue = 0.25;

double line[];
double pos_values[];
double neg_values[];

double values[];
double ema[];
double dema[];
double force[];

int init() {
  IndicatorBuffers(7);
  
  SetIndexStyle(0, DRAW_LINE);      SetIndexBuffer(0, line);
  SetIndexStyle(1, DRAW_HISTOGRAM); SetIndexBuffer(1, pos_values);
  SetIndexStyle(2, DRAW_HISTOGRAM); SetIndexBuffer(2, neg_values);
  
  SetIndexBuffer(3, values);
  SetIndexBuffer(4, ema);
  SetIndexBuffer(5, dema);
  SetIndexBuffer(6, force);

  return(0);
}

int deinit() {

  return(0);
}

int start() {
  int idx;
  int counted = IndicatorCounted();
  if (counted < 0) return (-1);
  if (counted > 0) counted--;
  int limit = Bars - counted;

  for (idx = limit; idx >= 0; idx--) ema[idx] = iMA(NULL, 0, TrendPeriod, 0, MODE_EMA, PRICE_CLOSE, idx);
  for (idx = limit; idx >= 0; idx--) dema[idx] = iMAOnArray(ema, 0, TrendPeriod, 0, MODE_EMA, idx);
  
  for (idx = limit; idx >= 0; idx--) {
    double ema_direct = ema[idx] - ema[idx+1]; 
    double dema_direct = dema[idx] - dema[idx+1];
    double delta = MathAbs(ema[idx] - dema[idx]) / Point;  
    double direct = 0.5*(ema_direct + dema_direct) / Point;    
    force[idx] = delta * MathPow(direct, 3);
    double extremum = FindExtremum(force, ForcePeriod, idx);  
    if (extremum > 0.0) values[idx] = force[idx] / extremum; else values[idx] = 0.0;
  }
  
  for (idx = limit; idx >= 0; idx--) {
    line[idx] = LineValue; 
    if (values[idx] > 0.0) {pos_values[idx] = MathAbs(values[idx]); neg_values[idx] = 0.0;} 
      else if (values[idx] < 0.0) {pos_values[idx] = 0.0; neg_values[idx] = MathAbs(values[idx]);}
        else {pos_values[idx] = 0.0; neg_values[idx] = 0.0;} 
  }  
  return(0);
}

double FindExtremum(double data[], int count, int index) {
  double result = 0.0;
  for (int idx = count - 1; idx >= 0; idx--)
    if (result < MathAbs(data[index+idx])) result = MathAbs(data[index+idx]);
  return (result);
}