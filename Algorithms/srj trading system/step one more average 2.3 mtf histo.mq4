//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//    when speed == allmost same with (smoothed)
//
//       0.5 - T3 (0.618 Tilson) 
//       2.5 - T3 (0.618 Fulks/Matulich)
//       1   - SMA, harmonic mean
//       2   - LWMA
//       7   - very similar to Hull and TEMA (but does not overshoot)
//       8   - very similar to LSMA and Linear regression value (but does not overshoot)
//
//

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
   tf_mb1 = PERIOD_MN1,     // Monthly
   tf_cus = 12345678        // Custom time frame
};

extern enTimeFrames   TimeFrame          = tf_cu;    // Time frame
extern int            TimeFrameCustom    = 0;        // Custom time frame to use (if custom time frame used)
extern int            OmaLength          = 25;       // Oma Length
extern double         OmaSpeed           = 2.5;      // Oma Speed
extern bool           OmaAdaptive        = true;     // Use Oma Adaptive true or false
extern double         Sensitivity        = 0.5;      // Sensivity Factor
extern double         StepSize           = 50;       // Step Size period
extern bool           HighLow            = false;    // High/Low Mode Switch (more sensitive)
extern double         Filter             = 0;        // Filter to use for filtering (<=0 - no filtering)
extern double         FilterPeriod       = 0;        // Filter period to use ( when <= 0, same as oma period) 
extern bool           alertsOn           = true;     // Turn alerts on?
extern bool           alertsOnCurrent    = true;     // Alerts on current (still opened) bar?
extern bool           alertsMessage      = true;     // Alerts should display alert message?
extern bool           alertsSound        = true;     // Alerts should play alert sound?
extern bool           alertsPushNotif    = false;    // Alerts should send alert notification?
extern bool           alertsEmail        = false;    // Alerts should send alert email?


double LineBuffer[];
double DnBuffera[];
double DnBufferb[];
double smin[];
double smax[];
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
   IndicatorBuffers(6);
   SetIndexBuffer(0,DnBuffera);  SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DnBufferb);  SetIndexStyle(1,DRAW_HISTOGRAM); 
   SetIndexBuffer(2,LineBuffer);
   SetIndexBuffer(3,smin);
   SetIndexBuffer(4,smax);
   SetIndexBuffer(5,trend);
   
      OmaLength         = MathMax(OmaLength,   1);
      OmaSpeed          = MathMax(OmaSpeed ,-1.5);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-99; 
         if (TimeFrameCustom==0) TimeFrameCustom = MathMax(TimeFrameCustom,_Period);
         if (TimeFrame!=tf_cus)
               TimeFrame = MathMax(TimeFrame,_Period);
         else  TimeFrame = (enTimeFrames)TimeFrameCustom;
   IndicatorShortName(timeFrameToString(TimeFrame)+" StepMA("+(string)OmaLength+","+(string)Sensitivity+","+(string)StepSize+")");
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
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { DnBuffera[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      for(i=limit; i>=0; i--)
      {
         double thigh;
         double tlow;
         int fperiod = OmaLength; if (FilterPeriod>0) fperiod=FilterPeriod;
            if (HighLow)
	               { thigh=iAverage(iFilter(High[i] ,Filter,fperiod,i,0),OmaLength,OmaSpeed,OmaAdaptive,i,0); tlow =iAverage(iFilter(Low[i]  ,Filter,fperiod,i,0),OmaLength,OmaSpeed,OmaAdaptive,i,7);} 	
	         else  { thigh=iAverage(iFilter(Close[i],Filter,fperiod,i,0),OmaLength,OmaSpeed,OmaAdaptive,i,0); tlow =iAverage(iFilter(Close[i],Filter,fperiod,i,1),OmaLength,OmaSpeed,OmaAdaptive,i,7);}
   	   LineBuffer[i] = iStepMa(Sensitivity,iATR(NULL,0,StepSize,i),1.0,thigh,tlow,Close[i],i);
   	   DnBuffera[i]  = EMPTY_VALUE;
   	   DnBufferb[i]  = EMPTY_VALUE;
         if (i<(Bars-1))
         {
   	     if (trend[i]== 1) DnBuffera[i] = 1; 
           if (trend[i]==-1) DnBufferb[i] = 1;
         }
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
            doAlert("up");
      else  doAlert("down");       
   }   
	return(0);	
   }
   
   //
   //
   //
   //
   //

   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         DnBuffera[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,0,y);
         DnBufferb[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,1,y);      
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

#define filterInstances 2
double workFil[][filterInstances*3];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double filter, int period, int i, int instanceNo=0)
{
   if (filter<=0) return(tprice);
   if (ArrayRange(workFil,0)!= Bars) ArrayResize(workFil,Bars); i = Bars-i-1; instanceNo*=3;
   
   //
   //
   //
   //
   //
   
   workFil[i][instanceNo+_fprice]  = tprice; if (i<1) return(tprice);
   workFil[i][instanceNo+_fchange] = MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]);
   workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];

   for (int k=1; k<period && (i-k)>=0; k++) workFil[i][instanceNo+_fachang] += workFil[i-k][instanceNo+_fchange];
                                            workFil[i][instanceNo+_fachang] /= period;
    
   double stddev = 0; for (k=0;  k<period && (i-k)>=0; k++) stddev += MathPow(workFil[i-k][instanceNo+_fchange]-workFil[i-k][instanceNo+_fachang],2);
          stddev = MathSqrt(stddev/(double)period); 
   double filtev = filter * stddev;
   if( MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]) < filtev ) workFil[i][instanceNo+_fprice]=workFil[i-1][instanceNo+_fprice];
        return(workFil[i][instanceNo+_fprice]);
}

//
//
//
//
//

double stored[][14];
              
#define E1  0
#define E2  1
#define E3  2
#define E4  3
#define E5  4
#define E6  5
#define res 6

//
//
//
//
//

double iAverage(double price, double averagePeriod, double tconst, bool adaptive, int i, int ashift=0)
{
   if (ArrayRange(stored,0) != Bars) ArrayResize(stored,Bars);
   if (averagePeriod <=1) return(price);
   int r = Bars-i-1; 
   
   double e1=stored[r-1][E1+ashift];  double e2=stored[r-1][E2+ashift];
   double e3=stored[r-1][E3+ashift];  double e4=stored[r-1][E4+ashift];
   double e5=stored[r-1][E5+ashift];  double e6=stored[r-1][E6+ashift];

   //
   //
   //
   //
   //

      if (adaptive && (averagePeriod > 1))
      {
         double minPeriod = averagePeriod/2.0;
         double maxPeriod = minPeriod*5.0;
         int    endPeriod = MathCeil(maxPeriod);
         double tsignal   = MathAbs((price-stored[r-endPeriod][res+ashift]));
         double noise     = 0.00000000001;

            for(int k=1; k<endPeriod; k++) noise=noise+MathAbs(price-stored[r-k][res+ashift]);

         averagePeriod = ((tsignal/noise)*(maxPeriod-minPeriod))+minPeriod;
      }
      
      //
      //
      //
      //
      //
      
      double alpha = (2.0+tconst)/(1.0+tconst+averagePeriod);

      e1 = e1 + alpha*(price-e1); e2 = e2 + alpha*(e1-e2); double v1 = 1.5 * e1 - 0.5 * e2;
      e3 = e3 + alpha*(v1   -e3); e4 = e4 + alpha*(e3-e4); double v2 = 1.5 * e3 - 0.5 * e4;
      e5 = e5 + alpha*(v2   -e5); e6 = e6 + alpha*(e5-e6); double v3 = 1.5 * e5 - 0.5 * e6;

   //
   //
   //
   //
   //

   stored[r][E1+ashift]  = e1;  stored[r][E2+ashift] = e2;
   stored[r][E3+ashift]  = e3;  stored[r][E4+ashift] = e4;
   stored[r][E5+ashift]  = e5;  stored[r][E6+ashift] = e6;
   stored[r][res+ashift] = price;
   return(v3);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workStep[][3];
#define _smin   0
#define _smax   1
#define _trend  2

double iStepMa(double sensitivity, double stepSize, double stepMulti, double phigh, double plow, double pprice, int r)
{
   if (ArrayRange(workStep,0)!=Bars) ArrayResize(workStep,Bars);
   if (sensitivity == 0) sensitivity = 0.0001; r = Bars-r-1;
   if (stepSize    == 0) stepSize    = 0.0001;
      double result; 
	   double size = sensitivity*stepSize;

      //
      //
      //
      //
      //
      
      if (r==0)
      {
         workStep[r][_smax]  = phigh+2.0*size*stepMulti;
         workStep[r][_smin]  = plow -2.0*size*stepMulti;
         workStep[r][_trend] = 0;
         return(pprice);
      }

      //
      //
      //
      //
      //
      
      workStep[r][_smax]  = phigh+2.0*size*stepMulti;
      workStep[r][_smin]  = plow -2.0*size*stepMulti;
      workStep[r][_trend] = workStep[r-1][_trend];
            if (pprice>workStep[r-1][_smax]) workStep[r][_trend] =  1;
            if (pprice<workStep[r-1][_smin]) workStep[r][_trend] = -1;
            if (workStep[r][_trend] ==  1) { if (workStep[r][_smin] < workStep[r-1][_smin]) workStep[r][_smin]=workStep[r-1][_smin]; result = workStep[r][_smin]+size*stepMulti; }
            if (workStep[r][_trend] == -1) { if (workStep[r][_smax] > workStep[r-1][_smax]) workStep[r][_smax]=workStep[r-1][_smax]; result = workStep[r][_smax]-size*stepMulti; }
      trend[Bars-r-1] = workStep[r][_trend]; 

   return(result); 
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

          message = StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)+" Step Oma ",doWhat);
             if (alertsMessage)   Alert(message);
             if (alertsPushNotif) SendNotification(message);
             if (alertsEmail)     SendMail(StringConcatenate(Symbol()," Step Oma "),message);
             if (alertsSound)     PlaySound("alert2.wav");
      }
}

