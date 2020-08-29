//+------------------------------------------------------------------+
//| THANKS to Keris2112 for the #MTF-TEMPLATE code                   |
//|                                                                  |
//| BB-Squeeze converted to MTF format by FX Sniper                  |
//+------------------------------------------------------------------+
#property indicator_separate_window
//----
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 White
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_level1 0.0
//---- input parameters
/*
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
PRICE_CLOSE    0 Close price. 
PRICE_OPEN     1 Open price. 
PRICE_HIGH     2 High price. 
PRICE_LOW      3 Low price. 
PRICE_MEDIAN   4 Median price, (high+low)/2. 
PRICE_TYPICAL  5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 
You must use the numeric value of the Applied Price that you want to use
when you set the 'applied_price' value with the indicator inputs.
*/
extern int TimeFrame=0;
extern int History=500;
//----
extern int       bolPrd=20;
extern double    bolDev=2.0;
extern int       keltPrd=20;
extern double    keltFactor=1.5;
extern int       momPrd=12;
//----
double upB[];
double loB[];
double upK[];
double loK[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,upB);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,loB);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,upK);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexArrow(2,159);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,loK);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexArrow(3,159);/**/
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
     }
   IndicatorShortName("MTF_BB-Sqeeze "+TimeFrameStr);
   return(0);
  }
//----
//+------------------------------------------------------------------+
//| MTF MACD                                                         |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,y=0;
   // Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   //limit=History;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+TimeFrame/Period();
   
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
/*
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
*/
      //  iCustom(NULL,TimeFrame,"DSS",LP,SP,0,y);
      upB[i]=iCustom(NULL,TimeFrame,"bbsqueeze",bolPrd,bolDev,keltPrd,keltFactor,momPrd,0,y);
      loB[i]=iCustom(NULL,TimeFrame,"bbsqueeze",bolPrd,bolDev,keltPrd,keltFactor,momPrd,1,y);
      upK[i]=iCustom(NULL,TimeFrame,"bbsqueeze",bolPrd,bolDev,keltPrd,keltFactor,momPrd,2,y);
      loK[i]=iCustom(NULL,TimeFrame,"bbsqueeze",bolPrd,bolDev,keltPrd,keltFactor,momPrd,3,y);
     }
   //----
   return(0);
  }
//+------------------------------------------------------------------+