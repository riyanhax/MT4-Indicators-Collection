//+------------------------------------------------------------------+
//|                                     Behgozin Strength Finder.mq4 |
//|                                  http://www.worldwide-invest.org |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Maximo."
#property link      "http://www.worldwide-invest.org"
#property indicator_separate_window
#property indicator_color1 DodgerBlue
#property indicator_buffers 1
#property indicator_level1  0
#property indicator_levelcolor DimGray
#property indicator_levelstyle STYLE_DOT
 
extern int period_EMA = 10;
extern int period_WMA = 6;

double     Buffer1[];

int init()
{
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);  
   SetIndexBuffer(0, Buffer1); 
   return(0);
}
int deinit() { return(0); }

int start()
{
   int counted = IndicatorCounted();
   if (counted < 0) return (-1);
   if (counted > 0) counted--;
   int limit = Bars-counted;
 
   for (int i = 0; i < limit; i++)
   {
       double ema = iMA(NULL,0, period_EMA,0, MODE_EMA, PRICE_CLOSE,i); 
       Buffer1[i] = ((Close[i] - ema) / ema) * 100; 
   }
   
   for (i=0; i<limit; i++) Buffer1[i] = iMAOnArray(Buffer1, 0, period_WMA, 0, MODE_LWMA,i);      
 
   return(0);
}


