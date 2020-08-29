//+------------------------------------------------------------------+
//|                                              cm-Volume-Level.mq4 |
//|                              Copyright © 2012, Khlystov Vladimir |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, cmillion@narod.ru"
#property link      "http://cmillion.narod.ru"
#property indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red
//--------------------------------------------------------------------
extern datetime TimeStart = D'2012.04.01 00:00'; //Время старта анализа
double BufferS[];
double BufferK[];
double Vol[1440],VolN[1440];
//--------------------------------------------------------------------
int init()
{
   IndicatorBuffers(2);

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0, BufferS);

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, BufferK);

   SetIndexLabel(0, "volume ");
   
   ArrayInitialize(Vol,0);
   ArrayInitialize(VolN,0);
   ArrayInitialize(BufferK,0);
   int limit=iBarShift(NULL,0,TimeStart,false);
   for(int i=0; i<limit; i++)
   {
      BufferS[i]=Volume[i];
      int n = N(Time[i]);
      Vol[n]+=Volume[i];
      VolN[n]++;
   }
   for(i=0; i<1440/Period(); i++)
   {
      Vol[i] = Vol[i]/VolN[i];
   }
   for(i=0; i<limit; i++)
   {
      n = N(Time[i]);
      BufferK[i]=Vol[n];
   }
   WindowRedraw();
   return;
}   
//--------------------------------------------------------------------
int start()                                  
{
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
   {
      BufferS[i]=Volume[i];
   }
   return;
}
//---------------------------------------------------------------------
int N(datetime T)                                  
{
   int h=TimeHour(T); 
   int m=TimeMinute(T);
   switch(Period())
   {
      case 1:
         return(60*h+m);
      case 5:
         if (m<5)  return(12*h);
         if (m<10) return(12*h+1);
         if (m<15) return(12*h+2);
         if (m<20) return(12*h+3);
         if (m<25) return(12*h+4);
         if (m<30) return(12*h+5);
         if (m<35) return(12*h+6);
         if (m<40) return(12*h+7);
         if (m<45) return(12*h+8);
         if (m<50) return(12*h+9);
         if (m<55) return(12*h+10);
         return(12*h+11);
      case 15:
         if (m<15) return(4*h+0);
         if (m<30) return(4*h+1);
         if (m<45) return(4*h+2);
         return(4*h+3);
      case 30:
         if (m<30) return(2*h);
         return(2*h+1);
      case 60:
         return(h);
   }
   return(0);
}
//---------------------------------------------------------------------

