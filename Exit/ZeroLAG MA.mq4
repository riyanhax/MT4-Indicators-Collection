//+------------------------------------------------------------------+
//|                                                   ZeroLAG MA.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int nZLMAPeriod = 21;
extern int nZLMAShift = 0;
extern int nZLMAMethod = 1;
extern int nZLMAApplPrice = 0;
extern int nZLMASmPeriod = 21;
extern int nZLMASmShift = 0;
extern int nZLMASmMethod = 1;
//---- indicator buffers
double dZLMABuffer[];
double dWorkBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexBuffer(0, dZLMABuffer);
   SetIndexBuffer(1, dWorkBuffer);
   SetIndexStyle(0, DRAW_LINE);
   IndicatorShortName("ZeroLAG MA(" + nZLMAPeriod + ", " + nZLMAShift + ", " + 
                      nZLMAMethod + ", " + nZLMAApplPrice + ")");
   SetIndexDrawBegin(0, nZLMAPeriod + nZLMASmPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   double dMA;   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) 
       return(-1);
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;
   for(int i = 0; i < limit; i++)
       dWorkBuffer[i] = iMA(NULL, 0, nZLMAPeriod, nZLMAShift, nZLMAMethod, nZLMAApplPrice, i);
   for(i = 0; i < limit; i++)
     {
       dMA = iMAOnArray(dWorkBuffer, 0, nZLMASmPeriod, nZLMASmShift, nZLMASmMethod, i);
       dZLMABuffer[i] = dWorkBuffer[i] + dWorkBuffer[i] - dMA;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+