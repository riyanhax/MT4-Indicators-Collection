//+------------------------------------------------------------------+
//| Расставляет уровни стопов в зависимости от цены и ATR            +
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Below & Beloved"
#property link      "http://www.metaquotes.net/"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Aqua
#property indicator_color3 Red
//---- input parameters
//extern int ATRPeriod=5;
//extern  int MA_Type_0_3=1;
//extern double Risk_0_5=3;
extern color ColorUpperStop=Blue;
extern color ColorLowerStop=Brown;
extern bool ShowGraf=true;
extern int CountBarsForShift=12;
extern int CountBarsForAverage=77;
extern double Target=2.5;
//extern int Count=200;
//---- indicator buffers
double MA[], MAUp[], MADn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- line shifts when drawing
   SetIndexShift(0,0);
//---- first positions skipped when drawing
   IndicatorShortName("ATRAuto("+CountBarsForAverage+","+Target+")");
   SetIndexDrawBegin(0,CountBarsForAverage);
   SetIndexDrawBegin(1,CountBarsForAverage);
   SetIndexDrawBegin(2,CountBarsForAverage);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,MA);
   SetIndexBuffer(1,MAUp);
   SetIndexBuffer(2,MADn);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
     if (ShowGraf)  
     {
      SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY, ColorUpperStop);
      SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY, ColorLowerStop);
     }
     else 
     {
      SetIndexStyle(1,DRAW_NONE,EMPTY,EMPTY, ColorUpperStop);
      SetIndexStyle(2,DRAW_NONE,EMPTY,EMPTY, ColorLowerStop);
     }
//---- index labels
   SetIndexLabel(0,"MAX("+CountBarsForAverage+","+Target+")");
   SetIndexLabel(1,"MAXUp("+CountBarsForAverage+","+Target+")");
   SetIndexLabel(2,"MAXDn("+CountBarsForAverage+","+Target+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("StopUpTxt");
   ObjectDelete("StopDnTxt");
   ObjectDelete("StopUpLine");
   ObjectDelete("StopDnLine");
   //ObjectDelete("Average");
   return(0);
  }
//+------------------------------------------------------------------+
//| Bill Williams' Alligator                                         |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted(), i, y, CountAverage;
   double   Spread=Ask-Bid;//MathPow(10,-MarketInfo(Symbol(),MODE_SPREAD));
   double  CandleSum=0, CandleAverage=0 ;
   //if (MA_Type_0_3<0 || MA_Type_0_3>4) MA_Type_0_3=0;
   //if (Risk_0_5>6) Risk_0_5=0;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//-----
   ObjectCreate("StopUpLine", OBJ_HLINE, 0, Time[0],Open[0]);
   ObjectSet("StopUpLine", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("StopUpLine", OBJPROP_COLOR, ColorUpperStop);
   ObjectCreate("StopUpTxt", OBJ_TEXT, 0, Time[0], Close[0]);
   //
   ObjectCreate("StopDnLine", OBJ_HLINE, 0, Time[0],Open[0]);
   ObjectSet("StopDnLine", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("StopDnLine", OBJPROP_COLOR, ColorLowerStop);
   ObjectCreate("StopDnTxt", OBJ_TEXT, 0, Time[0], Close[0]);
   //ObjectCreate("Average", OBJ_LABEL, 0, 0,0);
   //ObjectSet("Average", OBJPROP_CORNER, 3);
   //ObjectSet("Average", OBJPROP_XDISTANCE, 2);
   //ObjectSet("Average", OBJPROP_YDISTANCE, 2);
//---- main loop
     for( i=limit; i>=0; i--)     
     {
      CandleSum=0;
      for(CountAverage=CountBarsForAverage; CountAverage>0; CountAverage--)
         CandleSum+=MathAbs(High[CountAverage+i]-Low[CountAverage+i]);
      CandleAverage=CandleSum/CountBarsForAverage;
      //ATR=iCustom(NULL,0, "ATR", ATRPeriod,MA_Type_0_3,0,i+1);
      //MA[i]=iMA(NULL,0,ATRPeriod,0, MA_Type_0_3, PRICE_OPEN,i);
      //Comment(CandleAverage);
      MAUp[i]=Open[i]+Target*CandleAverage+Spread;
      MADn[i]=Open[i]-Target*CandleAverage;
      ObjectMove("StopUpLine", 0, Time[0],  MAUp[i]);
      ObjectSetText("StopUpTxt", DoubleToStr(MAUp[i],Digits)+"(+"+
      DoubleToStr((MAUp[i]-Open[i])*MathPow(10,Digits),0)+")", 12, "Terminal",ColorUpperStop);
      ObjectMove("StopUpTxt",0, Time[0]+CountBarsForShift*60*Period(),  MAUp[i]);
      ObjectMove("StopUpTxt",1, Time[0]+CountBarsForShift*60*Period(),  MAUp[i]);
      //
      ObjectMove("StopDnLine", 0, Time[0],  MADn[i]);
      ObjectSetText("StopDnTxt", DoubleToStr(MADn[i],Digits)+"("+
      DoubleToStr((MADn[i]-Open[i])*MathPow(10,Digits),0)+")", 12, "Terminal",ColorLowerStop);
      ObjectMove("StopDnTxt",0, Time[0]+CountBarsForShift*60*Period(),  MADn[i]);
      ObjectMove("StopDnTxt",1, Time[0]+CountBarsForShift*60*Period(),  MADn[i]);
      //Comment (GoUp);
     }
//---- done
   //Comment(Spread);
   return(0);
  }
//+------------------------------------------------------------------+

