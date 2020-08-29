//+------------------------------------------------------------------+
//|                                              Keltner Channel.mq4 |
//                                        Based on version by Gilani |
//|                                  Copyright © 2011, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, EarnForex.com"
#property link      "http://www.earnforex.com"

/*
   Displays classical Keltner Channel technical indicator.
   You can modify main MA period, mode of the MA and type of prices used in MA.
   Buy when candle closes above the upper band.
   Sell when candle closes below the lower band.
   Use *very conservative* stop-loss and 3-4 times higher take-profit.
*/

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red

//---- input parameters
extern int MA_Period = 10;
// 0 - SMA, 1 - EMA, 2 - SMMA, 3 - LWMA
extern int Mode_MA = 0;
// 0 - Close, 1 - Open, 2 - High, 3 - Low, 4 - Median, 5 - Typical, 6 - Weighted
extern int Price_Type = 5;

//----
double upper[], middle[], lower[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer(0, upper);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexShift(0, 0);
   SetIndexDrawBegin(0, 0);

   SetIndexBuffer(1, middle);
   SetIndexStyle(1, DRAW_LINE, STYLE_DASHDOT);
   SetIndexShift(1, 0);
   SetIndexDrawBegin(1, 0);

   SetIndexBuffer(2, lower);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexShift(2, 0);
   SetIndexDrawBegin(2, 0);

   SetIndexLabel(0, "KC-Up(" + MA_Period + ")");    
   SetIndexLabel(1, "KC-Mid(" + MA_Period + ")"); 
   SetIndexLabel(2, "KC-Low(" + MA_Period + ")"); 

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() 
{
   int limit;
   double avg;   
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return(-1);
   if (Bars < MA_Period) return(0);
   if (counted_bars > 0) counted_bars--;
   
   limit = Bars - counted_bars;
   if (limit > Bars - MA_Period) limit = Bars - MA_Period;

   for (int i = 0; i < limit; i++) 
   {
      middle[i] = iMA(NULL, 0, MA_Period, 0, Mode_MA, Price_Type, i);
      avg = findAvg(MA_Period, i);
      upper[i] = middle[i] + avg;
      lower[i] = middle[i] - avg;
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//| Finds the moving average of the price ranges                     |
//+------------------------------------------------------------------+  
double findAvg(int period, int shift) 
{
   double sum = 0;

   for (int i = shift; i < (shift + period); i++) 
       sum += High[i] - Low[i];

   sum = sum / period;
   
   return(sum);
}  
//+------------------------------------------------------------------+



