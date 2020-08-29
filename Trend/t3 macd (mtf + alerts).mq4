#property link      "www.forex-station.com"      
#property copyright "www.forex-station.com"      

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrDimGray
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES   TimeFrame       = PERIOD_CURRENT; // Time frame
input int                T3Period1       = 13;             // Fast period
input double             T3Hot1          = 0.7;            // Fast hot
input ENUM_APPLIED_PRICE T3Price1        = PRICE_CLOSE;    // Fast price
input bool               T3Original1     = true;           // Fast original
input int                T3Period2       = 20;             // Slow period
input double             T3Hot2          = 0.6;            // Slow hot
input ENUM_APPLIED_PRICE T3Price2        = PRICE_CLOSE;    // Slow price
input bool               T3Original2     = true;           // Slow original
input bool               alertsOn        = false;          // Alerts on?
input bool               alertsOnCurrent = true;           // Alerts on open bar true/false?
input bool               alertsMessage   = true;           // Alerts pop-up message true/false?
input bool               alertsSound     = false;          // Alerts sound true/false?
input bool               alertsPushNotif = false;          // Alerts push notification true/false?
input bool               alertsEmail     = false;          // Alerts email true/false?
input bool               Interpolate     = true;           // Interpolate in mtf mode

double macd[],UpH[],DnH[],state[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,0,T3Period1,T3Hot1,T3Price1,T3Original1,T3Period2,T3Hot2,T3Price2,T3Original2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,_buff,_ind)
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
   IndicatorBuffers(5);
   SetIndexBuffer(0,UpH, INDICATOR_DATA);  SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DnH, INDICATOR_DATA);  SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,macd,INDICATOR_DATA);  SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,state);
   SetIndexBuffer(4,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   
   IndicatorShortName(timeFrameToString(TimeFrame)+" T3 macd");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {    }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& time[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[])
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; count[0]=i;

   //
   //
   //
   //
   //

   if (TimeFrame == _Period)
   {
      for (; i>=0 && !_StopFlag; i--) 
      {
         macd[i]  = iT3(iMA(NULL,0,1,0,MODE_SMA,T3Price1,i),T3Period1,T3Hot1,T3Original1,i,rates_total,0)-
                    iT3(iMA(NULL,0,1,0,MODE_SMA,T3Price2,i),T3Period2,T3Hot2,T3Original2,i,rates_total,1);
         state[i] = (i<rates_total-1) ? (macd[i]>0)  ? 1 : (macd[i]<0) ? -1 : state[i+1] : 0;
         UpH[i] = (state[i] == 1) ? macd[i] : EMPTY_VALUE;
         DnH[i] = (state[i] ==-1) ? macd[i] : EMPTY_VALUE;
      }
      manageAlerts();
   return(rates_total);
   }
   
   //
   //
   //
   //
   //
   
   i = (int)fmax(i,fmin(rates_total-1,_mtfCall(4,0)*TimeFrame/_Period));
   for (; i>=0 && !_StopFlag; i--) 
   {
      int y = iBarShift(NULL,TimeFrame,time[i]);
         UpH[i]  = _mtfCall(0,y);
         DnH[i]  = _mtfCall(1,y);
         macd[i] = _mtfCall(2,y);

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
               _interpolate(macd);
  	            if (UpH[i]!= EMPTY_VALUE) UpH[i+k] = macd[i+k];
  	            if (DnH[i]!= EMPTY_VALUE) DnH[i+k] = macd[i+k];
            }            
     }
return(rates_total);
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
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (state[whichBar] != state[whichBar+1])
      {
         if (state[whichBar] ==  1) doAlert(whichBar,"up");
         if (state[whichBar] == -1) doAlert(whichBar,"down");
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
       
       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" t3 macd "+doWhat;
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(_Symbol+" t3 macd ",message);
          if (alertsPushNotif) SendNotification(message);
          if (alertsSound)     PlaySound("alert2.wav");
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

#define t3Instances 2
double workT3[][t3Instances*6];
double workT3Coeffs[][6];
#define _tperiod 0
#define _c1      1
#define _c2      2
#define _c3      3
#define _c4      4
#define _alpha   5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int bars, int tinstanceNo=0)
{
   if (ArrayRange(workT3,0) != bars)                 ArrayResize(workT3,bars);
   if (ArrayRange(workT3Coeffs,0) < (tinstanceNo+1)) ArrayResize(workT3Coeffs,tinstanceNo+1);

   if (workT3Coeffs[tinstanceNo][_tperiod] != period)
   {
     workT3Coeffs[tinstanceNo][_tperiod] = period;
        double a = hot;
            workT3Coeffs[tinstanceNo][_c1] = -a*a*a;
            workT3Coeffs[tinstanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[tinstanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[tinstanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[tinstanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[tinstanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int instanceNo = tinstanceNo*6;
   int r = bars-i-1;
   if (r == 0)
      {
         workT3[r][0+instanceNo] = price;
         workT3[r][1+instanceNo] = price;
         workT3[r][2+instanceNo] = price;
         workT3[r][3+instanceNo] = price;
         workT3[r][4+instanceNo] = price;
         workT3[r][5+instanceNo] = price;
      }
   else
      {
         workT3[r][0+instanceNo] = workT3[r-1][0+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(price                  -workT3[r-1][0+instanceNo]);
         workT3[r][1+instanceNo] = workT3[r-1][1+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][0+instanceNo]-workT3[r-1][1+instanceNo]);
         workT3[r][2+instanceNo] = workT3[r-1][2+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][1+instanceNo]-workT3[r-1][2+instanceNo]);
         workT3[r][3+instanceNo] = workT3[r-1][3+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][2+instanceNo]-workT3[r-1][3+instanceNo]);
         workT3[r][4+instanceNo] = workT3[r-1][4+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][3+instanceNo]-workT3[r-1][4+instanceNo]);
         workT3[r][5+instanceNo] = workT3[r-1][5+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][4+instanceNo]-workT3[r-1][5+instanceNo]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[tinstanceNo][_c1]*workT3[r][5+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c2]*workT3[r][4+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c3]*workT3[r][3+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c4]*workT3[r][2+instanceNo]);
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