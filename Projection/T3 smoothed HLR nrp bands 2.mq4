//+------------------------------------------------------------------+
//|                                                          HLR.mq4 |
//|                                      Copyright © 2007, Alexandre |
//|                      http://www.kroufr.ru/content/view/1184/124/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Alexandre"
#property link      "http://www.kroufr.ru/content/view/1184/124/"
//----
#property indicator_separate_window
#property indicator_buffers    6 
#property indicator_minimum    -30 
#property indicator_maximum    130
#property indicator_color1     DeepSkyBlue
#property indicator_color2     PaleVioletRed
#property indicator_color3     PaleVioletRed
#property indicator_color4     DarkSlateGray
#property indicator_color5     DarkSlateGray
#property indicator_color6     DarkSlateGray
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_style4     STYLE_DASH
#property indicator_style5     STYLE_DASH
#property indicator_style6     STYLE_DASH
#property indicator_levelcolor MediumOrchid

//
//
//
//
//---- input parameters

extern string TimeFrame        = "current time frame";
extern int    HLR_Range        = 75;
extern double T3SmoothLength   = 5;
extern double T3Hot            = 1.0;
extern bool   T3Original       = false;
extern int    mamode           = MODE_LWMA;
extern int    BandsPeriod      = 20;
extern double BandsDeviations  = 1.64;
extern bool   MultiColor       = true;
extern double level1           = 5;
extern double level2           = 50;
extern double level3           = 95;

extern string _                = "alerts settings";
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern bool   Interpolate      = true;

//
//
//
//
//

double hlr[];
double hlrDa[];
double hlrDb[];
double bUp[];
double bMi[];
double bDn[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

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
   SetIndexBuffer(0,hlr); 
   SetIndexBuffer(1,hlrDa); 
   SetIndexBuffer(2,hlrDb);  
   SetIndexBuffer(3,bUp);
   SetIndexBuffer(4,bMi);
   SetIndexBuffer(5,bDn);
   SetIndexBuffer(6,trend);
   
   SetLevelValue(0,level1);
   SetLevelValue(1,level2);
   SetLevelValue(2,level3);
   
     //
     //
     //
     //
     //
                  
     indicatorFileName = WindowExpertName();
     calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
     returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
     timeFrame         = stringToTimeFrame(TimeFrame);
         
     //
     //
     //
     //
     //
         
     IndicatorShortName(timeFrameToString(timeFrame)+"  T3 Smoothed HLR nrp bands (" +HLR_Range+ ")"); 
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
//
//

int deinit()  {   return(0);  }

//
//
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
   int i,counted_bars=IndicatorCounted();
     if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { hlr[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame==Period())
   {
     if (MultiColor && !calculateValue && trend[limit]==-1) CleanPoint(limit,hlrDa,hlrDb);  
     for (i = limit; i >= 0; i--)
     {
       double hhv  = High[iHighest(NULL, 0, MODE_HIGH, HLR_Range, i)];
       double llv  =  Low[iLowest (NULL, 0, MODE_LOW,  HLR_Range, i)]; 
       double m_pr = (High[i] + Low[i]) / 2.0; 
       if (hhv!=llv)
               hlr[i] = iT3(100.0 * (m_pr - llv) / (hhv - llv),T3SmoothLength,T3Hot,T3Original,i); 
        else   hlr[i] = iT3(50                                ,T3SmoothLength,T3Hot,T3Original,i); 
     }
     
     //
     //
     //
     //
     //
     
     for (i=limit; i>=0; i--) 
     {
        double deviations = iStdDevOnArray(hlr,0,BandsPeriod,0,mamode,i);
               bMi[i] = iMAOnArray(hlr,0,BandsPeriod,0,mamode,i);
               bUp[i] = bMi[i]+deviations*BandsDeviations;
               bDn[i] = bMi[i]-deviations*BandsDeviations;
               hlrDa[i] = EMPTY_VALUE;
               hlrDb[i] = EMPTY_VALUE;
               trend[i] = trend[i+1];
      
        if (hlr[i] > bMi[i]) trend[i] =  1;
        if (hlr[i] < bMi[i]) trend[i] = -1;
        if (MultiColor && trend[i] == -1) PlotPoint(i,hlrDa,hlrDb,hlr);
       
         
      }
      manageAlerts(); 
      return(0);
      }
      
      //
      //
      //
      //
      //
   
      limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
      if (MultiColor && trend[limit]==-1) CleanPoint(limit,hlrDa,hlrDb);
      for (i=limit; i>=0; i--)
      {
         int y = iBarShift(NULL,timeFrame,Time[i]);
            hlr[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HLR_Range,T3SmoothLength,T3Hot,T3Original,mamode,BandsPeriod,BandsDeviations,0,y);
            hlrDa[i] = EMPTY_VALUE;
            hlrDb[i] = EMPTY_VALUE;
            bUp[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HLR_Range,T3SmoothLength,T3Hot,T3Original,mamode,BandsPeriod,BandsDeviations,3,y);
            bMi[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HLR_Range,T3SmoothLength,T3Hot,T3Original,mamode,BandsPeriod,BandsDeviations,4,y);
            bDn[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HLR_Range,T3SmoothLength,T3Hot,T3Original,mamode,BandsPeriod,BandsDeviations,5,y);
            trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HLR_Range,T3SmoothLength,T3Hot,T3Original,mamode,BandsPeriod,BandsDeviations,6,y); 
        
            if (y==iBarShift(NULL,timeFrame,Time[i-1]) || !Interpolate) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
            {
               bUp[i+k] = bUp[i] + (bUp[i+n]-bUp[i])*k/n;
               bMi[i+k] = bMi[i] + (bMi[i+n]-bMi[i])*k/n;
               bDn[i+k] = bDn[i] + (bDn[i+n]-bDn[i])*k/n;
               hlr[i+k] = hlr[i] + (hlr[i+n]-hlr[i])*k/n;
            }               
      }
      if (MultiColor) for (i=limit;i>=0;i--) if (trend[i]==-1) PlotPoint(i,hlrDa,hlrDb,hlr);
      manageAlerts(); 
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

double workT3[][6];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
{
   if (ArrayRange(workT3,0) != Bars)                ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
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

//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"buy");
         if (trend[whichBar] ==-1) doAlert(whichBar,"sell");
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(timeFrame)+" T3 smooth HLR bands trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," T3 smooth HLR bands "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}




string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

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

string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}