//+------------------------------------------------------------------+
//|                                                  SineSupport.mq4 |
//|                                   Copyright © 2008, Craig Dargan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Craig Dargan"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Crimson
#property indicator_width1 2
#property indicator_width2 2
//---- input parameters
extern double    alpha=0.07;
//---- buffers
double resistance[];
double support[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,1);
   //SetIndexArrow(0,250);
   SetIndexBuffer(0,resistance);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_LINE,1);
   //SetIndexArrow(1,250);
   SetIndexBuffer(1,support);
   SetIndexEmptyValue(1,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int    counted_bars=IndicatorCounted();
//----
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   
   int limit = Bars-counted_bars;
   
   for (int i=limit;i>=0;i--)
   {
      double sine=iCustom(Symbol(),0,"Sinewave2",alpha,0,i);
      double lead=iCustom(Symbol(),0,"Sinewave2",alpha,1,i);
      double sinelast=iCustom(Symbol(),0,"Sinewave2",alpha,0,i+1);
      double leadlast=iCustom(Symbol(),0,"Sinewave2",alpha,1,i+1);
      
      if (leadlast>sinelast && lead<sine)
      {
         resistance[i]=iHigh(Symbol(),0,i);
         support[i]=NULL;
         
      }
      else
      {
         if (leadlast<sinelast && lead>sine)
         {
            resistance[i]=NULL;
            support[i]=iLow(Symbol(),0,i);
         }
         else
         {
            resistance[i]=resistance[i+1];
            support[i]=support[i+1];
         }
      }
   }

//----
   return(0);
}
//+------------------------------------------------------------------+