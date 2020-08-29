//+------------------------------------------------------------------+
//|                                          marney volume indicator |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DimGray
#property indicator_color2  SteelBlue
#property indicator_color3  PaleVioletRed
#property indicator_color4  PaleVioletRed
#property indicator_color5  Red
#property indicator_width4  3
#property indicator_width5  2
#property indicator_minimum 0

//
//
//
//
//

extern int AveragePeriod = 10;

//
//
//
//
//

double volumeN[];
double volumeU[];
double volumeD[];
double volumeA[];
double volumeF[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   SetIndexBuffer(0,volumeN);  SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,volumeU);  SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,volumeD);  SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,volumeA);
   SetIndexBuffer(4,volumeF);  SetIndexShift(4,PERIOD_D1/Period());

   IndicatorShortName("MVI ("+AveragePeriod+")");
   return(0);
}

int deinit()
{
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int i,k,limit,counted_bars=IndicatorCounted();

   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
      limit = Bars-counted_bars;

   //
   //
   //
   //
   //

   for (i=limit; i>=0; i--)
   {
      volumeN[i] = Volume[i];
      volumeU[i] = EMPTY_VALUE; if (Close[i]>Open[i]) volumeU[i] = volumeN[i];
      volumeD[i] = EMPTY_VALUE; if (Close[i]<Open[i]) volumeD[i] = volumeN[i];
      volumeF[i] = EMPTY_VALUE;      
      volumeA[i] = 0;
      
      //
      //
      //
      //
      //
      
         if (Period()>=PERIOD_D1)
         {
            for (k=1; k<=AveragePeriod && (i+k)<Bars; k++) volumeA[i] += Volume[i+k];
                                                           volumeA[i] /= k;
         }
         else
         {
            datetime searchTime = Time[i]-1440*60; k = 0;
            while (k<AveragePeriod && Time[Bars-1]<=searchTime)
            {
               int bar = iBarShift(NULL,0,searchTime,true);
               if (bar>-1)
               {
                  volumeA[i] += Volume[bar]; k++;
               }                  
               searchTime -= 1440*60;
            }
            volumeA[i] /= MathMax(k,1);
         }            
   }
   
   //
   //
   //
   //
   //
   
   if (Period()<PERIOD_D1)
   {
      int shift = PERIOD_D1/Period();
      for (i=0; i<=shift; i++)
      {
         datetime futureTime = Time[0]+i*Period()*60;
         if (TimeDayOfWeek(futureTime) == 6 || TimeDayOfWeek(futureTime) == 0) continue;
         
         //
         //
         //
         //
         //
         
         volumeF[shift-i] = 0;
         searchTime = futureTime-1440*60; k = 0;
         while (k<AveragePeriod && Time[Bars-1]<=searchTime)
         {
            bar = iBarShift(NULL,0,searchTime,true);
            if (bar>-1)
            {
               volumeF[shift-i] += Volume[bar]; k++;
            }                  
            searchTime -= 1440*60;
         }
         volumeF[shift-i] /= MathMax(k,1);
      }
      SetIndexDrawBegin(4,Bars-shift-1);
   }
   return(0);
}