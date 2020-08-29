//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 PaleVioletRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_minimum -1
#property indicator_maximum  1

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    MaPeriod        = 5;
extern int    MaFilterPass    = 1;
extern int    MaShift         = 0;
extern int    UpperPrice      = PRICE_HIGH;
extern int    LowerPrice      = PRICE_LOW;
extern double Deviation       = 0.2;
extern bool   Interpolate     = true;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double UpLine[];
double DnLine[]; 
double UpArrow[];
double DnArrow[]; 
double smax[];
double smin[];
double trend[];

//
//
//
//
//

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

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
   IndicatorBuffers(5);
      SetIndexBuffer(0,UpLine); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,DnLine); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,smax);
      SetIndexBuffer(3,smin);
      SetIndexBuffer(4,trend);
   
      //
      //
      // 
      //
      //
   
         MaFilterPass      = MathMax(MathMin(MaFilterPass,48),1);
         MaPeriod          = MathMax(MaPeriod,2);
         Deviation         = MathMax(MathMin(Deviation,100),0.0);
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
 
         for (int i=0;i<4;i++) SetIndexShift(i,MaShift*timeFrame/Period());
   IndicatorShortName(timeFrameToString(timeFrame)+" trend envelopes("+MaPeriod+")");
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

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { UpLine[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      for(i=limit; i>=0; i--)
      { 
         smax[i]    = (1+Deviation/100)*iMultiPassMa(iMA(NULL,0,1,0,MODE_SMA,UpperPrice,i),MaPeriod,MaFilterPass,i,0);
         smin[i]    = (1-Deviation/100)*iMultiPassMa(iMA(NULL,0,1,0,MODE_SMA,LowerPrice,i),MaPeriod,MaFilterPass,i,1);
         UpLine[i]  = EMPTY_VALUE;
         DnLine[i]  = EMPTY_VALUE;
         trend[i]   = trend[i+1]; 
   
         //
         //
         //
         //
         //
         
	      if (Close[i]>smax[i+1]) trend[i]= 1; 
	      if (Close[i]<smin[i+1]) trend[i]=-1;
	      if (trend[i]>0 && smin[i]<smin[i+1]) smin[i]=smin[i+1];
	      if (trend[i]<0 && smax[i]>smax[i+1]) smax[i]=smax[i+1];
         if (trend[i] == 1) UpLine[i] =  1;
         if (trend[i] ==-1) DnLine[i] = -1;
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         UpLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaPeriod,MaFilterPass,MaShift,UpperPrice,LowerPrice,Deviation,0,y);
         DnLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaPeriod,MaFilterPass,MaShift,UpperPrice,LowerPrice,Deviation,1,y);
         trend[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MaPeriod,MaFilterPass,MaShift,UpperPrice,LowerPrice,Deviation,4,y);
   }
   manageAlerts();
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

double workMpFilter[][50][2];
double iMultiPassMa(double price, int period, int filterPass, int i, int instanceNo=0)
{ 
   if (ArrayRange(workMpFilter,0) != Bars) ArrayResize(workMpFilter,Bars); i = Bars-i-1; 

   double ma = 0;
   for (int p=0; p<filterPass; p++)
   {
      if (p==0) workMpFilter[i][0][instanceNo] = price;
      if (i>=period)
               ma = workMpFilter[i-1][p+1][instanceNo]+(workMpFilter[i][p][instanceNo]-workMpFilter[i-period][p][instanceNo])/period;
      else {   ma = workMpFilter[i][p][instanceNo]; for (int k=1; k<period && (i-k)>=0; k++) ma += workMpFilter[i-k][p][instanceNo];
                                                                                             ma /= k; }
      workMpFilter[i][p+1][instanceNo] = ma;
   }               
   return(ma);
}      


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," trend envelope changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)),message);
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
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

string stringUpperCase(string str)
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