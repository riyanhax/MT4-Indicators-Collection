//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrSandyBrown
#property indicator_color3 clrSandyBrown
#property indicator_color4 clrSilver
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_level1 30
#property indicator_level2 70
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame     = PERIOD_CURRENT;  // Time frame to use
extern int                PeriodRSI     = 14;              // RSI period
extern ENUM_APPLIED_PRICE Price         = PRICE_TYPICAL;   // Price to use for RSI calculation
extern int                PeriodStoch   = 32;              // Stochastic period
extern int                PeriodSlowing = 3;               // Stochastic smoothing period
extern int                PeriodSignal  = 5;               // Stochastic signal period
extern ENUM_MA_METHOD     MAMode        = MODE_SMA;        // Average method used for stochastic smoothing and signal
extern bool               Interpolate   = true;            // Interpolate ddata in multi time frame mode?
   
//
//
//
//
//

double SK[],SKda[],SKdb[];
double SD[];
double StoRSI[];
double RSI[],cross[];

string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(7);
      SetIndexBuffer(0,SK);
      SetIndexBuffer(1,SKda);
      SetIndexBuffer(2,SKdb);
      SetIndexBuffer(3,SD);
      SetIndexBuffer(4,StoRSI);
      SetIndexBuffer(5,RSI);
      SetIndexBuffer(6,cross);

      //
      //
      //
      //
      //
   
            indicatorFileName = WindowExpertName();
            returnBars        = TimeFrame==-99;
            TimeFrame         = MathMax(TimeFrame,_Period);

      //
      //
      //
      //
      //
   
      IndicatorShortName(timeFrameToString(TimeFrame)+" Stochastic RSI ("+(string)PeriodRSI+","+(string)PeriodStoch+","+(string)PeriodSlowing+","+(string)PeriodSignal+")");
return(0);
}
int deinit() { return(0); }


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
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
          int limit=MathMin(Bars-counted_bars,Bars-1);
          if (returnBars) { SK[0] = limit; return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      if (cross[limit]==-1) CleanPoint(limit,SKda,SKdb);
      for(int i=limit; i>=0; i--)
      {
         RSI[i] = iRSI(NULL,0,PeriodRSI,Price,i);
         double LLV = RSI[ArrayMinimum(RSI,PeriodStoch,i)];
         double HHV = RSI[ArrayMaximum(RSI,PeriodStoch,i)];
         if ((HHV-LLV)!=0)
               StoRSI[i] = 100.0*((RSI[i] - LLV)/(HHV - LLV));
         else  StoRSI[i] = 0;
         SKda[i] = EMPTY_VALUE;
         SKdb[i] = EMPTY_VALUE;
      }   
      for(int i=limit; i>=0; i--) SK[i]=iMAOnArray(StoRSI,0,PeriodSlowing,0,MAMode,i);
      for(int i=limit; i>=0; i--)
      {
         SD[i]=iMAOnArray(SK,0,PeriodSignal,0,MAMode,i);
            if (i<Bars-1) cross[i] = cross[i+1];
            if (SK[i]<SD[i]) cross[i] = -1;
            if (SK[i]>SD[i]) cross[i] =  1;
            if (cross[i]==-1) PlotPoint(i,SKda,SKdb,SK);
      }            
      return(0);      
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for(int i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         SK[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,PeriodRSI,Price,PeriodStoch,PeriodSlowing,PeriodSignal,MAMode,0,y);
         SD[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,PeriodRSI,Price,PeriodStoch,PeriodSlowing,PeriodSignal,MAMode,3,y);
         cross[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,PeriodRSI,Price,PeriodStoch,PeriodSlowing,PeriodSignal,MAMode,6,y);
         SKda[i]  = EMPTY_VALUE;
         SKdb[i]  = EMPTY_VALUE;

         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
         //
         //
         //
         //
         //
                  
         int n,k; datetime time = iTime(NULL,TimeFrame,y);
            for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
            {
               SK[i+k] = SK[i] + (SK[i+n] - SK[i]) * k/n;
               SD[i+k] = SD[i] + (SD[i+n] - SD[i]) * k/n;
            }                           
   }               
   for(int i=limit; i>=0; i--) if (cross[i]==-1) PlotPoint(i,SKda,SKdb,SK);
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

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
         {
            if (first[i+2] == EMPTY_VALUE) 
                  { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
            else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
         }
   else  { first[i] = from[i]; second[i] = EMPTY_VALUE; }
}