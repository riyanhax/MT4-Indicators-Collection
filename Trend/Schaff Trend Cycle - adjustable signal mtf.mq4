//+------------------------------------------------------------------+
//|                                           Schaff Trend Cycle.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrSandyBrown
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame    = PERIOD_CURRENT; // Time frame
extern int             STCPeriod    = 10;             // Schaff period
extern int             FastMAPeriod = 23;             // Fast macd period
extern int             SlowMAPeriod = 50;             // Slow macd period
extern double          SignalPeriod = 3;              // Signal period
extern bool            Interpolate  = true;           // Interpolate in multi time frame mode?

double stcBuffer[],stcBufferUA[],stcBufferUB[],macdBuffer[],fastKBuffer[],fastDBuffer[],fastKKBuffer[],slope[],count[];
string indicatorFileName;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(9);
      SetIndexBuffer(0,stcBuffer);
      SetIndexBuffer(1,stcBufferUA);
      SetIndexBuffer(2,stcBufferUB);
      SetIndexBuffer(3,macdBuffer);
      SetIndexBuffer(4,fastKBuffer);
      SetIndexBuffer(5,fastDBuffer);
      SetIndexBuffer(6,fastKKBuffer);
      SetIndexBuffer(7,slope);
      SetIndexBuffer(8,count);
       indicatorFileName = WindowExpertName();
       TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" Schaff Trend Cycle ("+(string)STCPeriod+","+(string)FastMAPeriod+","+(string)SlowMAPeriod+","+(string)SignalPeriod+")");
   return(0);
}

int deinit()
{
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            #define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,STCPeriod,FastMAPeriod,SlowMAPeriod,SignalPeriod,_buff,_y)
            limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(8,0)*TimeFrame/Period()));
            if (slope[limit] == 1) CleanPoint(limit,stcBufferUA,stcBufferUB);
            for(int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  slope[i]       = _mtfCall(7,y);
                  stcBuffer[i]   = _mtfCall(0,y);
                  stcBufferUA[i] = EMPTY_VALUE;
                  stcBufferUB[i] = EMPTY_VALUE;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  #define _interpolate(buff,i,k,n) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(stcBuffer,i,k,n);
               }
               for(int i=limit; i>=0; i--) if (slope[i]==-1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
               return(0);
         }
         
   //
   //
   //
   //
   //
   
   double alpha = 2.0/(1.0+SignalPeriod);
   if (slope[limit] == 1) CleanPoint(limit,stcBufferUA,stcBufferUB);
      for(int i = limit; i >= 0 && !_StopFlag; i--)
      {
         macdBuffer[i] = iMA(NULL,0,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);

            //
            //
            //
            //
            //
      
            double lowMacd  = macdBuffer[ArrayMinimum(macdBuffer,STCPeriod,i)];
            double highMacd = macdBuffer[ArrayMaximum(macdBuffer,STCPeriod,i)]-lowMacd;
                              fastKBuffer[i] = (highMacd > 0) ? 100*((macdBuffer[i]-lowMacd)/highMacd) : (i<Bars-1) ? fastKBuffer[i+1] : 0;
                              fastDBuffer[i] = (i<Bars-1) ? fastDBuffer[i+1]+alpha*(fastKBuffer[i]-fastDBuffer[i+1]) : fastKBuffer[i];
               
            double lowStoch  = fastDBuffer[ArrayMinimum(fastDBuffer,STCPeriod,i)];
            double highStoch = fastDBuffer[ArrayMaximum(fastDBuffer,STCPeriod,i)]-lowStoch;
                               fastKKBuffer[i] = (highStoch > 0) ? 100*((fastDBuffer[i]-lowStoch)/highStoch) : (i<Bars-1) ? fastKKBuffer[i+1] : 0;
                               stcBuffer[i]    = (i<Bars-1) ? stcBuffer[i+1]+alpha*(fastKKBuffer[i]-stcBuffer[i+1]) : fastKKBuffer[i];
                               stcBufferUA[i]  = EMPTY_VALUE;
                               stcBufferUB[i]  = EMPTY_VALUE;
                               slope[i]        = (i<Bars-1) ? (stcBuffer[i] > stcBuffer[i+1]) ? 1 : (stcBuffer[i] < stcBuffer[i+1]) ? -1 : slope[i+1] : 0;
            if (slope[i]==-1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
      }   
   return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}