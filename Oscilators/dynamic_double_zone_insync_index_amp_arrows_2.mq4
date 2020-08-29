//+------------------------------------------------------------------+
//|                                                     insync index |
//+------------------------------------------------------------------+
#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers    6
#property indicator_color1     DeepSkyBlue
#property indicator_color2     LimeGreen
#property indicator_color3     LimeGreen
#property indicator_color4     Red
#property indicator_color5     Red
#property indicator_color6     DimGray
#property indicator_style3     STYLE_DOT
#property indicator_style5     STYLE_DOT
#property indicator_style6     STYLE_DOT
#property indicator_width1     2
#property indicator_levelcolor DarkSlateGray

//
//
//
//
//

#import "dynamicZone.dll"
    double dzBuyP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i, double precision);
   double dzSellP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i, double precision);
#import

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame       = PERIOD_CURRENT;
extern bool               UseVolumeBasedIndicators = true;
extern int                DzLookBackBars           = 70;
extern double             DzStartBuyProbability1   = 0.10;
extern double             DzStartBuyProbability2   = 0.25;
extern double             DzStartSellProbability1  = 0.10;
extern double             DzStartSellProbability2  = 0.25;
extern double             alertsOn                 = false;
extern bool               alertsOnCurrent          = true;
extern bool               alertsMessage            = true;
extern bool               alertsSound              = false;
extern bool               alertsNotify             = false;
extern bool               alertsEmail              = false;
extern string             soundFile                = "alert2.wav";
extern bool               ShowArrows               = false;
extern string             arrowsIdentifier         = "dz insync Arrows1";
extern double             arrowsUpperGap           = 0.5;
extern double             arrowsLowerGap           = 0.5;
extern color              arrowsUpColor            = LimeGreen;
extern color              arrowsDnColor            = Red;
extern int                arrowsUpCode             = 241;
extern int                arrowsDnCode             = 242;
extern bool               Interpolate              = true;

extern double             levelOb                  = 40;
extern double             levelOs                  = -40;

//
//
//
//
//

double insync[];
double bl1[];
double bl2[];
double sl1[];
double sl2[];
double zl1[];
double trend[];
double correction = 0;
string indicatorFileName;
bool   returnBars;

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
   if (!UseVolumeBasedIndicators) correction=-10;
   IndicatorBuffers(7);
      SetIndexBuffer(0,insync);
      SetIndexBuffer(1,bl1);
      SetIndexBuffer(2,bl2);
      SetIndexBuffer(3,sl1);
      SetIndexBuffer(4,sl2);
      SetIndexBuffer(5,zl1);
      SetIndexBuffer(6,trend);
      SetLevelValue(0,levelOb);
      SetLevelValue(1,levelOs);

         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame==-99);
         TimeFrame         = MathMax(TimeFrame,_Period);
         
   IndicatorShortName(timeFrameToString(TimeFrame)+" dynamic double zone insync index");
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

double  work[][5];
#define macdSignal 0
#define rocData    1
#define dpoData    2
#define mfiData    3
#define eomData    4

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { insync[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame==Period())
   {
      if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         double insyncScore = 0;
      
         //
         //
         //
         //
         //
      
         double avg = iMA(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,i);
         double std = iStdDev(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,i); if (std==0) continue;
         double bos = (Close[i]-avg+2.0*std)/(4.0*std);
               if (bos < 0.05) insyncScore -=5;
               if (bos > 0.95) insyncScore +=5;
               
         double cci = iCCI(NULL,0,14,PRICE_TYPICAL,i);
               if (cci < -100) insyncScore -=5;
               if (cci >  100) insyncScore +=5;

         double rsi = iRSI(NULL,0,14,PRICE_CLOSE,i);
               if (rsi < 30) insyncScore -=5;
               if (rsi > 70) insyncScore +=5;
               
         double stoFastK = iStochastic(NULL,0,14,3,1,MODE_EMA,0,MODE_MAIN  ,i);
         double stoFastD = iStochastic(NULL,0,14,3,1,MODE_EMA,0,MODE_SIGNAL,i);
               if (stoFastK < 20) insyncScore -=5;
               if (stoFastK > 80) insyncScore +=5;
               if (stoFastD < 20) insyncScore -=5;
               if (stoFastD > 80) insyncScore +=5;
               
         double macd = iMA(NULL,0,12,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,25,0,MODE_EMA,PRICE_CLOSE,i);
                work[r][macdSignal] = work[r-1][macdSignal]+0.2*(macd-work[r-1][macdSignal]);
               if (work[r][macdSignal] < 0 && work[r][macdSignal] > macd) insyncScore -=5;
               if (work[r][macdSignal] > 0 && work[r][macdSignal] < macd) insyncScore +=5;
         
         //
         //
         //
         //
         //
         
            work[r][rocData] = Close[i]-Close[i+10];
                  double rocAvg = 0; for (k=0; k<10; k++) rocAvg += work[r-k][rocData]; rocAvg /= 10;
                     if (rocAvg < 0 && rocAvg > work[r][rocData]) insyncScore -=5;
                     if (rocAvg > 0 && rocAvg < work[r][rocData]) insyncScore +=5;

            work[r][dpoData] = Close[i]-iMA(NULL,0,18,0,MODE_SMA,PRICE_CLOSE,i+10);
                  double dpoAvg = 0; for (k=0; k<10; k++) dpoAvg += work[r-k][dpoData]; dpoAvg /= 10;
                     if (dpoAvg < 0 && dpoAvg > work[r][dpoData]) insyncScore -=5;
                     if (dpoAvg > 0 && dpoAvg < work[r][dpoData]) insyncScore +=5;
        
         //
         //
         //
         //    volume based indicators :
         //                   money flow index
         //                   ease of move index
         //
         //
         //
        
         if (UseVolumeBasedIndicators)
         { 
               work[r][mfiData] = iMA(NULL,0,1,0,MODE_SMA,PRICE_TYPICAL,i);
                  double sumMfp = 0;
                  double sumMft = 0;
                  for (k=0; k<14; k++)
                  {
                     sumMft += work[r-k][mfiData]+Volume[i+k];
                        if (work[r-k][mfiData]>work[r-k-1][mfiData]) sumMfp += work[r-k][mfiData]+Volume[i+k];
                  }
                  double mfi = 100.0*sumMfp/sumMft;
                     if (mfi < 20) insyncScore -=5;
                     if (mfi > 80) insyncScore +=5;

               //
               //
               //
               //
               //
            
               double eom = 0; for (k=0; k<13; k++) 
                      eom += 100*100.0*(High[i+k]-Low[i+k])/Volume[i+k]*(High[i+k]+Low[i+k]-High[i+k+1]-Low[i+k+1])*0.5;
               work[r][eomData] = eom/13;
               double eomAvg = 0;
                     for (k=0; k<10; k++) eomAvg += work[r-k][eomData]; eomAvg /= 10;
                     if (eomAvg < 0 && eomAvg > eom) insyncScore -=5;
                     if (eomAvg > 0 && eomAvg < eom) insyncScore +=5;
         }

         //
         //
         //
         //
         //

         insync[i]    = insyncScore;
         trend[i]     = trend[i+1];
               if (insync[i] > (levelOb + correction - Point))   trend[i] =  1;
               if (insync[i] < (levelOs - correction + Point))   trend[i] = -1;
  
               if (DzStartBuyProbability1  > 0) bl1[i] = dzBuyP (insync, DzStartBuyProbability1,  DzLookBackBars, Bars, i, 0.0001);
               if (DzStartBuyProbability2  > 0) bl2[i] = dzBuyP (insync, DzStartBuyProbability2,  DzLookBackBars, Bars, i, 0.0001);
               if (DzStartSellProbability1 > 0) sl1[i] = dzSellP(insync, DzStartSellProbability1, DzLookBackBars, Bars, i, 0.0001);
               if (DzStartSellProbability2 > 0) sl2[i] = dzSellP(insync, DzStartSellProbability2, DzLookBackBars, Bars, i, 0.0001);
                                                zl1[i] = dzSellP(insync, 0.5                    , DzLookBackBars, Bars, i, 0.0001);
               
               //
               //
               //
               //
               //
     
               if (ShowArrows)
               {
                  ObjectDelete(arrowsIdentifier+":"+Time[i]);
                  if (trend[i] != trend[i+1])
                  {
                     if (trend[i] == 1)  drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                     if (trend[i] ==-1)  drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                  }
               }
      }
      
      //
      //
      //
      //
      //
      
      if (alertsOn)
      {
         if (alertsOnCurrent)
              int whichBar = 0;
         else     whichBar = 1; 
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
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         insync[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UseVolumeBasedIndicators,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
         bl1[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UseVolumeBasedIndicators,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,1,y);
         bl2[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UseVolumeBasedIndicators,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,2,y);
         sl1[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UseVolumeBasedIndicators,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,3,y);
         sl2[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UseVolumeBasedIndicators,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,4,y);
         zl1[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UseVolumeBasedIndicators,DzLookBackBars,DzStartBuyProbability1,DzStartBuyProbability2,DzStartSellProbability1,DzStartSellProbability2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,5,y);
         
         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,TimeFrame,y);
            for(int w = 1; i+w < Bars && Time[i+w] >= time; w++) continue;	
            for(int x = 1; x < w; x++)
            {
               insync[i+x] = insync[i] + (insync[i+w] - insync[i]) * x/w;
               bl1[i+x]    = bl1[i]    + (bl1[i+w]    - bl1[i])    * x/w;
               bl2[i+x]    = bl2[i]    + (bl2[i+w]    - bl2[i])    * x/w;
               sl1[i+x]    = sl1[i]    + (sl1[i+w]    - sl1[i])    * x/w;
               sl2[i+x]    = sl2[i]    + (sl2[i+w]    - sl2[i])    * x/w;
               zl1[i+x]    = zl1[i]    + (zl1[i+w]    - zl1[i])    * x/w;
           }
    }
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

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

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

          message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," dynamic zone insync index ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," dynamic zone insync index "),message);
             if (alertsSound)   PlaySound(soundFile);
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
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}