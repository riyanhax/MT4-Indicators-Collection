//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DimGray
#property indicator_color2  DeepSkyBlue
#property indicator_color3  PaleVioletRed
#property indicator_color4  LimeGreen
#property indicator_color5  Gold
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_width4  2

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

extern int    KSTType                = 1;
extern int    KSTMaType              = 1;
extern int    KSTSignalMaPeriod      = 9;
extern double SmoothPhase            = 0;
extern int    DzLookBackBars         = 35;
extern double DzStartBuyProbability  = 0.05;
extern double DzStartSellProbability = 0.05;
extern color  ColorUp                = Lime;
extern color  ColorDown              = Red;
extern string ColorUniqueID          = "dz kst";
extern int    ColorWidth             = 2;
extern int    ColorBars              = 1000;
extern bool   barsVisible            = true;
extern int    widthWick              = 0;
extern int    widthBody              = 2;
extern bool   drawInBackgound        = false;

extern bool   alertsOn               = true;
extern bool   alertsOnCurrent        = false;
extern bool   alertsOnSignalCross    = true;
extern bool   alertsOnZeroCross      = true;
extern bool   alertsOnSlope          = true;
extern bool   alertsMessage          = true;
extern bool   alertsSound            = true;
extern bool   alertsNotify           = false;
extern bool   alertsEmail            = false;
extern string soundFile              = "alert2.wav";
//
//
//
//
//

double obLine[];
double osLine[];
double zeroLine[];
double ratios[];
double kst[];
double kstSignal[];
double trend[];
double slope[];
double value[];
double paramr[4];
double paramm[4];
double koef = 1;
string shortName = "";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int window;
int init()
{
   KSTType   = MathMax(MathMin(KSTType  ,2),0);   
   KSTMaType = MathMax(MathMin(KSTMaType,1),0);   
   
   //
   //
   //
   //
   //
   
     switch (KSTMaType)
     {
         case 0 :
            switch (KSTType)
            {
               case 0 :
                     paramr[0] = 10; paramr[1] = 15; paramr[2] = 20; paramr[3] = 30; 
                     paramm[0] = 10; paramm[1] = 10; paramm[2] = 10; paramm[3] = 15;
                     shortName = ColorUniqueID+": ""Short term SMA";
                     break;
               case 1 :                     
                     paramr[0] = 10; paramr[1] = 13; paramr[2] = 15; paramr[3] = 20;
                     paramm[0] = 10; paramm[1] = 13; paramm[2] = 15; paramm[3] = 20;
                     shortName = ColorUniqueID+": ""Intermediate term SMA";
                     break;
               case 2:                     
                     paramr[0] =  9; paramr[1] = 12; paramr[2] = 18; paramr[3] = 24;
                     paramm[0] =  6; paramm[1] =  6; paramm[2] =  6; paramm[3] =  9; koef = 4;
                     shortName = ColorUniqueID+": ""Long term SMA";
                     break;
            }
            break;

         //
         //
         //
         //
         //
                     
         case 1 :            
            switch (KSTType)
            {
               case 0 :
                     paramr[0] = 3; paramr[1] = 4; paramr[2] = 6; paramr[3] = 10; 
                     paramm[0] = 3; paramm[1] = 4; paramm[2] = 6; paramm[3] =  8;
                     shortName = ColorUniqueID+": ""Short term EMA";
                     break;
               case 1 :                     
                     paramr[0] = 10; paramr[1] = 13; paramr[2] = 15; paramr[3] = 20;
                     paramm[0] = 10; paramm[1] = 13; paramm[2] = 15; paramm[3] = 20;
                     shortName = ColorUniqueID+": ""Intermediate term EMA";
                     break;
               case 2:                     
                     paramr[0] = 39; paramr[1] = 52; paramr[2] = 78; paramr[3] = 109;
                     paramm[0] = 26; paramm[1] = 26; paramm[2] = 26; paramm[3] =  39;
                     shortName = ColorUniqueID+": ""Long term EMA";
                     break;
            }
      }
      
      //
      //
      //
      //
      //
      
      IndicatorBuffers(9);
      SetIndexBuffer(0,zeroLine);  SetIndexLabel(0,NULL);
      SetIndexBuffer(1,obLine);    SetIndexLabel(1,NULL);
      SetIndexBuffer(2,osLine);    SetIndexLabel(2,NULL);
      SetIndexBuffer(3,kst);
      SetIndexBuffer(4,kstSignal);
      SetIndexBuffer(5,ratios); 
      SetIndexBuffer(6,slope);
      SetIndexBuffer(7,trend);
      SetIndexBuffer(8,value);
      IndicatorShortName(shortName);
   return(0);
}

//
//
//
//
//

int deinit()
{
      int lookForLength = StringLen(ColorUniqueID);
      for (int i=ObjectsTotal()-1; i>=0; i--) 
      {
         string name = ObjectName(i);  if (StringSubstr(name,0,lookForLength) == ColorUniqueID) ObjectDelete(name);
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

double work[][4];

int start()
{
   window = WindowFind(shortName);
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
      
      //
      //
      //
      //
      //
           
      int i,r;
      int cb = ColorBars; if (ColorBars==0) cb = Bars-1; cb = MathMin(Bars-1,cb);
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         for (int k=0; k<4; k++) work[r][k] = iROC(paramr[k],i);
         if (KSTMaType==0)
               kst[i] = (iSMA(0,r)+iSMA(1,r)*2.0+iSMA(2,r)*3.0+iSMA(3,r)*4.0)/koef;
         else  kst[i] = (iEMA(0,r)+iEMA(1,r)*2.0+iEMA(2,r)*3.0+iEMA(3,r)*4.0)/koef;
      
         double sum = 0; for (k=0; k<KSTSignalMaPeriod; k++) sum += kst[i+k];
               kstSignal[i] = sum/KSTSignalMaPeriod; 
               obLine[i]    = dzBuyP (kst, DzStartBuyProbability,  DzLookBackBars, Bars, i, 0.00001);
               osLine[i]    = dzSellP(kst, DzStartSellProbability, DzLookBackBars, Bars, i, 0.00001);
               zeroLine[i]  = dzSellP(kst, 0.5,                    DzLookBackBars, Bars, i, 0.00001);
               ratios[i]    = -1;
               
               //
               //
               //
               //
               //
               
               trend[i] = trend[i+1];
               slope[i] = slope[i+1];
               value[i] = value[i+1];
                  
               if (kst[i]>kstSignal[i]) value[i] = 1;
               if (kst[i]<kstSignal[i]) value[i] =-1;
               if (kst[i]>zeroLine[i])  trend[i] = 1;
               if (kst[i]<zeroLine[i])  trend[i] =-1;
               if (kst[i]>kst[i+1])     slope[i] = 1;
               if (kst[i]<kst[i+1])     slope[i] =-1;
               
               //
               //
               //
               //
               //
               
               ObjectDelete(ColorUniqueID+":"+Time[i]);   
               if (cb>=i)
               {
                  double ratio = MathMin(kst[i],osLine[i]);
                         ratio = MathMax(ratio ,obLine[i]);
                         if ((osLine[i]-obLine[i]) != 0)
                               ratio = (ratio-obLine[i])/(osLine[i]-obLine[i]);
                         else  ratio = 0; 
                         color theColor = gradientColor(100.0*ratio,101,ColorDown,ColorUp);
                              plot("",kst[i],kst[i+1],i,i+1,theColor,ColorWidth);
                              if (barsVisible) drawBar(Time[i],High[i],Low[i],Open[i],Close[i],theColor,theColor);
                }                        
                ratios[i] = ratio;               
         
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
    
        //
        //
        //
        //
        //
      
        static datetime time1 = 0;
        static string   mess1 = "";
           if (alertsOnSignalCross && value[whichBar] != value[whichBar+1])
           {
              if (value[whichBar] == 1) doAlert(time1,mess1,whichBar," crossing signal up ");
              if (value[whichBar] ==-1) doAlert(time1,mess1,whichBar," crossing signal down ");
           }            
        static datetime time2 = 0;
        static string   mess2 = "";
           if (alertsOnZeroCross && trend[whichBar] != trend[whichBar+1])
           {
              if (trend[whichBar] == 1) doAlert(time2,mess2,whichBar," crossing zeroline up ");
              if (trend[whichBar] ==-1) doAlert(time2,mess2,whichBar," crossing zeroline down ");
           }
           
        static datetime time3 = 0;
        static string   mess3 = "";
           if (alertsOnSlope && slope[whichBar] != slope[whichBar+1])
           {
              if (slope[whichBar] == 1) doAlert(time3,mess3,whichBar," sloping up ");
              if (slope[whichBar] ==-1) doAlert(time3,mess3,whichBar," sloping down ");
           }                                                
} 
return(0);
}  

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

double iROC(int period, int shift)
{
   double ROC;

   if (Close[shift + period] != 0)
          ROC = (Close[shift]-Close[shift + period]) / Close[shift + period];
   else   ROC = 0.00;
   return(ROC);
}

//
//
//
//
//

double iSMA(int forBuffer, int r)
{
   double sum=0;
   for (int k=0; k<paramm[forBuffer] && (r-k)>=0; k++) sum += work[r-k][forBuffer];
        return(sum/paramm[forBuffer]);
}

//
//
//
//
//

double workEma[][4];
double iEMA(int forBuffer, int r)
{
   if (ArrayRange(workEma,0)!=Bars) ArrayResize(workEma,Bars);
   if (r==0) 
      workEma[r][forBuffer] = work[r][forBuffer];
   else
   {
      double alpha = 2.0/(1.0+paramm[forBuffer]);
         workEma[r][forBuffer] = workEma[r-1][forBuffer]+alpha*(work[r][forBuffer]-workEma[r-1][forBuffer]);
   }      
   return(workEma[r][forBuffer]);
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," KST ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," KST "),message);
             if (alertsNotify)  SendNotification(message);
             if (alertsSound)   PlaySound(soundFile);
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

void plot(string namex,double valueA, double valueB, int shiftA, int shiftB, color theColor, int width=0,int style=STYLE_SOLID)
{
   string   name = ColorUniqueID+":"+namex+Time[shiftA];
   
   //
   //
   //
   //
   //
   
   ObjectDelete(name);   
       ObjectCreate(name,OBJ_TREND,window,Time[shiftA],valueA,Time[shiftB],valueB);
          ObjectSet(name,OBJPROP_RAY,false);
          ObjectSet(name,OBJPROP_BACK,false);
          ObjectSet(name,OBJPROP_STYLE,style);
          ObjectSet(name,OBJPROP_WIDTH,width);
          ObjectSet(name,OBJPROP_COLOR,theColor);
          ObjectSet(name,OBJPROP_PRICE1,valueA);
          ObjectSet(name,OBJPROP_PRICE2,valueB);
}

//
//
//
//
//

void drawBar(int bTime, double prHigh, double prLow, double prOpen, double prClose, color barColor, color wickColor)
{
   string oName;
          oName = ColorUniqueID+":"+TimeToStr(bTime)+"w";
            if (ObjectFind(oName) < 0) ObjectCreate(oName,OBJ_TREND,0,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prHigh);
                 ObjectSet(oName, OBJPROP_PRICE2, prLow);
                 ObjectSet(oName, OBJPROP_COLOR, wickColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthWick);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, drawInBackgound);
           
         oName = ColorUniqueID+":"+TimeToStr(bTime)+"b";
            if (ObjectFind(oName) < 0)ObjectCreate(oName,OBJ_TREND,0,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prOpen);
                 ObjectSet(oName, OBJPROP_PRICE2, prClose);
                 ObjectSet(oName, OBJPROP_COLOR, barColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthBody);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, drawInBackgound);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

color gradientColor(int step, int totalSteps, color from, color to)
{
   step = MathMax(MathMin(step,totalSteps-1),0);
      color newBlue  = getColor(step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
      color newGreen = getColor(step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
      color newRed   = getColor(step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
      return(newBlue+newGreen+newRed);
}
color getColor(int stepNo, int totalSteps, color from, color to)
{
   double step = (from-to)/(totalSteps-1.0);
   return(MathRound(from-step*stepNo));
}
       



