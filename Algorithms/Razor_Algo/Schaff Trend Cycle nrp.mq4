//+------------------------------------------------------------------+
//|                                           Schaff Trend Cycle.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Red
#property indicator_color2  Green
#property indicator_color3  Green

//
//
//
//
//

extern int STCPeriod    = 10;
extern int FastMAPeriod = 23;
extern int SlowMAPeriod = 50;

//
//
//
//
//

double stcBuffer[];
double stcBufferUA[];
double stcBufferUB[];
double macdBuffer[];
double fastKBuffer[];
double fastDBuffer[];
double fastKKBuffer[];
double trend[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(8);
      SetIndexBuffer(0,stcBuffer);
      SetIndexBuffer(1,stcBufferUA);
      SetIndexBuffer(2,stcBufferUB);
      SetIndexBuffer(3,macdBuffer);
      SetIndexBuffer(4,fastKBuffer);
      SetIndexBuffer(5,fastDBuffer);
      SetIndexBuffer(6,fastKKBuffer);
      SetIndexBuffer(7,trend);
   IndicatorShortName("Schaff Trend Cycle ("+STCPeriod+","+FastMAPeriod+","+SlowMAPeriod+")");
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
   int      counted_bars=IndicatorCounted();
   int      limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (trend[limit]==1) CleanPoint(limit,stcBufferUA,stcBufferUB);

   //
   //
   //
   //
   //
   
   for(i = limit; i >= 0; i--)
   {
      macdBuffer[i] = iMA(NULL,0,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i)-
                      iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);

      //
      //
      //
      //
      //
      
      double lowMacd  = minValue(macdBuffer,i);
      double highMacd = maxValue(macdBuffer,i)-lowMacd;
         if (highMacd > 0)
               fastKBuffer[i] = 100*((macdBuffer[i]-lowMacd)/highMacd);
         else  fastKBuffer[i] = fastKBuffer[i+1];
               fastDBuffer[i] = fastDBuffer[i+1]+0.5*(fastKBuffer[i]-fastDBuffer[i+1]);
               
      //
      //
      //
      //
      //
                     
      double lowStoch  = minValue(fastDBuffer,i);
      double highStoch = maxValue(fastDBuffer,i)-lowStoch;
         if (highStoch > 0)
               fastKKBuffer[i] = 100*((fastDBuffer[i]-lowStoch)/highStoch);
         else  fastKKBuffer[i] = fastKKBuffer[i+1];
               stcBuffer[i]    = stcBuffer[i+1]+0.5*(fastKKBuffer[i]-stcBuffer[i+1]);
      
         //
         //
         //
         //
         //

         trend[i]       = trend[i+1];      
         stcBufferUA[i] = EMPTY_VALUE;
         stcBufferUB[i] = EMPTY_VALUE;
            if (stcBuffer[i] > stcBuffer[i+1]) trend[i] = 1;
            if (stcBuffer[i] < stcBuffer[i+1]) trend[i] =-1;
            if (trend[i] == 1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
   }   
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

double minValue(double& array[],int shift)
{
   double minValue = array[shift];
            for (int i=1; i<STCPeriod; i++) minValue = MathMin(minValue,array[shift+i]);
   return(minValue);
}
double maxValue(double& array[],int shift)
{
   double maxValue = array[shift];
            for (int i=1; i<STCPeriod; i++) maxValue = MathMax(maxValue,array[shift+i]);
   return(maxValue);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
      if (first[i+2] == EMPTY_VALUE) {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}