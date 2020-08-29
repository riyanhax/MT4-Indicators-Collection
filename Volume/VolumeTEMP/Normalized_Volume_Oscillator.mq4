//+------------------------------------------------------------------+
//|                                 Normalized Volume Oscillator.mq4 |
//|                                                  Vadim Shumiloff |
//|                                                shumiloff@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Vadim Shumiloff"
#property link      "shumiloff@mail.ru"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue   // Закраска отрицательных баров
#property indicator_color2 Green       // Закраска баров 0 - 38.2
#property indicator_color3 Lime        // Закраска баров 38.2 - 61.8
#property indicator_color4 Yellow      // Закраска баров 61.8 - 100
#property indicator_color5 White       // Закраска баров свыше 100

#property indicator_width1 2  
#property indicator_width2 2  
#property indicator_width3 2  
#property indicator_width4 2  
#property indicator_width5 2  

extern int VolumePeriod=10;

double VolBufferH1[];
double VolBufferH2[];
double VolBufferH3[];
double VolBufferH4[];
double VolBufferH5[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;

   IndicatorBuffers(5);

   SetIndexBuffer(0,VolBufferH1);
   SetIndexBuffer(1,VolBufferH2);
   SetIndexBuffer(2,VolBufferH3);
   SetIndexBuffer(3,VolBufferH4);
   SetIndexBuffer(4,VolBufferH5);

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_HISTOGRAM);

   short_name="NVO ("+VolumePeriod+")";
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
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+VolumePeriod;

   double nvo=0;

   for(int i=0; i<limit; i++)
     {
      VolBufferH1[i] = 0;
      VolBufferH2[i] = 0;
      VolBufferH3[i] = 0;
      VolBufferH4[i] = 0;
      VolBufferH5[i] = 0;

      nvo=NormalizedVolume(i)*100-100;

      if(nvo<0)
        {
         VolBufferH1[i]=nvo;
        }
      else
        {
         if(nvo<38.2)
           {
            VolBufferH2[i]=nvo;
           }
         else
           {
            if(nvo<61.8)
              {
               VolBufferH3[i]=nvo;
              }
            else
              {
               if(nvo<100)
                 {
                  VolBufferH4[i]=nvo;
                 }
               else VolBufferH5[i]=nvo;
              }
           }
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizedVolume(int i)
  {
   double nv = 0;
   for(int j = i; j < (i+VolumePeriod); j++) nv = nv + Volume[j];
   nv=nv/VolumePeriod;
   return(Volume[i]/nv);
  }
//+------------------------------------------------------------------+
