//+------------------------------------------------------------------+
//|                                                          REI.mq4 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, LeMan"
#property link      "b-market@mail.ru"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_level1 60
#property indicator_level2 -60
//---- Входные параметры
extern int REIPeriod=5;
//---- Буферы
double REIBuffer[];
//+------------------------------------------------------------------+
//| Функция инициализации                                            |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   IndicatorBuffers(1);
   IndicatorShortName("REI ("+REIPeriod+")");
//---- Линии индикатора
   SetIndexBuffer(0,REIBuffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,REIPeriod+9);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SV(int i=0)
  {

   double var1 = High[i] - High[i+2];
   double var2 = Low[i] - Low[i+2];

   if(High[i+2]<Close[i+7] && High[i+2]<Close[i+8] && High[i]<High[i+5] && High[i]<High[i+6])
     {
      int num_zero=0;
        } else {
      num_zero=1;
     }

   if(Low[i+2]>Close[i+7] && Low[i+2]>Close[i+8] && Low[i]>Low[i+5] && Low[i]>Low[i+6])
     {
      int num_zero2=0;
        } else {
      num_zero2=1;
     }

   return((num_zero*num_zero2*var1)+(num_zero*num_zero2*var2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ADV(int i=0)
  {
   double var3 = MathAbs(High[i] - High[i+2]);
   double var4 = MathAbs(Low[i] - Low[i+2]);
   return(var3+var4);
  }
//+------------------------------------------------------------------+
//| Метод Каири                                                      |
//+------------------------------------------------------------------+
int start()
  {
   int i,k;
//----
   if(Bars<=8+REIPeriod) return(0);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+REIPeriod+8;

   for(i=0; i<=limit; i++)
     {
      double sv=0.0;
      double adv=0.0;
      for(k=0; k<REIPeriod; k++)
        {
         adv+=ADV(i+k);
        }
      for(k=0; k<REIPeriod; k++)
        {
         sv+=SV(i+k);
        }
      REIBuffer[i]=(sv/adv)*100;
     }

   return(0);
  }
//+------------------------------------------------------------------+
