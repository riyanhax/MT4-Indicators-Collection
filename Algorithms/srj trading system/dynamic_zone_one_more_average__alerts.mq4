//+------------------------------------------------------------------+
//|                                             One more average.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  DeepSkyBlue
#property indicator_color2  LimeGreen
#property indicator_color3  LimeGreen
#property indicator_color4  DimGray
#property indicator_color5  Red
#property indicator_color6  Red
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_style5  STYLE_DOT
#property indicator_width1  2

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

extern int    Length                  =  26;
extern int    AppliedPrice            =   0;
extern double Speed                   = 1.0;
extern bool   Adaptive                = true;
extern string DisplayLines            = "yyyyyy";
extern int    DzLookBackBars          = 35;
extern double DzStartBuyProbability1  = 0.10;
extern double DzStartBuyProbability2  = 0.25;
extern double DzStartSellProbability1 = 0.10;
extern double DzStartSellProbability2 = 0.25;

//
//
//
//
//

extern bool   alertsOn        = false;
extern string alertCrosses    = "yyyyy";
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double average[];
double bl1Buffer[];
double bl2Buffer[];
double sl1Buffer[];
double sl2Buffer[];
double zliBuffer[];
double trends[][5];
double stored[][7];
double alerts[5][2];

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
   SetIndexBuffer(0,average);
   SetIndexBuffer(1,bl1Buffer);
   SetIndexBuffer(2,bl2Buffer);
   SetIndexBuffer(3,zliBuffer);
   SetIndexBuffer(4,sl2Buffer);
   SetIndexBuffer(5,sl1Buffer);

      for (int i=0; i<6; i++)
         if (isYes(DisplayLines,i))
               SetIndexStyle(i,DRAW_LINE);
         else  SetIndexStyle(i,DRAW_NONE);
   
         //
         //
         //
         //
         //
         
         Length = MathMax(Length,1);
         Speed  = MathMax(Speed,-1.5);
   IndicatorShortName("One more average ("+Length+")");
   return(0);
}
int deinit() { return(0); }

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
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (ArrayRange(stored,0) != Bars) { ArrayResize(stored,Bars); ArrayResize(trends,Bars);}
         if (Digits>3)
            double precision = 0.001;
         else      precision = 0.1;            


   //
   //
   //
   //
   //

   for(i=limit, r=Bars-limit-1; i>=0; i--,r++)
   {
      average[i] = iAverage(iMA(NULL,0,1,0,MODE_SMA,AppliedPrice,i),Length,Speed,Adaptive,r);
      if (DzStartBuyProbability1 >0) bl1Buffer[i] = dzBuyP (average, DzStartBuyProbability1,  DzLookBackBars, Bars, i, precision);
      if (DzStartBuyProbability2 >0) bl2Buffer[i] = dzBuyP (average, DzStartBuyProbability2,  DzLookBackBars, Bars, i, precision);
      if (DzStartSellProbability1>0) sl1Buffer[i] = dzSellP(average, DzStartSellProbability1, DzLookBackBars, Bars, i, precision);
      if (DzStartSellProbability2>0) sl2Buffer[i] = dzSellP(average, DzStartSellProbability2, DzLookBackBars, Bars, i, precision);
                                     zliBuffer[i] = dzSellP(average, 0.5                    , DzLookBackBars, Bars, i, precision);
      
      //
      //
      //
      //
      //
      
      if (alertsOn)
      {
         double price = average[i];
            setTrend(price,0,bl1Buffer,r,i);
            setTrend(price,1,bl2Buffer,r,i);
            setTrend(price,2,zliBuffer,r,i);
            setTrend(price,3,sl2Buffer,r,i);
            setTrend(price,4,sl1Buffer,r,i);
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
      checkTrend(whichBar,0,"buy probability line 1");
      checkTrend(whichBar,1,"buy probability line 2");
      checkTrend(whichBar,2,"middle line");
      checkTrend(whichBar,3,"sell probability line 2");
      checkTrend(whichBar,4,"sell probability line 1");
   }

   //
   //
   //
   //
   //
   
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

bool isYes(string from, int position)
{
   int length = StringLen(from);
      if (position<length)
      {
         string ans = StringSubstr(from,position,1);
            if (ans=="y" || ans =="Y")
                  return(true);
            else  return(false);
      }
      else return(false);                  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void setTrend(double price, int forTrend, double &array[],int r, int i)
{
   if (array[i] == EMPTY_VALUE)
      trends[r][forTrend] = 0;
   else
      {      
         trends[r][forTrend] = trends[r-1][forTrend]; 
            if (price>array[i]) trends[r][forTrend] =  1;
            if (price<array[i]) trends[r][forTrend] = -1;
      }            
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
//
//
//
//
//

void checkTrend(int whichBar,int forTrend, string crossDescription)
{
   int r = Bars-whichBar-1;

      if (!isYes(alertCrosses,forTrend))                                            return;
      if (trends[r][forTrend]==trends[r-1][forTrend])                               return;
      if (alerts[forTrend][0]==trends[r][forTrend] && alerts[forTrend][1]==Time[0]) return;
      
      //
      //
      //
      //
      //
      
      alerts[forTrend][0]=trends[r][forTrend];
      alerts[forTrend][1]=Time[0];
            if (trends[r][forTrend] == 1)
                  doAlert(crossDescription+" up");
            else  doAlert(crossDescription+" down");
}

//
//
//
//
//

void doAlert(string doWhat)
{
   string message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," DZ OMA crossed ",doWhat);
      if (alertsMessage) Alert(message);
      if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"DZ OMA "),message);
      if (alertsSound)   PlaySound("alert2.wav");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

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

double iAverage(double price, double averagePeriod, double fconst, bool adaptive, int r)
{
   double e1=stored[r-1][E1];  double e2=stored[r-1][E2];
   double e3=stored[r-1][E3];  double e4=stored[r-1][E4];
   double e5=stored[r-1][E5];  double e6=stored[r-1][E6];

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
         double signal    = MathAbs((price-stored[r-endPeriod][res]));
         double noise     = 0.00000000001;

            for(int k=1; k<endPeriod; k++) noise=noise+MathAbs(price-stored[r-k][res]);

         averagePeriod = ((signal/noise)*(maxPeriod-minPeriod))+minPeriod;
      }
      
      //
      //
      //
      //
      //
      
      double alpha = (2.0+fconst)/(1.0+fconst+averagePeriod);

      e1 = e1 + alpha*(price-e1); e2 = e2 + alpha*(e1-e2); double v1 = 1.5 * e1 - 0.5 * e2;
      e3 = e3 + alpha*(v1   -e3); e4 = e4 + alpha*(e3-e4); double v2 = 1.5 * e3 - 0.5 * e4;
      e5 = e5 + alpha*(v2   -e5); e6 = e6 + alpha*(e5-e6); double v3 = 1.5 * e5 - 0.5 * e6;

   //
   //
   //
   //
   //

   stored[r][E1]  = e1;  stored[r][E2] = e2;
   stored[r][E3]  = e3;  stored[r][E4] = e4;
   stored[r][E5]  = e5;  stored[r][E6] = e6;
   stored[r][res] = price;
   return(v3);
}