//+------------------------------------------------------------------+
//|   BetterVolumeTicks.mq4
//+------------------------------------------------------------------+
#property indicator_separate_window
#include <stdlib.mqh>
#property indicator_buffers 7
#property indicator_color1  Red
#property indicator_color2  DarkGray
#property indicator_color3  Yellow
#property indicator_color4  Lime
#property indicator_color5  White
#property indicator_color6  Magenta
#property indicator_color7  Maroon
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2

//
//
//
//
//

extern int VolPeriod    = 15;
extern int VolAvgMethod = MODE_LWMA;
extern int LookBack     = 7;

//
//
//
//
//

double MyPoint;
double ClimaxHi[];
double Neutral[];
double LoVolume[];
double Churn[];
double ClimaxLo[];
double ClimaxChurn[];
double AvgVol[];
double UpTicks[];
double DnTicks[];
double VolRange[];
double VolSort[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int init()
{
   ArraySetAsSeries(UpTicks,true);
   ArraySetAsSeries(DnTicks,true);
   ArraySetAsSeries(VolRange,true);
   ArraySetAsSeries(VolSort,true);

   IndicatorBuffers(7);
   SetIndexBuffer(0,ClimaxHi);   SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"ClimaxHi");
   SetIndexBuffer(1,Neutral);    SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"Neutral");
   SetIndexBuffer(2,LoVolume);   SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexLabel(2,"LoVolume");
   SetIndexBuffer(3,Churn);      SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexLabel(3,"Churn");
   SetIndexBuffer(4,ClimaxLo);   SetIndexStyle(4,DRAW_HISTOGRAM); SetIndexLabel(4,"ClimaxLo");
   SetIndexBuffer(5,ClimaxChurn);SetIndexStyle(5,DRAW_HISTOGRAM); SetIndexLabel(5,"ClimaxChurn");
   SetIndexBuffer(6,AvgVol);                                      SetIndexLabel(6,"AvgVolume");

   IndicatorShortName("Better Volume Ticks" );
      
	if (Digits == 5 || (Digits == 3 && StringFind(Symbol(), "JPY") != -1)) { MyPoint = Point*10; }
	else
	if (Digits == 6 || (Digits == 4 && StringFind(Symbol(), "JPY") != -1)) { MyPoint = Point*100;}
	else                                                                   { MyPoint = Point;    }
return(0);
}

//
//
//
//
//

int deinit() { return(0); }

//
//
//
//
//

int start()
{
   int count,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for(int i = limit; i >= 0; i--)
   {
      ResizeArrays();
      VolSort[i] = Volume[i];
      AvgVol[i]  = NormalizeDouble(iMAOnArray(VolSort,0,VolPeriod,0,VolAvgMethod,i),0);
   }   

   for(i = limit; i >= 0; i--)
   {
      double Range   = High[i]-Low[i];
      double CountUp = (Volume[i]+(Close[i]-Open[i])/MyPoint)*0.5;
      double CountDn = Volume[i]-UpTicks[i];

      UpTicks[i] = CountUp*Range;
      DnTicks[i] = CountDn*Range;
      
      if (!CompareDoubles(Range,0))
      {VolRange[i] = Volume[i]/Range;}
      
      double LoVol = Volume[iLowest(NULL, 0,MODE_VOLUME,LookBack,i)];
      double HiVol = Volume[iHighest(NULL,0,MODE_VOLUME,LookBack,i)];

      double HiUpTick = UpTicks[FindMaxUp(i)];
      double HiDnTick = DnTicks[FindMaxDn(i)];
      double MaxVol   = VolRange[FindMaxVol(i)];
      
      Neutral[i]     = NormalizeDouble(Volume[i],0);
      ClimaxHi[i]    = EMPTY_VALUE;      
      ClimaxLo[i]    = EMPTY_VALUE;      
      Churn[i]       = EMPTY_VALUE;      
      LoVolume[i]    = EMPTY_VALUE;      
      ClimaxChurn[i] = EMPTY_VALUE;      
      
      if (CompareDoubles(Volume[i],LoVol))
      {
         LoVolume[i] = NormalizeDouble(Volume[i],0);
         Neutral[i]  = EMPTY_VALUE;
      }

      if (CompareDoubles(VolRange[i],MaxVol))
      {
         Churn[i]    = NormalizeDouble(Volume[i],0);                
         Neutral[i]  = EMPTY_VALUE;
         LoVolume[i] = EMPTY_VALUE;
      }

      if (CompareDoubles(UpTicks[i],HiUpTick) && Close[i] >= (High[i]+Low[i])*0.5)
      {

         ClimaxHi[i] = NormalizeDouble(Volume[i],0);
         Neutral[i]  = EMPTY_VALUE;
         LoVolume[i] = EMPTY_VALUE;
         Churn[i]    = EMPTY_VALUE;
      }   
         
      if (CompareDoubles(DnTicks[i],HiDnTick) && Close[i] <= (High[i]+Low[i])*0.5)
      {
         ClimaxLo[i] = NormalizeDouble(Volume[i],0);
         Neutral[i]  = EMPTY_VALUE;
         LoVolume[i] = EMPTY_VALUE;
         Churn[i]    = EMPTY_VALUE;
      }   
         
      if (CompareDoubles(VolRange[i],MaxVol) && (ClimaxHi[i] < EMPTY_VALUE || ClimaxLo[i] < EMPTY_VALUE))
      {
         ClimaxChurn[i] = NormalizeDouble(Volume[i],0);
         ClimaxHi[i]    = EMPTY_VALUE;
         ClimaxLo[i]    = EMPTY_VALUE;
         Churn[i]       = EMPTY_VALUE;
         Neutral[i]     = EMPTY_VALUE;
      }
   }

return(0);
}

//
//
//
//
//

int FindMaxUp(int i)      
{
   int x,y;
   double max=0;
   for(x=LookBack-1;x>=0;x--)
   {
      if(UpTicks[i+x] > max)
      {
         y = i+x;
         max = UpTicks[y];
      }
   }
   return(y);
}

//
//
//
//
//

int FindMaxDn(int i)      
{
   int x,y;
   double max=0;
   for(x=LookBack-1;x>=0;x--)
   {
      if(DnTicks[i+x] > max)
      {
         y = i+x;
         max = DnTicks[y];
      }
   }
   return(y);
}

//
//
//
//
//

int FindMaxVol(int i)      
{
   int x,y;
   double max=0;
   for(x=LookBack-1;x>=0;x--)
   {
      if(VolRange[i+x] > max)
      {
         y = i+x;
         max = VolRange[y];
      }
   }
   return(y);
}

//
//
//
//
//

void ResizeArrays()
{
   ArrayResize(UpTicks,Bars);
   ArrayResize(DnTicks,Bars);
   ArrayResize(VolRange,Bars);
   ArrayResize(VolSort,Bars);
}
//+------------------------------------------------------------------+
         