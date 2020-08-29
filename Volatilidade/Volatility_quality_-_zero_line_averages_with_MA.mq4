//+------------------------------------------------------------------+
//|                                           Volatility quality.mq4 |
//|                                                                  |
//|                                                                  |
//| Volatility quality index originaly developed by                  |
//| Thomas Stridsman (August 2002 Active Trader Magazine)            |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers    4
#property indicator_color1     LimeGreen
#property indicator_color2     Red
#property indicator_color3     Red
#property indicator_color4     White
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_width4     2
#property indicator_level1     0
#property indicator_levelcolor DarkGray

//
//
//
//
//

enum enMaTypes
{
   ma_sma,     // simple moving average - SMA
   ma_ema,     // exponential moving average - EMA
   ma_dsema,   // double smoothed exponential moving average - DSEMA
   ma_dema,    // double exponential moving average - DEMA
   ma_tema,    // tripple exponential moving average - TEMA
   ma_smma,    // smoothed moving average - SMMA
   ma_lwma,    // linear weighted moving average - LWMA
   ma_pwma,    // parabolic weighted moving average - PWMA
   ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // volume weighted moving average - VWMA
   ma_hull,    // Hull moving average
   ma_tma,     // triangular moving average
   ma_sine,    // sine weighted moving average
   ma_linr,    // linear regression value
   ma_ie2,     // IE/2
   ma_nlma,    // non lag moving average
   ma_zlma,    // zero lag moving average
   ma_lead,    // leader exponential moving average
   ma_ssm,     // super smoother
   ma_smoo     // smoother
};
enum enTimeFrames
{
   tf_cu  = 0,              // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mb1 = PERIOD_MN1      // Monthly
};
enum enIterpolation
{
   int_noint, // No interpolation
   int_line,  // Linear interpolation
   int_quad   // Quadratic interpolation
};

extern enTimeFrames   TimeFrame            = tf_cu;
extern int            PriceSmoothing       = 25;
extern enMaTypes      PriceSmoothingMethod = ma_ssm;
extern double         Filter               = 0.5;

extern int            MA_Period            = 10;
extern ENUM_MA_METHOD MA_Type              = MODE_SMA;

extern bool           alertsOn             = false;
extern bool           alertsOnCurrent      = true;
extern bool           alertsMessage        = true;
extern bool           alertsPushNotif      = false;
extern bool           alertsSound          = false;
extern bool           alertsEmail          = false;
extern string         soundFile            = "alert2.wav";
extern enIterpolation Interpolate          = int_line;

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
double ma[];

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
   IndicatorBuffers(6);
      SetIndexBuffer(0,sumVqi); 
      SetIndexBuffer(1,sumVqida); 
      SetIndexBuffer(2,sumVqidb);
      SetIndexBuffer(3,ma); 
      SetIndexBuffer(4,Vqi);   
      SetIndexBuffer(5,trend); 
      
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
      
      IndicatorShortName(timeFrameToString(TimeFrame)+" Volatility quality zero line "+getAverageName(PriceSmoothingMethod)+" ("+PriceSmoothing+","+Filter+")");
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
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { sumVqi[0] = MathMin(limit+1,Bars-1); return(0); }
         double pipMultiplier = MathPow(10,_Digits%2);

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {     
     if (trend[limit] == -1) CleanPoint(limit,sumVqida,sumVqidb);
     for(int i=limit; i>=0; i--)
     {
        if (i==(Bars-1)) { Vqi[i] = 0; sumVqi[i] = 0; continue; }

        double cHigh  = iCustomMa(PriceSmoothingMethod,iMA(NULL,0,1,0,MODE_SMA,PRICE_HIGH ,i)  ,PriceSmoothing,i,0);
        double cLow   = iCustomMa(PriceSmoothingMethod,iMA(NULL,0,1,0,MODE_SMA,PRICE_LOW  ,i)  ,PriceSmoothing,i,1);
        double cOpen  = iCustomMa(PriceSmoothingMethod,iMA(NULL,0,1,0,MODE_SMA,PRICE_OPEN ,i)  ,PriceSmoothing,i,2);
        double cClose = iCustomMa(PriceSmoothingMethod,iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,i)  ,PriceSmoothing,i,3);
        double pClose = iCustomMa(PriceSmoothingMethod,iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,i+1),PriceSmoothing,i,4);;

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
           if (Filter > 0) if (MathAbs(sumVqi[i]-sumVqi[i+1]) < Filter*Point*pipMultiplier) sumVqi[i] = sumVqi[i+1];
      
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
      manageAlerts();
      for (int j=limit; j>=0; j--)
               {
               ma[j] = iMAOnArray(sumVqi,0,MA_Period,0,MA_Type,j);
               } 

      return(0);
   }      

   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/_Period));
   if (trend[limit] == -1) CleanPoint(limit,sumVqida,sumVqidb);
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         trend[i]    = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,PriceSmoothing,PriceSmoothingMethod,Filter,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,soundFile,4,y);
         sumVqi[i]   = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,PriceSmoothing,PriceSmoothingMethod,Filter,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,soundFile,0,y);
         sumVqida[i] = EMPTY_VALUE;
         sumVqidb[i] = EMPTY_VALUE;
         if (Interpolate==int_noint || (y!=0 && y==iBarShift(NULL,TimeFrame,Time[MathMax(i-1,0)]))) continue;
             interpolate(sumVqi,TimeFrame,i,Interpolate);
   }
   for (i=limit; i>=0; i--) if (trend[i]==-1) PlotPoint(i,sumVqida,sumVqidb,sumVqi);
   for (int k=limit; k>=0; k--)
               {
               ma[k] = iMAOnArray(sumVqi,0,MA_Period,0,MA_Type,j);
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

void interpolate(double& target[], int ptimeFrame, int i, int interpolateType)
{
   int bar = iBarShift(NULL,ptimeFrame,Time[i]); double y0,y1,y2,x0,x1,x2;
   if (interpolateType==int_quad)
   {
      if ((iBarShift(NULL,0,iTime(NULL,ptimeFrame,bar+1))+1)>(Bars-1)) return;
         y0 = target[i];                                                x0 = 0;
         y1 = target[iBarShift(NULL,0,iTime(NULL,ptimeFrame,bar+0))+1]; x1 = 1;
         y2 = target[iBarShift(NULL,0,iTime(NULL,ptimeFrame,bar+1))+1]; x2 = 2;
   }               

      //
      //
      //
      //
      //

      datetime time = iTime(NULL,ptimeFrame,bar);
      int n,k;
         for(n = 1; i+n < Bars-1 && Time[i+n] >= time; n++) continue;
         for(k = 1; i+k < Bars-1 && k < n; k++)
         if (interpolateType==int_quad)
         {
            double x3 = (double)k/n;
               target[i+k]  = y0*(x3-x1)*(x3-x2)/(-x1*(-x2))+
                              y1*(x3-x0)*(x3-x2)/( x1*(-x1))+
		                        y2*(x3-x0)*(x3-x1)/( x2*( x1));         
         }
         else target[i+k] = target[i] + (target[i+n] - target[i])*k/n;
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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(_Period)+" VQ trend changed to ",doWhat);
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(StringConcatenate(Symbol()," VQ "),message);
          if (alertsPushNotif) SendNotification(StringConcatenate(Symbol(), " VQ "+" "+message)); 
          if (alertsSound)     PlaySound(soundFile);
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

string methodNames[] = {"SMA","EMA","Double smoothed EMA","Double EMA","Tripple EMA","Smoothed MA","Linear weighted MA","Parabolic weighted MA","Alexander MA","Volume weghted MA","Hull MA","Triangular MA","Sine weighted MA","Linear regression","IE/2","NonLag MA","Zero lag EMA","Leader EMA","Super smoother","Smoothed"};
string getAverageName(int method)
{
   int max = ArraySize(methodNames)-1;
      method=MathMax(MathMin(method,max),0); return(methodNames[method]);
}

//
//
//
//
//

#define _maWorkBufferx1 5
#define _maWorkBufferx2 10
#define _maWorkBufferx3 15
#define _maWorkBufferx5 25

double iCustomMa(int mode, double price, double length, int i, int instanceNo=0)
{
   int r = Bars-i-1;
   length = MathMax(length,1);
   switch (mode)
   {
      case ma_sma   : return(iSma(price,length,r,instanceNo));
      case ma_ema   : return(iEma(price,length,r,instanceNo));
      case ma_dsema : return(iDsema(price,length,r,instanceNo));
      case ma_dema  : return(iDema(price,length,r,instanceNo));
      case ma_tema  : return(iTema(price,length,r,instanceNo));
      case ma_smma  : return(iSmma(price,length,r,instanceNo));
      case ma_lwma  : return(iLwma(price,length,r,instanceNo));
      case ma_pwma  : return(iLwmp(price,length,r,instanceNo));
      case ma_alxma : return(iAlex(price,length,r,instanceNo));
      case ma_vwma  : return(iWwma(price,length,r,instanceNo));
      case ma_hull  : return(iHull(price,length,r,instanceNo));
      case ma_tma   : return(iTma(price,length,r,instanceNo));
      case ma_sine  : return(iSineWMA(price,length,r,instanceNo));
      case ma_linr  : return(iLinr(price,length,r,instanceNo));
      case ma_ie2   : return(iIe2(price,length,r,instanceNo));
      case ma_nlma  : return(iNonLagMa(price,length,r,instanceNo));
      case ma_zlma  : return(iZeroLag(price,length,r,instanceNo));
      case ma_lead  : return(iLeader(price,length,r,instanceNo));
      case ma_ssm   : return(iSsm(price,length,r,instanceNo));
      case ma_smoo  : return(iSmooth(price,length,r,instanceNo));
      default : return(0);
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= Bars) ArrayResize(workDsema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]);
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= Bars) ArrayResize(workDema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workDema[r][_dema1+instanceNo] = workDema[r-1][_dema1+instanceNo]+alpha*(price                         -workDema[r-1][_dema1+instanceNo]);
          workDema[r][_dema2+instanceNo] = workDema[r-1][_dema2+instanceNo]+alpha*(workDema[r][_dema1+instanceNo]-workDema[r-1][_dema2+instanceNo]);
   return(workDema[r][_dema1+instanceNo]*2.0-workDema[r][_dema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= Bars) ArrayResize(workTema,Bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]);
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
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

//
//
//
//
//

double workLwmp[][_maWorkBufferx1];
double iLwmp(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwmp,0)!= Bars) ArrayResize(workLwmp,Bars);
   
   //
   //
   //
   //
   //
   
   workLwmp[r][instanceNo] = price;
      double sumw = period*period;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (period-k)*(period-k);
                sumw  += weight;
                sum   += weight*workLwmp[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workAlex[][_maWorkBufferx1];
double iAlex(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workAlex,0)!= Bars) ArrayResize(workAlex,Bars);
   if (period<4) return(price);
   
   //
   //
   //
   //
   //

   workAlex[r][instanceNo] = price;
      double sumw = period-2;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k-2;
                sumw  += weight;
                sum   += weight*workAlex[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workTma[][_maWorkBufferx1];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTma,0)!= Bars) ArrayResize(workTma,Bars);
   
   //
   //
   //
   //
   //
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workSineWMA[][_maWorkBufferx1];
#define Pi 3.14159265358979323846264338327950288

double iSineWMA(double price, int period, int r, int instanceNo=0)
{
   if (period<1) return(price);
   if (ArrayRange(workSineWMA,0)!= Bars) ArrayResize(workSineWMA,Bars);
   
   //
   //
   //
   //
   //
   
   workSineWMA[r][instanceNo] = price;
      double sum  = 0;
      double sumw = 0;
  
      for(int k=0; k<period && (r-k)>=0; k++)
      { 
         double weight = MathSin(Pi*(k+1.0)/(period+1.0));
                sumw  += weight;
                sum   += weight*workSineWMA[r-k][instanceNo]; 
      }
      return(sum/sumw);
}

//
//
//
//
//

double workWwma[][_maWorkBufferx1];
double iWwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workWwma,0)!= Bars) ArrayResize(workWwma,Bars);
   
   //
   //
   //
   //
   //
   
   workWwma[r][instanceNo] = price;
      int    i    = Bars-r-1;
      double sumw = Volume[i];
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = Volume[i+k];
                sumw  += weight;
                sum   += weight*workWwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workHull[][_maWorkBufferx2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars);

   //
   //
   //
   //
   //

      int HmaPeriod  = MathMax(period,2);
      int HalfPeriod = MathFloor(HmaPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= Bars) ArrayResize(workLinr,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}

//
//
//
//
//

double workIe2[][_maWorkBufferx1];
double iIe2(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workIe2,0)!= Bars) ArrayResize(workIe2,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workIe2[r][instanceNo] = price;
         double sumx=0, sumxx=0, sumxy=0, sumy=0;
         for (int k=0; k<period; k++)
         {
            price = workIe2[r-k][instanceNo];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
         }
         double tslope  = (period*sumxy - sumx*sumy)/(sumx*sumx-period*sumxx);
         double average = sumy/period;
   return(((average+tslope)+(sumy+tslope*sumx)/period)/2.0);
}

//
//
//
//
//

double workLeader[][_maWorkBufferx2];
double iLeader(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLeader,0)!= Bars) ArrayResize(workLeader,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      double alpha = 2.0/(period+1.0);
         workLeader[r][instanceNo  ] = workLeader[r-1][instanceNo  ]+alpha*(price                          -workLeader[r-1][instanceNo  ]);
         workLeader[r][instanceNo+1] = workLeader[r-1][instanceNo+1]+alpha*(price-workLeader[r][instanceNo]-workLeader[r-1][instanceNo+1]);

   return(workLeader[r][instanceNo]+workLeader[r][instanceNo+1]);
}

//
//
//
//
//

double workZl[][_maWorkBufferx2];
#define _zprice 0
#define _zlema  1

double iZeroLag(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workZl,0)!=Bars) ArrayResize(workZl,Bars); instanceNo *= 2; workZl[r][_zprice+instanceNo] = price;

   //
   //
   //
   //
   //

   double median = 0;
   double alpha  = 2.0/(1.0+length); 
   int    per    = (length-1.0)/2.0;
   if (r<per)
          workZl[r][_zlema+instanceNo] = price;
   else   
      {
         if ((int)length%2==0)
               median = (workZl[r-per][_zprice+instanceNo]+workZl[r-per-1][_zprice+instanceNo])/2.0;
         else  median =  workZl[r-per][_zprice+instanceNo];
         workZl[r][_zlema+instanceNo] = workZl[r-1][_zlema+instanceNo]+alpha*(2.0*price-median-workZl[r-1][_zlema+instanceNo]);
      }            
   return(workZl[r][_zlema+instanceNo]);
}

//
//
//
//
//

double workSmooth[][_maWorkBufferx5];
double iSmooth(double price,int length,int r, int instanceNo=0)
{
   if (ArrayRange(workSmooth,0)!=Bars) ArrayResize(workSmooth,Bars); instanceNo *= 5;
 	if(r<=2) { workSmooth[r][instanceNo] = price; workSmooth[r][instanceNo+2] = price; workSmooth[r][instanceNo+4] = price; return(price); }
   
   //
   //
   //
   //
   //
   
	double alpha = 0.45*(length-1.0)/(0.45*(length-1.0)+2.0);
   	  workSmooth[r][instanceNo+0] =  price+alpha*(workSmooth[r-1][instanceNo]-price);
	     workSmooth[r][instanceNo+1] = (price - workSmooth[r][instanceNo])*(1-alpha)+alpha*workSmooth[r-1][instanceNo+1];
	     workSmooth[r][instanceNo+2] =  workSmooth[r][instanceNo+0] + workSmooth[r][instanceNo+1];
	     workSmooth[r][instanceNo+3] = (workSmooth[r][instanceNo+2] - workSmooth[r-1][instanceNo+4])*MathPow(1.0-alpha,2) + MathPow(alpha,2)*workSmooth[r-1][instanceNo+3];
	     workSmooth[r][instanceNo+4] =  workSmooth[r][instanceNo+3] + workSmooth[r-1][instanceNo+4]; 
   return(workSmooth[r][instanceNo+4]);
}

//
//
//
//
//

double workSsm[][_maWorkBufferx2];
#define _tprice  0
#define _ssm     1

double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3

//
//
//
//
//

double iSsm(double price, double period, int i, int instanceNo)
{
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_period] != period)
   {
      workSsmCoeffs[instanceNo][_period] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_c2] = b1;
         workSsmCoeffs[instanceNo][_c3] = -a1*a1;
         workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2;   
          workSsm[i][s+_tprice] = price;
          workSsm[i][s+_ssm]    = workSsmCoeffs[instanceNo][_c1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                                  workSsmCoeffs[instanceNo][_c2]*workSsm[i-1][s+_ssm]                                + 
                                  workSsmCoeffs[instanceNo][_c3]*workSsm[i-2][s+_ssm]; 
   return(workSsm[i][s+_ssm]);
}

//
//
//
//
//

#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[_maWorkBufferx1][3];
double  nlmprices[ ][_maWorkBufferx1];
double  nlmalphas[ ][_maWorkBufferx1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(nlmprices,0) != Bars)         ArrayResize(nlmprices,Bars);
   if (ArrayRange(nlmvalues,0) <  instanceNo+1) ArrayResize(nlmvalues,instanceNo+1);
                               nlmprices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlmprices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[instanceNo][_length] != length  || ArraySize(nlmalphas)==0)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlmvalues[instanceNo][_length] = length;
         nlmvalues[instanceNo][_len   ] = length*4 + Phase;  
         nlmvalues[instanceNo][_weight] = 0;

         if (ArrayRange(nlmalphas,0) < nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas,nlmvalues[instanceNo][_len]);
         for (int k=0; k<nlmvalues[instanceNo][_len]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[instanceNo][_weight]>0)
   {
      double sum = 0;
           for (k=0; k < nlmvalues[instanceNo][_len]; k++) sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
           return( sum / nlmvalues[instanceNo][_weight]);
   }
   else return(0);           
}