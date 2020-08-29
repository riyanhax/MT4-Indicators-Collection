//+--------------------------------------------------------------------------------------+
//|                                                                                      |
//+--------------------------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1  DimGray
#property indicator_color2  DeepSkyBlue
#property indicator_color3  PaleVioletRed
#property indicator_color4  DeepSkyBlue
#property indicator_color5  PaleVioletRed
#property indicator_color6  PaleVioletRed
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_style1 STYLE_DOT

#import "libSSA.dll"
   void fastSingular(double& sourceArray[],int arraySize, int lag, int numberOfComputationLoops, double& destinationArray[]);
#import

//
//
//
//
//

extern int    SSAPrice                =  PRICE_CLOSE;
extern int    SSALag                  = 25;
extern int    SSANumberOfComputations =  2;
extern int    SSAPeriodNormalization  = 10;
extern int    SSANumberOfBars         = 300;
extern int    FirstBar                = 400; 
extern bool   MultiColor              = true;
extern double alertsLevel             = 0.25;
extern bool   alertsOn                = false;
extern bool   alertsOnCurrent         = true;
extern bool   alertsMessage           = true;
extern bool   alertsSound             = false;
extern bool   alertsEmail             = false;

//
//
//
//
//

double in[];
double inDa[];
double inDb[];
double inDotu[];
double inDotd[];
double ssaCurrent[];
double no[];
double ssaIn[];
double ssaOut[];

//+--------------------------------------------------------------------------------------+
//|                                                                                      |
//+--------------------------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,ssaCurrent);
      SetIndexBuffer(1,inDotu); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159);
      SetIndexBuffer(2,inDotd); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,159);
      SetIndexBuffer(3,in);
      SetIndexBuffer(4,inDa);
      SetIndexBuffer(5,inDb);
      SetIndexBuffer(6,no);
         SetLevelValue(0, alertsLevel);
         SetLevelValue(1,-alertsLevel);
         SetLevelValue(2,           0);
   IndicatorShortName("SSA normalized end-pointed");
   return(0);
}
int deinit(){return(0);}

//+--------------------------------------------------------------------------------------+
//|                                                                                      |
//+--------------------------------------------------------------------------------------+
//
//
//
//
//

double trend[];
double slope[];

int start()
{
   int i,r,limit,counted_bars = IndicatorCounted();

      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(trend,0)!=Bars)
            {
               ArrayResize(trend,Bars);
               ArrayResize(slope,Bars);
            }

   //
   //
   //
   //
   //
      
   if (MultiColor && slope[Bars-limit-1]==-1) CleanPoint(limit,inDa,inDb);
   for(i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      double ma    = iMA(NULL,0,SSAPeriodNormalization,0,MODE_SMA,SSAPrice,i);
      double dev   = iStdDev(NULL,0,SSAPeriodNormalization,0,MODE_SMA,SSAPrice,i)*3.0;
      double price = iMA(NULL,0,1,0,MODE_SMA,SSAPrice,i);
             no[i] = (price-ma)/(MathMax(dev,0.000001));
            
         //
         //
         //
         //
         //
 
         trend[r] = trend[r-1];
         slope[r] = slope[r-1];
         if (i<=FirstBar)
         {
            int ssaBars = MathMin(Bars-i,SSANumberOfBars);
            if (ssaBars<SSALag) continue;
               if (ArraySize(ssaIn) != ssaBars)
               {
                  ArrayResize(ssaIn ,ssaBars);
                  ArrayResize(ssaOut,ssaBars);
               }
               ArrayCopy(ssaIn,no,0,i,ssaBars);
 
            fastSingular(ssaIn,ssaBars,SSALag,SSANumberOfComputations,ssaOut);
            in[i]     = ssaOut[0];
            inDa[i]   = EMPTY_VALUE;
            inDb[i]   = EMPTY_VALUE;
            inDotu[i] = EMPTY_VALUE;
            inDotd[i] = EMPTY_VALUE;

            //
            //
            //
            //
            //
            
            if (in[i]> alertsLevel)                      trend[r] =  1;
            if (in[i]<-alertsLevel)                      trend[r] = -1;
            if (in[i]>-alertsLevel && in[i]<alertsLevel) trend[r] =  0;
            if (in[i]>in[i+1])                           slope[r] =  1;
            if (in[i]<in[i+1])                           slope[r] = -1;
            if (trend[r] != trend[r-1])
            {
               if (in[i]>0)
                  if (trend[r]==1)
                        inDotu[i] = alertsLevel;
                  else  inDotd[i] = alertsLevel;
               if (in[i]<0)
                  if (trend[r]==-1)
                        inDotd[i] = -alertsLevel;
                  else  inDotu[i] = -alertsLevel;
            }               
            if (MultiColor && slope[r]==-1) PlotPoint(i,inDa,inDb,in);
         }                   
   }

   //
   //
   //
   //
   //
   
   ArrayCopy(ssaCurrent,ssaOut);

   //
   //
   //
   //
   //

   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = Bars-whichBar-1;
      if (trend[whichBar] != trend[whichBar-1])
      {
         if (trend[whichBar]   == 1)                        doAlert("level "+DoubleToStr( alertsLevel,2)+" crossed up");
         if (trend[whichBar]   ==-1)                        doAlert("level "+DoubleToStr(-alertsLevel,2)+" crossed down");
         if (trend[whichBar-1] == 1 && trend[whichBar]!= 1) doAlert("level "+DoubleToStr( alertsLevel,2)+" crossed down");
         if (trend[whichBar-1] ==-1 && trend[whichBar]!=-1) doAlert("level "+DoubleToStr(-alertsLevel,2)+" crossed up");
      }         
   }
   
   //
   //
   //
   //
   //
   
   SetIndexDrawBegin(0,Bars-ssaBars);
   return(0); 
}


//+--------------------------------------------------------------------------------------+
//|                                                                                      |
//+--------------------------------------------------------------------------------------+
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," normalized end-point SSA ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," normalized end-point SSA "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}