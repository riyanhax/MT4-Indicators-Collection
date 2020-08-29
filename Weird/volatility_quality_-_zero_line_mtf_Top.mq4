//+------------------------------------------------------------------+
//|                                           Volatility quality.mq4 |
//|                                                                  |
//|                                                                  |
//| Volatility quality index originaly developed by                  |
//| Thomas Stridsman (August 2002 Active Trader Magazine)            |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers  3
#property indicator_color1   LimeGreen
#property indicator_color2   Red
#property indicator_color3   Red
#property indicator_width1   2
#property indicator_width2   2
#property indicator_width3   2
#property indicator_level1   0
#property indicator_levelcolor DarkGray

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame            = PERIOD_CURRENT;
extern int             PriceSmoothing       = 15;
extern ENUM_MA_METHOD  PriceSmoothingMethod = MODE_LWMA;
extern double          Filter               = 5;
extern bool            Interpolate          = true;

//
//
//
//
//

double sumVqi[];
double sumVqida[];
double sumVqidb[];
double Vqi[];
double trend[];
string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(5);
      SetIndexBuffer(0,sumVqi); 
      SetIndexBuffer(1,sumVqida); 
      SetIndexBuffer(2,sumVqidb); 
      SetIndexBuffer(3,Vqi);   
      SetIndexBuffer(4,trend); 
      
      PriceSmoothing    = MathMax(PriceSmoothing,1);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-99;
      TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+"  Volatility quality zero line ");        
   return(0);
}
int deinit() { return(0); }

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
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { sumVqi[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //
            
   if (TimeFrame == Period())
   {         
      if (trend[limit] == -1) ClearPoint(limit,sumVqida,sumVqidb);
      for(i=limit; i>=0; i--)
      {
         if (i==(Bars-1)) { Vqi[i] = 0; sumVqi[i] = 0; continue; }
      
      //
      //
      //
      //
      //
      
         double cHigh  = iMA(NULL,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_HIGH ,i);
         double cLow   = iMA(NULL,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_LOW  ,i);
         double cOpen  = iMA(NULL,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_OPEN ,i);
         double cClose = iMA(NULL,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_CLOSE,i);
         double pClose = iMA(NULL,0,PriceSmoothing,0,PriceSmoothingMethod,PRICE_CLOSE,i+1);

         double trueRange = MathMax(cHigh,pClose)-MathMin(cLow,pClose);
         double     range = cHigh-cLow;
      
            if (range != 0 && trueRange!=0)
               double vqi = ((cClose-pClose)/trueRange + (cClose-cOpen)/range)*0.5;
            else      vqi = Vqi[i+1];

      //
      //
      //
      //
      //
         
         Vqi[i]      = MathAbs(vqi)*(cClose-pClose+cClose-cOpen)*0.5;
         sumVqi[i]   = Vqi[i];
         sumVqida[i] = EMPTY_VALUE;
         sumVqidb[i] = EMPTY_VALUE;
            if (Filter > 0) if (MathAbs(sumVqi[i]-sumVqi[i+1]) < Filter*Point) sumVqi[i] = sumVqi[i+1];
      
      //
      //
      //
      //
      //
      
      trend[i] = trend[i+1];
         if (sumVqi[i] > 0) trend[i] =  1;
         if (sumVqi[i] < 0) trend[i] = -1;
         if (trend[i] == -1) PlotPoint(i,sumVqida,sumVqidb,sumVqi);
      }
      return(0);
   }      
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         sumVqi[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,PriceSmoothing,PriceSmoothingMethod,Filter,0,y);
         trend[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,PriceSmoothing,PriceSmoothingMethod,Filter,4,y);
         sumVqida[i] = EMPTY_VALUE;
         sumVqidb[i] = EMPTY_VALUE;

         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,TimeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
            for(int k = 1; k < n; k++)
               sumVqi[i+k] = sumVqi[i] + (sumVqi[i+n] - sumVqi[i]) * k/n;
   }
   for(i=limit; i>=0; i--) if (trend[i] == -1) PlotPoint(i,sumVqida,sumVqidb,sumVqi);
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

void ClearPoint(int i,double& first[],double& second[])
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//

string sTfTable[] = { "M1","M5","M15","M30","H1","H4","D1","W1","MN" };
int    iTfTable[] = { 1,5,15,30,60,240,1440,10080,43200 };

string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}