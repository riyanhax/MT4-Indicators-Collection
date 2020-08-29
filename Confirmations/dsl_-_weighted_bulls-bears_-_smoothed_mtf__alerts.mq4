//------------------------------------------------------------------
//
//
//
//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers   7
#property indicator_color1  clrDimGray
#property indicator_color2  clrDimGray
#property indicator_color3  clrGreen
#property indicator_color4  clrGreen
#property indicator_color5  clrRed
#property indicator_color6  clrRed
#property indicator_color7  clrDimGray
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_width3  2
#property indicator_width5  2
#property indicator_width7  2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame       = PERIOD_CURRENT; // Time frame to use
extern int                CalcPeriod      = 50;             // Calculation period
extern ENUM_APPLIED_PRICE CalcPrice       = PRICE_CLOSE;    // Price
extern ENUM_MA_METHOD     CalcMaMethod    = MODE_SMA;       // Average method for price smoothing
extern int                CalcMaPeriod    = 1;              // Period for price smoothing
extern double             DslSignal       = 9;              // Signal period
extern bool               AlertsOn        = false;          // Turn alerts on?
extern bool               AlertsOnCurrent = true;           // Alerts on current (still opened) bar?
extern bool               AlertsOnZero    = true;           // Alerts on zero cross?
extern bool               AlertsOnSignal  = true;           // Alerts on signal cross?
extern bool               AlertsMessage   = true;           // Alerts should show pop-up message?
extern bool               AlertsSound     = false;          // Alerts should play alert sound?
extern bool               AlertsPushNotif = false;          // Alerts should send push notification?
extern bool               AlertsEmail     = false;          // Alerts should send email?
extern bool               ShowHisto       = true;           // Display histogram?
extern bool               Interpolate     = true;           // Interpolate in multi time frame?

//
//
//
//
//

double   buffer1[],buffer2[],buffer3[],buffer4[],buffer5[],prices[],levelu[],leveld[],trendz[],trends[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CalcPeriod,CalcPrice,CalcMaMethod,CalcMaPeriod,DslSignal,AlertsOn,AlertsOnCurrent,AlertsOnZero,AlertsOnSignal,AlertsMessage,AlertsSound,AlertsPushNotif,AlertsEmail,_buff,_ind)


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
   IndicatorBuffers(11);
   SetIndexBuffer( 0,levelu);
   SetIndexBuffer( 1,leveld);
   SetIndexBuffer( 2,buffer1); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer( 3,buffer2); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer( 4,buffer3); SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer( 5,buffer4); SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer( 6,buffer5);
   SetIndexBuffer( 7,trendz);
   SetIndexBuffer( 8,trends);
   SetIndexBuffer( 9,count);
   SetIndexBuffer(10,prices);
         indicatorFileName = WindowExpertName();
         TimeFrame         = MathMax(TimeFrame,_Period);
      IndicatorShortName(timeFrameToString(TimeFrame)+" Weighted bulls/bears ("+(string)CalcPeriod+","+(string)CalcMaPeriod+","+(string)DslSignal+")");
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
         int limit = MathMin(Bars-counted_bars,Bars-1); count[0] = limit;
            if (TimeFrame != Period())
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(9,0)*TimeFrame/_Period));
               for(int i=limit; i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  levelu[i]  = _mtfCall(0,y);
                  leveld[i]  = _mtfCall(1,y);
                  buffer1[i] = _mtfCall(2,y);
                  buffer2[i] = _mtfCall(3,y);
                  buffer3[i] = _mtfCall(4,y);
                  buffer4[i] = _mtfCall(5,y);
                  buffer5[i] = _mtfCall(6,y);
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime itime = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= itime; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
                        {
                          _interpolate(levelu);                      
                          _interpolate(leveld);                      
                          _interpolate(buffer5);                      
                           if (buffer1[i+k]!=EMPTY_VALUE) buffer1[i+k]=buffer5[i+k];
                           if (buffer2[i+k]!=EMPTY_VALUE) buffer2[i+k]=buffer5[i+k];
                           if (buffer3[i+k]!=EMPTY_VALUE) buffer3[i+k]=buffer5[i+k];
                           if (buffer4[i+k]!=EMPTY_VALUE) buffer4[i+k]=buffer5[i+k];
                        }                          
               }
               return(0);
            }            

   //
   //
   //
   //
   //

   double alpha = 2.0/(1.0+DslSignal);
      for(int i=limit; i>=0; i--)
      {
         prices[i] = iMA(NULL,0,CalcMaPeriod,0,CalcMaMethod,CalcPrice,i);
         int    hbar = ArrayMaximum(prices,CalcPeriod,i); double hval=prices[hbar];
         int    lbar = ArrayMinimum(prices,CalcPeriod,i); double lval=prices[lbar];
         double bear = -weight(hval-prices[i],hbar-i+1);
         double bull = +weight(prices[i]-lval,lbar-i+1);
         
         buffer5[i] = bull*2+bear*2;
         levelu[i] = (i<Bars-1) ? (buffer5[i]>0) ? levelu[i+1]+alpha*(buffer5[i]-levelu[i+1]) : levelu[i+1] : 50;
         leveld[i] = (i<Bars-1) ? (buffer5[i]<0) ? leveld[i+1]+alpha*(buffer5[i]-leveld[i+1]) : leveld[i+1] : 50;
         trends[i] = (buffer5[i]>levelu[i]) ? 1 : (buffer5[i]<leveld[i]) ? -1 : 0;
         trendz[i] = (buffer5[i]>0) ? 1 : (buffer5[i]<0) ? -1 : 0;
               if (i<(Bars-1) && ShowHisto)
               {
                  buffer1[i]=EMPTY_VALUE;
                  buffer2[i]=EMPTY_VALUE;
                  buffer3[i]=EMPTY_VALUE;
                  buffer4[i]=EMPTY_VALUE;
                  
                  if(buffer5[i]<leveld[i])
                  {
                     if (buffer5[i]<buffer5[i+1]) buffer3[i]=buffer5[i];
                     if (buffer5[i]>buffer5[i+1]) buffer4[i]=buffer5[i];
                  }
                  if(buffer5[i]>levelu[i])
                  {
                     if (buffer5[i]<buffer5[i+1]) buffer2[i]=buffer5[i];
                     if (buffer5[i]>buffer5[i+1]) buffer1[i]=buffer5[i];
                  }
               }                  
      }
   manageAlerts(trendz,trends);      
   return(0);
}


double weight(double range, double dist) { return(range+range/dist); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//


void manageAlerts(const double& _trendz[], const double& _trends[])
{
   if (AlertsOn)
   {
      int whichBar = (AlertsOnCurrent) ? 0 : 1;
      static datetime _timez = 0;
      static string   _messz = "";
         if (AlertsOnZero && _trendz[whichBar] != _trendz[whichBar+1])
         {
            if (_trendz[whichBar] ==  1) doAlert(_timez,_messz,whichBar," crossed zero line up");
            if (_trendz[whichBar] == -1) doAlert(_timez,_messz,whichBar," crossed zero line down");
         }
      static datetime _times = 0;
      static string   _messs = "";
         if (AlertsOnSignal && _trends[whichBar] != _trends[whichBar+1])
         {
            if (_trends[whichBar] ==  1)                            doAlert(_timez,_messz,whichBar," crossed upper signal line up");
            if (_trends[whichBar] == -1)                            doAlert(_timez,_messz,whichBar," crossed lower signal line down");
            if (_trends[whichBar] !=  1 && _trends[whichBar+1]== 1) doAlert(_timez,_messz,whichBar," crossed upper signal line down");
            if (_trends[whichBar] != -1 && _trends[whichBar+1]==-1) doAlert(_timez,_messz,whichBar," crossed lower signal line up");
         }
   }
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

       message = timeFrameToString(_Period)+" - "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" dsl weighted bulls/bears "+doWhat;
          if (AlertsMessage)   Alert(message);
          if (AlertsEmail)     SendMail(_Symbol+" dsl weighted bulls/bears",message);
          if (AlertsPushNotif) SendNotification(message);
          if (AlertsSound)     PlaySound("alert2.wav");
   }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}