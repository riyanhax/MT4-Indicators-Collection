//+------------------------------------------------------------------+
//|                                             NormalizedVolume.mq4 |
//|                         Copyright © Vadim Shumilov (DrShumiloff) |
//|                                                shumiloff@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Vadim Shumilov (DrShumiloff)"
#property link      "shumiloff@mail.ru"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 clrLightSeaGreen

extern int VolumePeriod=9;

double VolBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;

   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VolBuffer);
   SetIndexDrawBegin(0,VolumePeriod);

   short_name="Normalized Volume("+(string)VolumePeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();

   if(counted_bars<1)
      for(int i=1; i<=VolumePeriod; i++)
         VolBuffer[Bars-i]=0.0;
   int limit=Bars-counted_bars;
   if(counted_bars>0)
      limit++;
   else
      limit-=VolumePeriod;

   for(i=0; i<limit; i++)
      VolBuffer[i]=NormalizedVolume(i);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizedVolume(int i)
  {
   double nv=0;

   for(int j=i; j<(i+VolumePeriod); j++)
      nv=nv+Volume[j];
   nv=nv/VolumePeriod;
   return(Volume[i]/nv);
  }
//+------------------------------------------------------------------+
