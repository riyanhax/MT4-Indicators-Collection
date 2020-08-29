
#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_label1  "Deviation"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_width1  3
#property indicator_label2  "Deviation"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_width2  3
#property indicator_label3  "Deviation"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_width3  3
#property indicator_label4  "Ma of deviation"
#property indicator_type4   DRAW_LINE
#property indicator_style4  STYLE_DASH
#property indicator_color4  clrWhite

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
enum enCalcType
{
   st_ste, // Use standard error
   st_sam, // Custom standard deviation - with sample correction
   st_nos  // Custom standard deviation - without sample correction
};
extern ENUM_TIMEFRAMES   TimeFrame        = PERIOD_CURRENT;     // Time frame to use
input ENUM_APPLIED_PRICE StdPrice         = PRICE_CLOSE;        // Standard deviation price
input int                StdPeriod        = 20;                 // Standard deviation period
input enCalcType         DevType          = st_nos;             // Deviation calculation type
input int                SigMaPeriod      = 20;                 // Ma period
input enMaTypes          MaMethod         = ma_lwma;            // Moving average method  
input bool               alertsOn         = true;               // Alerts on true/false?
input bool               alertsOnCurrent  = false;              // Alerts open bar true/false?
input bool               alertsMessage    = true;               // Alerts message true/false?
input bool               alertsSound      = false;              // Alerts sound true/false?
input bool               alertsEmail      = false;              // Alerts email true/false?
input bool               alertsPushNotif  = false;              // Alerts notification true/false?
input bool               Interpolate      = true;               // Interpolate in mtf mode?

double std[],stdda[],stddb[],sdma[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,StdPrice,StdPeriod,DevType,SigMaPeriod,MaMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif,_buff,_ind)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,std,  INDICATOR_DATA);
   SetIndexBuffer(1,stdda,INDICATOR_DATA);
   SetIndexBuffer(2,stddb,INDICATOR_DATA);
   SetIndexBuffer(3,sdma, INDICATOR_DATA);
   SetIndexBuffer(4,trend);
   SetIndexBuffer(5,count); 
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
  
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(TimeFrame)+" deviations + ma ("+(string)StdPeriod+","+(string)SigMaPeriod+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//+-----------------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                             |
//+-----------------------------------------------------------------------------------------------------------------------------+
//
//
//
//
//

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i,limit=fmin(rates_total-prev_calculated+1,rates_total-1); count[0]=limit;
      if (TimeFrame!=_Period)
      {
         limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(5,0)*TimeFrame/_Period));
         if (trend[limit] == -1) CleanPoint(limit,stdda,stddb);
         for (i=limit;i>=0 && !_StopFlag; i--)
         {
            int y = iBarShift(NULL,TimeFrame,time[i]);
               std[i]   = _mtfCall(0,y);
               stdda[i] = stddb[i] = EMPTY_VALUE; 
               sdma[i]  = _mtfCall(3,y);
               trend[i] = _mtfCall(4,y);
                 
               //
               //
               //
               //
               //
                     
               if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                  #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                  int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<rates_total && time[i+n] >= btime; n++) continue;	
                     for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                     {
                        _interpolate(std);
                        _interpolate(sdma);
                     }                                  
        }   
        for (i=limit;i>=0 && !_StopFlag; i--)  if (trend[i] == -1) PlotPoint(i,stdda,stddb,std); 
	return(rates_total);
	} 
	
	//
	//
	//
	     
   if (trend[limit] == -1) CleanPoint(limit,stdda,stddb);
   for (i=limit;i>=0 && !_StopFlag; i--) 
   {
       double price = getPrice(StdPrice,open,close,high,low,i,rates_total);
       switch (DevType)
       {
            case st_ste : std[i] = iStdError(price, StdPeriod,i,rates_total);                 break;
            default :     std[i] = iDeviation(price,StdPeriod,DevType==st_sam,i,rates_total); 
       }            
       sdma[i]  = iCustomMa(MaMethod,std[i],SigMaPeriod,i,rates_total);    
       trend[i] = (i<rates_total-1) ? (std[i]>std[i+1]) ? 1 : (std[i]<std[i+1]) ? -1 : trend[i+1] : 0; 
       stdda[i] = stddb[i] = EMPTY_VALUE;  if (trend[i] == -1) PlotPoint(i,stdda,stddb,std);       
   }
   
   //
   //
   //
   //
   //
      
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("sloping up");
      else  doAlert("sloping down");       
   }     
return(rates_total);
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

#define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double values, int length, bool isSample, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workDev,0)!=bars) ArrayResize(workDev,bars); i=bars-i-1; workDev[i][instanceNo] = values;
                 
   //
   //
   //
   //
   //
   
      double oldMean   = values;
      double newMean   = values;
      double squares   = 0; int k;
      for (k=1; k<length && (i-k)>=0; k++)
      {
         newMean  = (workDev[i-k][instanceNo]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k][instanceNo]-oldMean)*(workDev[i-k][instanceNo]-newMean);
         oldMean  = newMean;
      }
      return(sqrt(squares/fmax(k-isSample,1)));
}

//
//
//
//
//

double workErr[][_devInstances];
double iStdError(double values, int length,int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workErr,0)!=bars) ArrayResize(workErr,bars); i = bars-i-1; workErr[i][instanceNo] = values;
                        
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
         return(sqrt(err2));
   else  return(0.00);       
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
         
         double haOpen  = (r>0) ? (open[i+1]+close[i+1])*0.5 : (open[i]+close[i])*0.5;
         double haClose = (open[i]+high[i]+low[i]+close[i])*0.25;
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" deviations + ma "+doWhat;
             if (alertsMessage)   Alert(message);
             if (alertsPushNotif) SendNotification(message);
             if (alertsEmail)     SendMail(_Symbol+" deviations + ma ",message);
             if (alertsSound)     PlaySound("alert2.wav");
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}



