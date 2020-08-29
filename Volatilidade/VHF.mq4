//+------------------------------------------------------------------+
//|                                                          VHF.mq4 |
//|                                          Copyright © 2009, LeMan |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, LeMan"
#property link      "b-market@mail.ru"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
//----
extern int N=28;
//----
double VHFBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   IndicatorBuffers(2);
//----   
   SetIndexBuffer(0,VHFBuffer);
   SetIndexBuffer(1,TempBuffer);
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
//----   
   SetIndexDrawBegin(0,N+1);
//----
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
//----
   int i,k;
//---- 
   if(N<=1) return(0);
   if(Bars<=N) return(0);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2+N;

//----
   for(i=0; i<limit; i++)
     {
      TempBuffer[i]=MathAbs(Close[i]-Close[i+1]);
     }

   i=limit;
   while(i>=0)
     {
      double hh = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, N, i));
      double ll = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, N, i));
      double a = hh-ll;
      double b = 0.0;
      k=i+N-1;
      while(k>=i)
        {
         b+=TempBuffer[k];
         k--;
        }
      VHFBuffer[i]=a/b;
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
