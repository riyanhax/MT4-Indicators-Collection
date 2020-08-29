//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrDimGray
#property indicator_color2  clrGray
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrPaleVioletRed
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_style1  STYLE_DOT
#property indicator_level1  0

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame    = PERIOD_CURRENT;     // Time frame
extern int    TTFbars               =   15;
extern int    topLine               =  100;
extern int    bottomLine            = -100;
extern double t3Period              =    3;
extern double t3Hot                 =  0.7;
extern bool   t3Original            = false;
extern bool   showTopBottomLevels   = true;
extern bool   showSignals           = true;
extern bool   alertsOn              = false;
extern bool   alertsOnCurrent       = true;
extern bool   alertsMessage         = true;
extern bool   alertsSound           = false;
extern bool   alertsEmail           = false;
extern bool   arrowsVisible         = false;
extern bool   arrowsOnNewest        = true;           // Arrows drawn on newest bar of higher time frame bar?
extern string arrowsIdentifier      = "TrendScalpArrows";
extern bool   arrowsOnZeroCross     = false;
extern bool   arrowsOnLevelsBreak   = true;
extern bool   arrowsOnLevelsRetrace = false;
extern color  arrowsUpColor         = clrDeepSkyBlue;
extern color  arrowsDnColor         = clrRed;
extern bool   Interpolate           = true;               // Interpolate in multi time frame mode true/false?

//
//
//
//
//

double ttf[],lev[],sigu[],sigd[],trend[],trends[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,TTFbars,topLine,bottomLine,t3Period,t3Hot,t3Original,showTopBottomLevels,showSignals,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsOnZeroCross,arrowsOnLevelsBreak,arrowsOnLevelsRetrace,arrowsUpColor,arrowsDnColor,_buff,_ind)

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,lev);  SetIndexStyle(0,DRAW_LINE);
      SetIndexBuffer(1,ttf);  SetIndexStyle(1,DRAW_LINE);
      SetIndexBuffer(2,sigu); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,159);
      SetIndexBuffer(3,sigd); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159);
      SetIndexBuffer(4,trend);
      SetIndexBuffer(5,trends);
      SetIndexBuffer(6,count);
      
      indicatorFileName = WindowExpertName();
      TimeFrame         = fmax(TimeFrame,_Period);
      
      IndicatorShortName(timeFrameToString(TimeFrame)+" Trend scalp ("+(string)TTFbars+","+(string)t3Period+")");
    return(0);
}
int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
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
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(6,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     lev[i]    = _mtfCall(0,y);
                     ttf[i]    = _mtfCall(1,y);
                     trend[i]  = _mtfCall(4,y);
                     trends[i] = _mtfCall(5,y);
                     
                     if (showTopBottomLevels)
                     {
                        trend[i] = trend[i+1];
                        if (ttf[i]>0) trend[i] =  1;
                        if (ttf[i]<0) trend[i] = -1;
                        if (trend[i]== 1) lev[i] = topLine;
                        if (trend[i]==-1) lev[i] = bottomLine;
                     }
      
                     if (showSignals)
                     {
                        trends[i] = 0;
                        if (ttf[i] > topLine)    trends[i] =  1;
                        if (ttf[i] < bottomLine) trends[i] = -1;
                        if (trends[i]== 1) sigu[i] = topLine;
                        if (trends[i]==-1) sigd[i] = bottomLine;
                     }
                    
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
                        {
                            _interpolate(lev);
                            _interpolate(ttf);
                         }
               }       
   return(0);
   }               

   //
   //
   //
   //
   //
   
   for(i=limit; i >= 0; i--)
   {
      double HighestHighRecent = High[i]; double HighestHighOlder = High[iHighest(NULL,0,MODE_HIGH,TTFbars,i+1)];
      double LowestLowRecent   = Low[i];  double LowestLowOlder   = Low[iLowest(NULL,0,MODE_LOW,TTFbars,i+1)];
      
         double BuyPower  = HighestHighRecent-LowestLowOlder;
         double SellPower = HighestHighOlder -LowestLowRecent;
               ttf[i] = iT3((BuyPower-SellPower)/(0.5*(BuyPower+SellPower))*100.0,t3Period,t3Hot,t3Original,i,Bars);
      
      //
      //
      //
      //
      //
         
      trend[i] = trend[i+1];
         if (ttf[i] > 0) trend[i] =  1;
         if (ttf[i] < 0) trend[i] = -1;
         if (showTopBottomLevels)
         {
            if (trend[i]== 1) lev[i] = topLine;
            if (trend[i]==-1) lev[i] = bottomLine;
         }
      
      trends[i] = 0;
         if (ttf[i] > topLine)    trends[i] =  1;
         if (ttf[i] < bottomLine) trends[i] = -1;
         if (showSignals)
         {
            sigu[i] = EMPTY_VALUE;
            sigd[i] = EMPTY_VALUE;
               if (trends[i]== 1) sigu[i] = topLine;
               if (trends[i]==-1) sigd[i] = bottomLine;
         }
      manageArrow(i);
   }
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

#define t3Instances 1
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," "," trend scalp trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"trend scalp "),message);
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

void manageArrow(int i)
{
   if (arrowsVisible)
   {
      deleteArrow(Time[i]);
      if (arrowsOnZeroCross && trend[i]!=trend[i+1])
      {
         if (trend[i] ==  1) drawArrow(i,arrowsUpColor,241,false);
         if (trend[i] == -1) drawArrow(i,arrowsDnColor,242,true);
      }
      if (arrowsOnLevelsBreak || arrowsOnLevelsRetrace)
      if (trends[i]!=trends[i+1])
      {
         if (arrowsOnLevelsBreak   && trends[i] == 1)                      drawArrow(i,arrowsUpColor,241,false);
         if (arrowsOnLevelsBreak   && trends[i] ==-1)                      drawArrow(i,arrowsDnColor,242,true);
         if (arrowsOnLevelsRetrace && trends[i] != 1 && trends[i+1] ==  1) drawArrow(i,arrowsDnColor,242,true);
         if (arrowsOnLevelsRetrace && trends[i] !=-1 && trends[i+1] == -1) drawArrow(i,arrowsUpColor,241,false);
      }
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      datetime time = Time[i]; if (arrowsOnNewest) time += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
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


