//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrSandyBrown
#property indicator_color5  clrGray
#property indicator_color6  clrDarkOrange
#property indicator_color7  clrDodgerBlue
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property strict

//
//
//
//
//

enum enCalcType
{
   st_std, // Use standard deviation 
   st_ste, // Use standard error
   st_sam, // Custom strandard deviation - with sample correction
   st_nos  // Custom strandard deviation - without sample correction
   
};
extern ENUM_TIMEFRAMES    TimeFrame        = PERIOD_CURRENT;   // Time frame
extern string             ForSymbol        = "";               // Symbol to use (leave empty for current symbol)
extern int                LRPrd            = 20;               // Linear regression Period
extern int                bolPrd           = 20;               // Bollinger Bands Period
extern ENUM_MA_METHOD     bolMaMode        = MODE_SMA;         // Bollinger Average method
extern double             bolDev           = 2.0;              // Bollinger Bands Deviation
extern enCalcType         bolDevType       = st_std;           // Deviation calculation type
extern int                keltPrd          = 20;               // Keltner Period
extern double             keltFactor       = 1.5;              // Keltner Spacing between bands
extern ENUM_APPLIED_PRICE AppliedPrice     = PRICE_CLOSE;      // Price to use
extern bool               alertsOn         = true;             // Turn alerts on?
extern bool               alertsOnCurrent  = false;            // Alerts on current (still opened) bar?
extern bool               alertsOnHisto    = true;             // Alerts on Histo color change
extern bool               alertsOnSqueeze  = true;             // Alerts on squeeze
extern bool               alertsMessage    = true;             // Alerts showing a pop-up message?
extern bool               alertsPushNotif  = false;            // Alerts sending a push notification?
extern bool               alertsSound      = false;            // Alerts playing sound?
extern bool               alertsEmail      = false;            // Alerts sending email?
extern string             soundFile        = "alert2.wav";     // Alerts Sound File to use
extern bool               Interpolate      = true;             // Interpolate in multi time frame mode?


double lrhuu[],lrhud[],lrhdd[],lrhdu[],d[],colors[],upK[],dnK[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",LRPrd,bolPrd,bolMaMode,bolDev,bolDevType,keltPrd,keltFactor,AppliedPrice,alertsOn,alertsOnCurrent,alertsOnHisto,alertsOnSqueeze,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,soundFile,_buff,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
   for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(10);
   SetIndexBuffer(0, lrhuu); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1, lrhdd); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2, lrhud); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3, lrhdu); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4, d); 
   SetIndexBuffer(5, upK);   SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,159);
   SetIndexBuffer(6, dnK);   SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159);
   SetIndexBuffer(7, trend);
   SetIndexBuffer(8, colors);
   SetIndexBuffer(9, count);
        indicatorFileName = WindowExpertName();
        TimeFrame         = MathMax(TimeFrame,_Period);  
        ForSymbol         = (ForSymbol=="") ? _Symbol : ForSymbol; 
   IndicatorShortName(timeFrameToString(TimeFrame)+" "+ForSymbol+" bbsqueeze("+(string)LRPrd+")");
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
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period || ForSymbol!=_Symbol)
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(9,0)*TimeFrame/_Period));
               for (int i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(ForSymbol,TimeFrame,Time[i]);
                     d[i]      = _mtfCall(4,y);
                     lrhuu[i]  = EMPTY_VALUE;
                     lrhud[i]  = EMPTY_VALUE;
                     lrhdd[i]  = EMPTY_VALUE;
                     lrhdu[i]  = EMPTY_VALUE;
                     upK[i]    = EMPTY_VALUE;
                     dnK[i]    = EMPTY_VALUE;
                     trend[i]  = _mtfCall(7,y);
                     colors[i] = _mtfCall(8,y);
                     
                     if (!Interpolate || (i>0 && y==iBarShift(ForSymbol,TimeFrame,Time[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           _interpolate(d);
               }
               for (int i=limit;i>=0; i--)
               {
                  if (trend[i] == 1) upK[i] = 0;
                  if (trend[i] ==-1) dnK[i] = 0;
                     
                  if (d[i]>0)
                  if (colors[i]==1)
                        lrhuu[i] = d[i];
                  else  lrhud[i] = d[i];
                  if (d[i]<0)
                  if (colors[i]==1)
                        lrhdu[i] = d[i];
                  else  lrhdd[i] = d[i];       
               }
               return(0);
            }               
         
   //
   //
   //
   //
   //
   
   for (int i=limit; i>=0; i--)
   {
       double std=0;
         switch (bolDevType)
         {
            case st_std : std = iStdDev(NULL,0,bolPrd,0,(int)bolMaMode,AppliedPrice,i); break;
            case st_ste : std = iStdError(iMA(NULL,0,1,0,0,AppliedPrice,i), bolPrd,i);  break;
            default :     std = iDeviation(iMA(NULL,0,1,0,0,AppliedPrice,i),bolPrd,bolDevType==st_sam,i);
         }            
         double dt = iMA(NULL,0,bolPrd,0,(int)bolMaMode,AppliedPrice,i);           
         d[i]      = LinearRegressionSlope(LRPrd,i);
            double atr    = iATR(NULL,0,keltPrd,i);
               double UpMa   = dt + std*bolDev;
               double DnMa   = dt - std*bolDev;
               double keltUp = dt + keltFactor*atr;
               double keltDn = dt - keltFactor*atr;
                  trend[i]  = (i<Bars-1) ? (UpMa<keltUp&&DnMa>keltDn) ? 1 : (UpMa>keltUp&&DnMa<keltDn) ? -1 : trend[i+1]  : 0; 
                  colors[i] = (i<Bars-1) ? (d[i]>d[i+1])              ? 1 : (d[i]<d[i+1])              ? -1 : colors[i+1] : 0; 
                  lrhuu[i]  = EMPTY_VALUE;
                  lrhud[i]  = EMPTY_VALUE;
                  lrhdd[i]  = EMPTY_VALUE;
                  lrhdu[i]  = EMPTY_VALUE;
                  upK[i]    = EMPTY_VALUE;
                  dnK[i]    = EMPTY_VALUE;

                  if (trend[i] == 1) upK[i] = 0;
                  if (trend[i] ==-1) dnK[i] = 0;
                     
                  if (d[i]>0)
                  if (colors[i]==1)
                        lrhuu[i] = d[i];
                  else  lrhud[i] = d[i];
                  if (d[i]<0)
                  if (colors[i]==1)
                        lrhdu[i] = d[i];
                  else  lrhdd[i] = d[i];       
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnHisto)
      {
         if (lrhdu[whichBar+1] == EMPTY_VALUE && lrhdu[whichBar] != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"weak buy");
         if (lrhuu[whichBar+1] == EMPTY_VALUE && lrhuu[whichBar] != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"strong buy");
         if (lrhud[whichBar+1] == EMPTY_VALUE && lrhud[whichBar] != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"weak sell");
         if (lrhdd[whichBar+1] == EMPTY_VALUE && lrhdd[whichBar] != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"strong sell");  
      }         
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnSqueeze && trend[whichBar] != trend[whichBar+1])
      {
           if (trend[whichBar] ==  1 ) doAlert(time2,mess2,whichBar,"squeeze");
           if (trend[whichBar] == -1 ) doAlert(time2,mess2,whichBar,"breaking out");
      }         
      
    }         
return(0);
}

//---------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------
//
//
//
//
//

int    lrsperiod=EMPTY_VALUE;
double lrssumX;
double lrssumXSqr;
double lrsdivisor;
double LinearRegressionSlope(int len,int shift)
{
   double LinearRegSlope;
   double SumXY = 0;
   double SumY  = 0;

   //
   //
   //
   //
   //

   if (lrsperiod != len)
   {
      lrsperiod  = len;
      lrssumX    = lrsperiod * (lrsperiod-1) / 2;
      lrssumXSqr = lrsperiod * (lrsperiod-1) * (2 * lrsperiod - 1) / 6;
      lrsdivisor = MathPow(lrssumX,2) - lrsperiod * lrssumXSqr;
   }

   //
   //
   //
   //
   //

   for (int i=0; i<lrsperiod; i++)
   {
      double price = iMA(NULL,0,1,0,MODE_EMA,AppliedPrice,i+shift);
            SumXY += i*price;
            SumY  +=   price;
   }
   if( lrsdivisor != 0 ) 
         	LinearRegSlope = (lrsperiod * SumXY - lrssumX * SumY)/lrsdivisor;
   else     LinearRegSlope = 0; 
   return  (LinearRegSlope);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
// 
//
//
//
//

#define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double value, int length, bool isSample, int i, int instanceNo=0)
{
   if (ArrayRange(workDev,0)!=Bars) ArrayResize(workDev,Bars); i=Bars-i-1; workDev[i][instanceNo] = value;
                 
   //
   //
   //
   //
   //
   
      double oldMean   = value;
      double newMean   = value;
      double squares   = 0; int k;
      for (k=1; k<length && (i-k)>=0; k++)
      {
         newMean  = (workDev[i-k][instanceNo]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k][instanceNo]-oldMean)*(workDev[i-k][instanceNo]-newMean);
         oldMean  = newMean;
      }
      return(MathSqrt(squares/MathMax(k-isSample,1)));
}

//
//
//
//
//

double workErr[][_devInstances];
double iStdError(double value, int length,int i, int instanceNo=0)
{
   if (ArrayRange(workErr,0)!=Bars) ArrayResize(workErr,Bars); i = Bars-i-1; workErr[i][instanceNo] = value;
                        
      //
      //
      //
      //
      //
                              
      double avgY     = workErr[i][instanceNo]; int j; for (j=1; j<length && (i-j)>=0; j++) avgY += workErr[i-j][instanceNo]; avgY /= j;
      double avgX     = length * (length-1) * 0.5 / length;
      double sumDxSqr = 0.00;
      double sumDySqr = 0.00;
      double sumDxDy  = 0.00;
   
      for (int k=0; k<length && (i-k)>=0; k++)
      {
         double dx = k-avgX;
         double dy = workErr[i-k][instanceNo]-avgY;
            sumDxSqr += (dx*dx);
            sumDySqr += (dy*dy);
            sumDxDy  += (dx*dy);
      }
      double err2 = (sumDySqr-(sumDxDy*sumDxDy)/sumDxSqr)/(length-2); 
      
   //
   //
   //
   //
   //
         
   if (err2 > 0)
         return(MathSqrt(err2));
   else  return(0.00);       
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];
       
       //
       //
       //
       //
       //

       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" bbsqueeze "+doWhat;
          if (alertsMessage)    Alert(message);
          if (alertsPushNotif)  SendNotification(message);
          if (alertsEmail)      SendMail(_Symbol+" bbsqueeze ",message);
          if (alertsSound)      PlaySound(soundFile);
      }
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


