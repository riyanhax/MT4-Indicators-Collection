//+------------------------------------------------------------------+
//|                                                 CMF_T3_X_EMA.mq4 |
//|                                                 Radu Draghiceanu |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Radu Draghiceanu"
#property strict
#property indicator_separate_window

#property indicator_buffers    4

#property indicator_color1     LimeGreen
#property indicator_color2     Red
#property indicator_color3     Red
#property indicator_color4     Yellow

#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_width4     2

#property indicator_level1     0
#property indicator_levelcolor DarkGray

enum enMaTypes
{
   ma_sma,     // simple moving average - SMA
   ma_ema,     // exponential moving average - EMA
   ma_dsema,   // double smoothed exponential moving average - DSEMA
   ma_dema,    // double exponential moving average - DEMA
   ma_tema,    // tripple exponential moving average - TEMA
   ma_smma,    // smoothed moving average - SMMA
   ma_lwma,    // linear weighted moving average - LWMA
   ma_pwma,    // parabolic weighted moving average - PWMA
   ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // volume weighted moving average - VWMA
   ma_hull,    // Hull moving average
   ma_tma,     // triangular moving average
   ma_sine,    // sine weighted moving average
   ma_linr,    // linear regression value
   ma_ie2,     // IE/2
   ma_nlma,    // non lag moving average
   ma_zlma,    // zero lag moving average
   ma_lead,    // leader exponential moving average
   ma_ssm,     // super smoother
   ma_smoo     // smoother
};
enum enTimeFrames
{
   tf_cu  = 0,              // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mb1 = PERIOD_MN1      // Monthly
};
enum enIterpolation
{
   int_noint, // No interpolation
   int_line,  // Linear interpolation
   int_quad   // Quadratic interpolation
};

extern enTimeFrames   TimeFrame            = tf_cu;
extern int            PriceSmoothing       = 25;
extern enMaTypes      PriceSmoothingMethod = ma_ssm;
extern double         Filter               = 0.5;
extern bool           alertsOn             = false;
extern bool           alertsOnCurrent      = true;
extern bool           alertsMessage        = true;
extern bool           alertsPushNotif      = false;
extern bool           alertsSound          = false;
extern bool           alertsEmail          = false;
extern string         soundFile            = "alert2.wav";
extern enIterpolation Interpolate          = int_line;

extern int     MAPeriod       = 6 ;
extern ENUM_MA_METHOD MAType  = MODE_SMMA ;
extern int MAShift            = 0;
extern int BarCheck = 500;

//---- buffers
double b1[];
double b2[];
double b3[];
double xxMA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//--- indicator buffers mapping
//---- indicators
    SetIndexStyle(0, DRAW_LINE, 0, 2);
    SetIndexBuffer(0, b1);
    SetIndexStyle(1, DRAW_LINE, 0, 2);
    SetIndexBuffer(1, b2);
    SetIndexStyle(2, DRAW_LINE, 0, 2);
    SetIndexBuffer(2, b3);
//----
    SetIndexStyle(3, DRAW_LINE,0, 2);
    SetIndexBuffer(3, xxMA);
    
//---- name for DataWindow and indicator subwindow label
    IndicatorShortName("VQLZ (" + PriceSmoothing  + ") ");
    SetIndexLabel(0, " VQ ");
    SetIndexLabel(3, " MA of VQZL ");  
//---
    return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   ArraySetAsSeries(b1, true);
   ArraySetAsSeries(b2, true);
   ArraySetAsSeries(b3, true);
   ArraySetAsSeries(xxMA, true);
   
   if(prev_calculated < 1)
     {
      ArrayInitialize(b1, EMPTY_VALUE);
      ArrayInitialize(b2, EMPTY_VALUE);
      ArrayInitialize(b3, EMPTY_VALUE);
      ArrayInitialize(xxMA, EMPTY_VALUE);
     }
   else
      limit++;
   for(int i = limit-1; i >= 0; i--)
     {
     if (i >= MathMin(BarCheck-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation 
  b1[i] = VQZL(0,i);     
  b2[i] = VQZL(1,i);     
  b3[i] = VQZL(2,i);     
  xxMA[i]= iMAOnArray(b1, 0 , MAPeriod , MAShift, MAType , i) ;}
  return(0); 
   }
//----
  
//+------------------------------------------------------------------+



int deinit()
  {
//----
   
//----
   return(0);
  }
  
double VQZL(int index, int shift)  
       {
       return (iCustom(NULL,TimeFrame,"Volatility_quality_-_zero_line_averages",tf_cu,PriceSmoothing,PriceSmoothingMethod,Filter,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,soundFile,index,shift));
       }