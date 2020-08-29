//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrLimeGreen
#property indicator_color4  clrOrange
#property indicator_color5  clrOrange
#property indicator_color6  clrSilver
#property indicator_color7  clrSilver
#property indicator_color8  clrLimeGreen
#property indicator_color9  clrOrange
#property indicator_style6  STYLE_DOT
#property indicator_style7  STYLE_DOT
//#property strict

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
enum enIterpolation
{
   int_noint, // No interpolation
   int_line,  // Linear interpolation
   int_quad   // Quadratic interpolation
};
enum enDisplay
{
   en_lin,  // Display lines
   en_his,  // Display colored bars
   en_all,  // Display colored lines and bars
   en_lid,  // Display lines with dots
   en_hid,  // Display colored bars with dots
   en_ald,  // Display colored lines and bars with dots
   en_dot   // Display dots
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
extern enDisplay      DisplayType        = en_lin;   // Display type
extern int            LinesWidth         = 3;        // Lines width (when lines are included in display)
extern int            BarsWidth          = 1;        // Bars width (when bars are included in display)
extern bool           alertsOn           = true;     // Turn alerts on?
extern bool           alertsOnCurrent    = true;     // Alerts on current (still opened) bar?
extern bool           alertsMessage      = true;     // Alerts should display alert message?
extern bool           alertsSound        = true;     // Alerts should play alert sound?
extern bool           alertsPushNotif    = false;    // Alerts should send alert notification?
extern bool           alertsEmail        = false;    // Alerts should send alert email?
extern double         UpPips             = 0;        // Upper band in pips (<= 0 - no band)
extern double         DnPips             = 0;        // Lower band in pips (<= 0 - no band)
extern int            ArrowCodeUp        = 159;      // Up Arrow code
extern int            ArrowCodeDn        = 159;      // Down Arrow code
extern double         ArrowGapUp         = 0.5;      // Gap for arrow up        
extern double         ArrowGapDn         = 0.5;      // Gap for arrow down
extern int            ArrowSizeUp        = 2;        // Up Arrow Size 
extern int            ArrowSizeDn        = 2;        // Down Arrow Size
extern bool           ArrowOnFirst       = true;     // Arrow on first bars
extern int            Shift              = 0;        // Average shift
extern enIterpolation Interpolate        = int_line; // Interpolating method when using multi time frame mode

double histou[];
double histod[];
double LineBuffer[];
double DnBuffera[];
double DnBufferb[];
double bandUp[];
double bandDn[];
double arrowu[];
double arrowd[];
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
   IndicatorBuffers(12);
   int lstyle = DRAW_LINE;        if (DisplayType==en_his || DisplayType==en_hid || DisplayType==en_dot) lstyle = DRAW_NONE;
   int hstyle = DRAW_HISTOGRAM;   if (DisplayType==en_lin || DisplayType==en_lid || DisplayType==en_dot) hstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;       if (DisplayType<en_lid)                                                astyle = DRAW_NONE;
   SetIndexBuffer(0, histou);     SetIndexStyle(0,hstyle,EMPTY,BarsWidth);  
   SetIndexBuffer(1, histod);     SetIndexStyle(1,hstyle,EMPTY,BarsWidth);  
   SetIndexBuffer(2, LineBuffer); SetIndexStyle(2,lstyle,EMPTY,LinesWidth);  
   SetIndexBuffer(3, DnBuffera);  SetIndexStyle(3,lstyle,EMPTY,LinesWidth); 
   SetIndexBuffer(4, DnBufferb);  SetIndexStyle(4,lstyle,EMPTY,LinesWidth);  
   SetIndexBuffer(5, bandUp);
   SetIndexBuffer(6, bandDn);
   SetIndexBuffer(7, arrowu);     SetIndexStyle(7,astyle,0,ArrowSizeUp); SetIndexArrow(7,ArrowCodeUp);
   SetIndexBuffer(8, arrowd);     SetIndexStyle(8,astyle,0,ArrowSizeDn); SetIndexArrow(8,ArrowCodeDn);
   SetIndexBuffer(9, smin);
   SetIndexBuffer(10,smax);
   SetIndexBuffer(11,trend);
   
      OmaLength         = MathMax(OmaLength,   1);
      OmaSpeed          = MathMax(OmaSpeed ,-1.5);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-99; 
         if (TimeFrameCustom==0) TimeFrameCustom = MathMax(TimeFrameCustom,_Period);
         if (TimeFrame!=tf_cus)
               TimeFrame = MathMax(TimeFrame,_Period);
         else  TimeFrame = (enTimeFrames)TimeFrameCustom;
         for (int i=0; i<7; i++) SetIndexShift(i,Shift*TimeFrame/Period());
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
         if (returnBars) { histou[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      if (trend[limit]==-1) CleanPoint(limit,DnBuffera,DnBufferb);
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
   	   histou[i]     = EMPTY_VALUE;
         histod[i]     = EMPTY_VALUE;
         arrowu[i]     = EMPTY_VALUE;
         arrowd[i]     = EMPTY_VALUE;
         if (i<(Bars-1))
         {
   	     if (trend[i]==-1) PlotPoint(i,DnBuffera,DnBufferb,LineBuffer);
   	     if (trend[i]==-1) { histou[i] = Low[i]; histod[i] = High[i]; }
           if (trend[i]== 1) { histod[i] = Low[i]; histou[i] = High[i]; }
         }
         if (UpPips>0) bandUp[i] = LineBuffer[i]+UpPips*_Point*MathPow(10,_Digits%2);    
         if (DnPips>0) bandDn[i] = LineBuffer[i]-DnPips*_Point*MathPow(10,_Digits%2);    
         if (i<Bars-1 && trend[i]!= trend[i+1])
         {
           if (trend[i] ==  1) arrowu[i] = MathMin(LineBuffer[i],Low[i] )-iATR(NULL,0,15,i)*ArrowGapUp;
           if (trend[i] == -1) arrowd[i] = MathMax(LineBuffer[i],High[i])+iATR(NULL,0,15,i)*ArrowGapDn;
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
   if (trend[limit]==-1) CleanPoint(limit,DnBuffera,DnBufferb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
      int x = y;
      if (ArrowOnFirst)
            {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);          }
      else  {  if (i>0) x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
         trend[i]      = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,false,0,11,y);
         LineBuffer[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,false,0, 2,y);
         bandUp[i]     = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,false,0, 5,y);
         bandDn[i]     = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,false,0, 6,y);
         DnBuffera[i]  = EMPTY_VALUE;
   	   DnBufferb[i]  = EMPTY_VALUE;
   	   histou[i]     = EMPTY_VALUE;
         histod[i]     = EMPTY_VALUE;
         arrowu[i]     = EMPTY_VALUE;
         arrowd[i]     = EMPTY_VALUE;
         if (x!=y)
         {
            arrowu[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,false,0,7,y);
            arrowd[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,OmaLength,OmaSpeed,OmaAdaptive,Sensitivity,StepSize,HighLow,Filter,FilterPeriod,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,UpPips,DnPips,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowSizeUp,ArrowSizeDn,false,0,8,y);
         }
         if (trend[i]==-1) { histou[i] = Low[i]; histod[i] = High[i]; }
         if (trend[i]== 1) { histod[i] = Low[i]; histou[i] = High[i]; }

         //
         //
         //
         //
         //
      
         if (Interpolate==int_noint || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
             interpolate(LineBuffer,TimeFrame,i,Interpolate);
             interpolate(bandUp    ,TimeFrame,i,Interpolate);
             interpolate(bandDn    ,TimeFrame,i,Interpolate);
   }
   for (i=limit;i>=0;i--) if (trend[i]==-1) PlotPoint(i,DnBuffera,DnBufferb,LineBuffer);
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
   int bar = iBarShift(NULL,ptimeFrame,Time[i]); double x0 = 0, x1 = 1, x2 = 2, y0 =0, y1 = 0, y2 = 0;
   if (interpolateType==int_quad)
   {
      y0 = target[i];                                                
      y1 = target[(int)MathMin(iBarShift(NULL,0,iTime(NULL,ptimeFrame,bar+0))+1,Bars-1)]; 
      y2 = target[(int)MathMin(iBarShift(NULL,0,iTime(NULL,ptimeFrame,bar+1))+1,Bars-1)]; 
   }      

      //
      //
      //
      //
      //

      datetime time = iTime(NULL,ptimeFrame,bar);
      int n,k;
         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;
         for(k = 1; (i+n)<Bars && (i+k)<Bars && k<n; k++)
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