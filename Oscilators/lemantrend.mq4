//+------------------------------------------------------------------+
//|                                                   LeManTrend.mq4 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, LeMan."
#property link      "b-market@mail.ru"
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 SlateBlue
#property indicator_color2 Red
//---- ¬ходные параметры
extern int Min       = 13;
extern int Midle     = 21;
extern int Max       = 34;
extern int PeriodEMA = 3;
extern bool Sound=true;
int Alert_Delay_In_Seconds=0;
int PrevAlertTime=0;
//---- Ѕуферы
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double TempBuffer1[];
double TempBuffer2[];
//---- 
bool gSellAlertGiven = false; // Used to stop constant alerts
bool gBuyAlertGiven = false; // Used to stop constant alerts
//+------------------------------------------------------------------+
int init() {
//----
   IndicatorDigits(Digits);
   IndicatorBuffers(4);
   
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,TempBuffer1);                              
   SetIndexBuffer(3,TempBuffer2);                              

   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE); 
   
   SetIndexDrawBegin(0,Max);           
   SetIndexDrawBegin(1,Max);           
//----
   return(0);
}
//+------------------------------------------------------------------+
int deinit() {
//----  
   
//----
   return(0);
}
//+------------------------------------------------------------------+
int start() {
   double 
   val1,
   val2;
//----
   int i, counted_bars = IndicatorCounted();
//----
   if (Bars <= Max) {
      return(0);
   }
//---- initial zero
   if (counted_bars < 1) {
      for(i=1; i<=Max; i++) {
         ExtMapBuffer1[Bars-i] = 0.0;
         ExtMapBuffer2[Bars-i] = 0.0;
      }
   }
//----
   i = Bars-counted_bars-1;
//----
   while(i >= 0) {
      double High1 = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Min,i+1));
      double High2 = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Midle,i+1));
      double High3 = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Max,i+1));    
      TempBuffer1[i] = ((High[i]-High1)+(High[i]-High2)+(High[i]-High3));
      double Low1 = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Min, i+1));
      double Low2 = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Midle, i+1));
      double Low3 = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Max, i+1));    
      TempBuffer2[i] = ((Low1-Low[i])+(Low2-Low[i])+(Low3-Low[i]));
      i--;
   } 
   if (counted_bars > 0) {
      counted_bars--;
   }
   int limit = Bars-counted_bars;   

   for(i=0; i<limit; i++) {
      if (PeriodEMA > 0 ) 
         ExtMapBuffer1[i] = iMAOnArray(TempBuffer1,Bars,PeriodEMA,0,MODE_EMA,i);
         ExtMapBuffer2[i] = iMAOnArray(TempBuffer2,Bars,PeriodEMA,0,MODE_EMA,i);
         val1 = ExtMapBuffer1[0];
         val2 = ExtMapBuffer2[0];
       if(val1 > val2)
         {
           Comment("покупка buy ", val1);
           if(Sound == true && gBuyAlertGiven == false)
             {
               PlaySound("alert.wav");
               Alert(Symbol() + "__TF- " + Period() + "______BUY_signal");
               gBuyAlertGiven = true;
               gSellAlertGiven = false;
             }
         }
       if(val1 < val2)
         {
           Comment("продажа sell ", val2);
           if(Sound == true && gSellAlertGiven == false)
             {
               PlaySound("alert.wav");
               Alert(Symbol() + "__TF- " + Period() + "______SELL_signal");
               gBuyAlertGiven = false;
               gSellAlertGiven=true;
             }
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+