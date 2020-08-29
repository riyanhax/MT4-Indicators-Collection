//+------------------------------------------------------------------+
//|                                                    DoubleCCI.mq4 |
//|                   Copyright © 2005, Jason Robinson (jnrtrading). |
//|                                      http://www.jnrtrading.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)."
#property link      "http://www.jnrtrading.co.uk"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Gold
#property indicator_color5 Blue
#property indicator_color6 DarkGray
#property indicator_color7 Gold
#property indicator_level1 50
#property indicator_level2 100
#property indicator_level3 150
#property indicator_level4 200
#property indicator_level5 -200
#property indicator_level6 -150
#property indicator_level7 -100
#property indicator_level8 -50

//---- input parameters
extern int TrendCCI_Period = 14;
extern int EntryCCI_Period = 6;
extern bool Zero_Cross_Alert;
extern bool Automatic_Timeframe_Setting = false;
extern int M1_TrendCCI_Period = 50;
extern int M1_EntryCCI_Period = 14;
extern int M5_TrendCCI_Period = 50;
extern int M5_EntryCCI_Period = 14;
extern int M15_TrendCCI_Period = 14;
extern int M15_EntryCCI_Period = 6;
extern int M30_TrendCCI_Period = 14;
extern int M30_EntryCCI_Period = 6;
extern int H1_TrendCCI_Period = 14;
extern int H1_EntryCCI_Period = 6;
extern int H4_TrendCCI_Period = 14;
extern int H4_EntryCCI_Period = 6;
extern int D1_TrendCCI_Period = 14;
extern int D1_EntryCCI_Period = 6;
extern int W1_TrendCCI_Period = 14;
extern int W1_EntryCCI_Period = 6;
extern int MN_TrendCCI_Period = 14;
extern int MN_EntryCCI_Period = 6;


double TrendCCI[];
double EntryCCI[];
double CCITrendUp[];
double CCITrendDown[];
double CCINoTrend[];
double CCITimeBar[];
double ZeroLine[];

int trendUp, trendDown;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
//---- indicators
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(4, TrendCCI);
   SetIndexLabel(4, "TrendCCI");
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1);
   SetIndexBuffer(0, CCITrendUp);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1);
   SetIndexBuffer(1, CCITrendDown);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0, 1);
   SetIndexBuffer(2, CCINoTrend);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0, 1);
   SetIndexBuffer(3, CCITimeBar);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexBuffer(5, EntryCCI);
   SetIndexLabel(5, "EntryCCI");
   SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexBuffer(6, ZeroLine);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
int start() {

   int limit, i, trendCCI, entryCCI;
   int counted_bars = IndicatorCounted();
   static datetime prevtime = 0;
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;

   limit=Bars;//-counted_bars;
   
   if (Automatic_Timeframe_Setting == true) {
      switch(Period()) {
         case 1: trendCCI = M1_TrendCCI_Period; entryCCI = M1_EntryCCI_Period; break;
         case 5: trendCCI = M5_TrendCCI_Period; entryCCI = M5_EntryCCI_Period; break;
         case 15: trendCCI = M15_TrendCCI_Period; entryCCI = M15_EntryCCI_Period; break;
         case 30: trendCCI = M30_TrendCCI_Period; entryCCI = M30_EntryCCI_Period; break;
         case 60: trendCCI = H1_TrendCCI_Period; entryCCI = H1_EntryCCI_Period; break;
         case 240: trendCCI = H4_TrendCCI_Period; entryCCI = H4_EntryCCI_Period; break;
         case 1440: trendCCI = D1_TrendCCI_Period; entryCCI = D1_EntryCCI_Period; break;
         case 10080: trendCCI = W1_TrendCCI_Period; entryCCI = W1_EntryCCI_Period; break;
         case 43200: trendCCI = MN_TrendCCI_Period; entryCCI = MN_EntryCCI_Period; break;
      }
   }
   else {
      trendCCI = TrendCCI_Period;
      entryCCI = EntryCCI_Period;
   }
      IndicatorShortName("(TrendCCI: " + trendCCI + ", EntryCCI: " + entryCCI + ") ");   
   
   for(i = limit; i >= 0; i--) {
      CCINoTrend[i] = 0;
      CCITrendDown[i] = 0;
      CCITimeBar[i] = 0;
      CCITrendUp[i] = 0;
      ZeroLine[i] = 0;
      TrendCCI[i] = iCCI(NULL, 0, trendCCI, PRICE_TYPICAL, i);
      EntryCCI[i] = iCCI(NULL, 0, entryCCI, PRICE_TYPICAL, i);
      
      if(TrendCCI[i] > 0 && TrendCCI[i+1] < 0) {
         if (trendDown > 4) trendUp = 0;
      }
      if (TrendCCI[i] > 0) {
         if (trendUp < 5){
            CCINoTrend[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp == 5) {
            CCITimeBar[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp > 5) {
            CCITrendUp[i] = TrendCCI[i];
         }
      }
      if(TrendCCI[i] < 0 && TrendCCI[i+1] > 0) {
         if (trendUp > 4) trendDown = 0;
      }
      if (TrendCCI[i] < 0) {
         
         if (trendDown < 5){
            CCINoTrend[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown == 5) {
            CCITimeBar[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown > 5) {
            CCITrendDown[i] = TrendCCI[i];
         }
      }
   }
   
   if (Zero_Cross_Alert == true) {
      if (prevtime == Time[0]) {
         return(0);
      }
      else {
         if(EntryCCI[0] < 0) {
            if((TrendCCI[0] < 0) && (TrendCCI[1] >= 0)) {
               Alert(Symbol(), " M", Period(), " Trend & Entry CCI Have both crossed below zero");
            }
         }
         else if(EntryCCI[0] > 0) {
            if((TrendCCI[0] > 0) && (TrendCCI[1] <= 0)) {
               Alert(Symbol(), " M", Period(), " Trend & Entry CCI Have both crossed above zero");
            }
         }
         prevtime = Time[0];
      }
   }
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+