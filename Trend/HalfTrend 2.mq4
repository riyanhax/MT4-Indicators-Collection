//+----------------------------------------------------------------------+
//|                                                        HalfTrend.mq4 |
//+----------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 DodgerBlue  // up[]
#property indicator_width1 3
#property indicator_color2 Red       // down[]
#property indicator_width2 3
#property indicator_color3 DodgerBlue  // atrlo[]
#property indicator_width3 1
#property indicator_color4 Red       // atrhi[]
#property indicator_width4 1
#property indicator_color5 DodgerBlue  // arrup[]
#property indicator_width5 2
#property indicator_color6 Red      // arrdwn[]
#property indicator_width6 2

extern ENUM_TIMEFRAMES TimeFrame  = PERIOD_CURRENT;
extern int    Amplitude           = 2.0;
extern bool   alertsOn            = true;
extern bool   alertsOnCurrent     = false;
extern bool   alertsMessage       = true;
extern bool   alertsNotification  = true;//false;
extern bool   alertsSound         = true;
extern bool   alertsEmail         = false;

extern bool   ShowBars            = false;//true;
extern bool   ShowArrows          = true;
extern int    arrowSize           = 2;
extern int    uparrowCode         = 233;
extern int    dnarrowCode         = 234;
extern bool   ArrowsOnFirstBar    = true;

double up[],down[],atrlo[],atrhi[],trend[];
double arrup[],arrdwn[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7); // +1 buffer - trend[]
   SetIndexBuffer(0,up);
   SetIndexBuffer(1,down);
   SetIndexBuffer(2,atrlo);
   SetIndexBuffer(3,atrhi);
   SetIndexBuffer(4,arrup);
   SetIndexBuffer(5,arrdwn);
   SetIndexBuffer(6,trend);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(6,0.0);
   
   if(ShowBars)
   {
      SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID);
      SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_SOLID);
   }
   else
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }
   if (ShowArrows)
   {
     SetIndexStyle(4,DRAW_ARROW,0,arrowSize); SetIndexArrow(4,uparrowCode);
     SetIndexStyle(5,DRAW_ARROW,0,arrowSize); SetIndexArrow(5,dnarrowCode);   
   }
   else
   {
     SetIndexStyle(4,DRAW_NONE);
     SetIndexStyle(5,DRAW_NONE);
   }        
          
     
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame == -99;
   TimeFrame         = MathMax(TimeFrame,_Period);
return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFix { } ExtFix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{  int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { up[0] = limit+1; return(0); }
            if (TimeFrame!=Period())
            {
               int shift = -1; if (ArrowsOnFirstBar) shift=1;
               limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
               for (int i=limit; i>=0; i--)
               {
                   int y = iBarShift(NULL,TimeFrame,Time[i]);  
                   int x = iBarShift(NULL,TimeFrame,Time[i+shift]);             
                      up[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Amplitude,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,0,y);             
                      down[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Amplitude,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,1,y);
                      atrlo[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Amplitude,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,2,y);             
                      atrhi[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Amplitude,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,3,y);  
                   if(x!=y)
                   {
                     arrup[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Amplitude,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,4,y);             
                     arrdwn[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Amplitude,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,5,y);         
                   }
                   else
                   {
                     arrup[i]  = EMPTY_VALUE;
                     arrdwn[i] = EMPTY_VALUE;
                   }
               }
               return(0);
            }
   double atr,lowprice_i,highprice_i,lowma,highma;
   int workbar=0;
  
   double nexttrend=0,maxlowprice=Low[Bars-1],minhighprice=High[Bars-1];
   for(i=Bars-1; i>=0; i--)
     {
      lowprice_i=iLow(Symbol(),Period(),iLowest(Symbol(),Period(),MODE_LOW,Amplitude,i));
      highprice_i=iHigh(Symbol(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,Amplitude,i));
      lowma=NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_LOW,i),Digits());
      highma=NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_HIGH,i),Digits());
      trend[i]=trend[i+1];
      atr=iATR(Symbol(),0,100,i)/2;

      arrup[i]  = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;
      if(nexttrend==1)
        {
         maxlowprice=MathMax(lowprice_i,maxlowprice);

         if(highma<maxlowprice && Close[i]<Low[i+1])
           {
            trend[i]=1.0;
            nexttrend=0;
            minhighprice=highprice_i;
           }
        }
      if(nexttrend==0)
        {
         minhighprice=MathMin(highprice_i,minhighprice);

         if(lowma>minhighprice && Close[i]>High[i+1])
           {
            trend[i]=0.0;
            nexttrend=1;
            maxlowprice=lowprice_i;
           }
        }
      if(trend[i]==0.0)
        {
         if(trend[i+1]!=0.0)
           {
            up[i]=down[i+1];
            up[i+1]=up[i];
            arrup[i] = up[i] - 2*atr;
           }
         else
           {
            up[i]=MathMax(maxlowprice,up[i+1]);
           }
         atrhi[i] = up[i] - atr;
         atrlo[i] = up[i];
         down[i]=0.0;
        }
      else
        {
         if(trend[i+1]!=1.0)
           {
            down[i]=up[i+1];
            down[i+1]=down[i];
            arrdwn[i] = down[i] + 2*atr;           
           }
         else
           {
            down[i]=MathMin(minhighprice,down[i+1]);
           }
         atrhi[i] = down[i] + atr;
         atrlo[i] = down[i];
         up[i]=0.0;
        }
     }
     manageAlerts();
   return (0);
  }
  
//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
         if (arrup[whichBar]  != EMPTY_VALUE) doAlert(whichBar,"up");
         if (arrdwn[whichBar] != EMPTY_VALUE) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," HalfTrend ",doWhat);
          if (alertsMessage)      Alert(message);
          if (alertsEmail)        SendMail(StringConcatenate(Symbol(),"HalfTrend "),message);
          if (alertsNotification) SendNotification(message);
          if (alertsSound)        PlaySound("alert2.wav");
   }
}