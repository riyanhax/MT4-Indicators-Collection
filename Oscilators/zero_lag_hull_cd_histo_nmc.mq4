//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "www.forex-tsd,com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  DeepSkyBlue
#property indicator_color2  PaleVioletRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//
//
//
//

extern string TimeFrame       = "current time frame";
extern int    FastHullLength  = 15;
extern int    FastHullPrice   = PRICE_CLOSE;
extern int    SlowHullLength  = 30;
extern int    SlowHullPrice   = PRICE_CLOSE;
extern bool   arrowsVisible   = false;
extern string arrowsUniqueID  = "ZlHullArrows1";
extern color  arrowsUpColor   = DeepSkyBlue;
extern color  arrowsDnColor   = PaleVioletRed;
extern int    arrowsUpCode    = 241;
extern int    arrowsDownCode  = 242;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern bool   Interpolate     = true;

//
//
//
//
//

double hmha[];
double hmhb[];
double hma[];
double hmb[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0,hmha); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,hmhb); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,hma);
      SetIndexBuffer(3,hmb);
      SetIndexBuffer(4,trend);

      //
      //
      //
      //
      //
   
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame=="returnBars";     if (returnBars)     return(0);
      calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      
   //
   //
   //
   //
   //
         
   IndicatorShortName(timeFrameToString(timeFrame)+" zero lag HMA CD ("+FastHullLength+","+SlowHullLength+")");         
   return(0);
}

//
//
//
//
//

int deinit()
{
   string lookFor       = arrowsUniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { hma[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      for (i=limit; i>=0; i--)
      {
         double hma1   = iHma(iMA(NULL,0,1,0,MODE_SMA,FastHullPrice,i),FastHullLength,i,0);
         double hma2   = iHma(hma1                                    ,FastHullLength,i,1);
                hma[i] = 2.0*hma1-hma2;
                hma1   = iHma(iMA(NULL,0,1,0,MODE_SMA,SlowHullPrice,i),SlowHullLength,i,2);
                hma2   = iHma(hma1                                    ,SlowHullLength,i,3);
                hmb[i] = 2.0*hma1-hma2;

         //
         //
         //
         //
         //
         
         hmha[i] = EMPTY_VALUE;
         hmhb[i] = EMPTY_VALUE;
            if (hma[i] > hmb[i]) trend[i] =  1;
            if (hma[i] < hmb[i]) trend[i] = -1;
            if (trend[i] ==  1)  hmha[i]=1;
            if (trend[i] == -1)  hmhb[i]=1;
            manageArrow(i);
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
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastHullLength,FastHullPrice,SlowHullLength,SlowHullPrice,4,y);
         hmha[i]  = EMPTY_VALUE;
         hmhb[i]  = EMPTY_VALUE;
            if (trend[i] ==  1)  hmha[i]=1;
            if (trend[i] == -1)  hmhb[i]=1;
         manageArrow(i);
   }
   
   //
   //
   //
   //
   //

   manageAlerts();   
   return(0);
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
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
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

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ZL Hull CD trend changed to ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"ZL Hull CD"),message);
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
   if (!calculateValue && arrowsVisible)
   {
      deleteArrow(Time[i]);
      if (trend[i]!=trend[i+1])
      {
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode  ,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDownCode,true);
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
   string name = arrowsUniqueID+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
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
   string lookFor = arrowsUniqueID+":"+time; ObjectDelete(lookFor);
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

double wrk[][8];

//
//
//
//
//

double iHma(double price, int period, int i, int s=0)
{
   if (ArrayRange(wrk,0)!=Bars) ArrayResize(wrk,Bars);
   
   //
   //
   //
   //
   //
   
      int HMAPeriod  = MathMax(2,period);
      int HalfPeriod = MathFloor(HMAPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HMAPeriod));

      //
      //
      //
      //
      //

      s = s*2;         
      int r = Bars-i-1;  
         wrk[r][s  ] = price;
         wrk[r][s+1] = 2.0*iLwma(s,HalfPeriod,r)-iLwma(s,HMAPeriod,r);
      return (iLwma(s+1,HullPeriod,r));
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

double iLwma(int forBuffer, int period, int r)
{
   double weight = 0;
   double sum    = 0;
   int    i,k;
   
   if (r>=period)
   {
      for (i=0, k=period; i<period; i++,k--)
      {
            weight += k; sum += wrk[r-i][forBuffer]*k;
      }
      if (weight !=0)
            return(sum/weight);
      else  return(0.0);
    }
    else return(wrk[r][forBuffer]);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

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