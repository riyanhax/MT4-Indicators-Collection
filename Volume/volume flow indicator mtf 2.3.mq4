//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//
//    originaly developed by Markos Katsanos
//    first published in TASC june 2004
//
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrSilver
#property indicator_color2  clrDarkGray
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrPaleVioletRed
#property indicator_color5  clrPaleVioletRed
#property indicator_style1  STYLE_DOT
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property strict

//
//
//
//
//

#import "dynamicZone.dll"
   double dzBuyP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i, double precision);
#import

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};
enum enMaTypes
{
   ma_sma,     // Simple moving average
   ma_ema,     // Exponential moving average
   ma_smma,    // Smoothed MA
   ma_lwma,    // Linear weighted MA
};
enum enColorOn
{
   chg_onSlope, // Color change on slope change
   chg_onZero,  // Color change on zero level cross
   chg_onSign   // Color change on smooth value cross
};
extern ENUM_TIMEFRAMES    TimeFrame       = PERIOD_CURRENT; // Time frame
extern double             VfiCoeff        = 0.2;            // Volume flow coefficient
extern int                VfiPeriod       = 130;            // Calculation period
input enPrices            VfiPrice        = pr_typical;     // Price to use
extern double             VolumeCoeff     = 2.5;            // Volume coefficient
extern int                PreSmoothPeriod = 3;              // Pre-smoothig period
input enMaTypes           PreSmoothMethod = ma_sma;         // Pre-smoothing method             
extern int                SmoothPeriod    = 3;              // Smoothig period
extern int                DzLookBackBars  = 35;             // Dynamic zero line
extern enColorOn          ColorOn         = chg_onZero;     // Color change on :
extern bool               alertsOn        = false;          // Turn alerts on?
extern bool               alertsOnCurrent = false;          // Alerts on current (still opened) bar?
extern bool               alertsMessage   = true;           // Alerts should show pop-up message?
extern bool               alertsSound     = false;          // Alerts should play alert sound?
extern bool               alertsNotify    = false;          // Alerts should send a push notification?
extern bool               alertsEmail     = false;          // Alerts should send an emil?
extern string             soundFile       = "alert2.wav";   // Sound file to use for alerts
extern bool               Interpolate     = true;           // Interpolate in multi time frame mode

double zli[],vfi[],vfs[],vfsua[],vfsub[],trend[];

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

int OnInit()
{
   if (!IsDllsAllowed())
   {
      Alert("and then attach it to the chart again");
      Alert("Please enable DLL imports in the indicator properties");
      Alert("This indicator needs dlls to work");
      return(INIT_FAILED);
   }
   IndicatorBuffers(6);
   SetIndexBuffer(0,zli,  INDICATOR_DATA);  SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,vfi,  INDICATOR_DATA);  SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,vfs,  INDICATOR_DATA);  SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,vfsua,INDICATOR_DATA);  SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,vfsub,INDICATOR_DATA);  SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5,trend);
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" volume flow ("+(string)VfiPeriod+","+(string)VfiCoeff+","+(string)PreSmoothPeriod+","+(string)SmoothPeriod+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){    }


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][5];
#define _price  0
#define _volume 1
#define _voluma 2
#define _dvol   3
#define _vfi    4

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
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { vfi[0] = MathMin(limit+1,Bars-1); return(0); }
         if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      double alpha = 2.0 / (1.0+SmoothPeriod);    
      if (trend[limit]==-1) CleanPoint(limit,vfsua,vfsub);
      for(int i = limit, r=Bars-i-1; i >= 0; i--,r++)
      {
         work[r][_price]  = iCustomMa(PreSmoothMethod,getPrice(VfiPrice,Open,Close,High,Low,i,Bars),PreSmoothPeriod,i,Bars);  
         work[r][_volume] = (double)Volume[i];
         work[r][_voluma] = 0;

            if (r==0) continue;
         
               work[r][_voluma] = work[r][_volume]; for (int k=1; k<VfiPeriod && (r-k)>=0; k++) work[r][_voluma] += work[r-k][_volume];
               work[r][_voluma] /= (double)VfiPeriod;
            
         //
         //
         //
         //
         //
         
            double mf     = work[r][_price]-work[r-1][_price];
            double inter  = log(work[r][_price])-log(work[r-1][_price]);
            double vinter = iDeviation(inter,30,i);
            double cutoff = VfiCoeff * vinter * Close[i];
            double vave   = work[r-1][_voluma];
            double vmax   = vave*VolumeCoeff;
            double vc     = fmin(work[r][_volume],vmax);
            double directionalVolume = 0;
               if (mf> cutoff) directionalVolume =  vc;
               if (mf<-cutoff) directionalVolume = -vc;
         
               //
               //
               //
               //
               //
            
               work[r][_dvol] = directionalVolume;
               work[r][_vfi]  = directionalVolume;  for (int k=1; k<VfiPeriod && (r-k)>=0; k++) work[r][_vfi] += work[r-k][_dvol];
               if (vave!=0)
                     work[r][_vfi] /= vave;
               else  work[r][_vfi] = 0;
               
               vfi[i]   = work[r][_vfi];
               vfs[i]   = vfs[i+1]+alpha*(work[r][_vfi]-vfs[i+1]);
               zli[i]   = dzBuyP(vfs,0.5,DzLookBackBars,Bars,i,0.0001);
               vfsua[i] = vfsub[i] = EMPTY_VALUE;
               switch (ColorOn)
               {
                  case chg_onZero:   trend[i] = (vfs[i]>zli[i])   ? 1 : (vfs[i]<zli[i])   ? -1: trend[i+1]; break;
                  case chg_onSlope:  trend[i] = (vfs[i]>vfs[i+1]) ? 1 : (vfs[i]<vfs[i+1]) ? -1: trend[i+1]; break;
                  default:           trend[i] = (vfi[i]>vfs[i])   ? 1 : (vfi[i]<vfs[i])   ? -1: trend[i+1];
               }               
               if (trend[i]== -1) PlotPoint(i,vfsua,vfsub,vfs);
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,vfsua,vfsub);
   for(int i = limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         zli[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,VfiCoeff,VfiPeriod,VfiPrice,VolumeCoeff,PreSmoothPeriod,PreSmoothMethod,SmoothPeriod,DzLookBackBars,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,0,y);
         vfi[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,VfiCoeff,VfiPeriod,VfiPrice,VolumeCoeff,PreSmoothPeriod,PreSmoothMethod,SmoothPeriod,DzLookBackBars,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,1,y);
         vfs[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,VfiCoeff,VfiPeriod,VfiPrice,VolumeCoeff,PreSmoothPeriod,PreSmoothMethod,SmoothPeriod,DzLookBackBars,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,2,y);
         trend[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,VfiCoeff,VfiPeriod,VfiPrice,VolumeCoeff,PreSmoothPeriod,PreSmoothMethod,SmoothPeriod,DzLookBackBars,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,5,y);
         vfsua[i] = vfsub[i] = EMPTY_VALUE;

         //
         //
         //
         //
         //
      
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
                  zli[i+k]  = zli[i]  + (zli[i+n]  - zli[i])*k/n;
                  vfi[i+k]  = vfi[i]  + (vfi[i+n]  - vfi[i])*k/n;
                  vfs[i+k]  = vfs[i]  + (vfs[i+n]  - vfs[i])*k/n;
               }
   }
   for (int i=limit;i>=0;i--) if (trend[i]== -1) PlotPoint(i,vfsua,vfsub,vfs);
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

double array[];
double iDeviation(double value, double period, int i)
{
   if (ArraySize(array)!=Bars) ArrayResize(array,Bars); i= Bars-i-1; array[i] = value;
   double avg = 0; for(int k=0; k<period && (i-k)>=0; k++) avg += array[i-k]; avg /= period;
   double sum = 0; for(int k=0; k<period && (i-k)>=0; k++) sum += (array[i-k]-avg)*(array[i-k]-avg);
   return(MathSqrt(sum/period));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

string getAverageName(int method)
{
      switch(method)
      {
         case ma_ema:    return("EMA");
         case ma_lwma:   return("LWMA");
         case ma_sma:    return("SMA");
         case ma_smma:   return("SMMA");
      }
return("");      
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)ceil(length),r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1;  for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
   return(avg/(double)k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*fabs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         //
         //
         
         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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

//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
      }         
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

           message = Symbol()+" "+timeFrameToString(_Period)+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" volume flow indicator state changed to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(" volume flow indicator ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}