//+------------------------------------------------------------------
//| Jurik volty simple
//+------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  DeepSkyBlue
#property indicator_color2  PaleVioletRed
#property indicator_color3  DimGray
#property indicator_color4  DeepSkyBlue
#property indicator_style3  STYLE_DOT
#property indicator_width4  2

//
//
//
//
//

extern string TimeFrame               = "Current time frame";
extern int    Length                  =  14;
extern int    Price                   =   0;
extern int    Shift                   =   0;
extern bool   ShowMiddle              = true;
extern bool   ZeroBind                = true;
extern bool   Normalize               = false;
extern bool   alertsOnZeroCross       = true;
extern bool   alertsOnAllBreakOuts    = false;
extern bool   alertsOnAllBreakOutBars = false;
extern bool   alertsOn                = false;
extern bool   alertsOnCurrent         = false;
extern bool   alertsMessage           = true;
extern bool   alertsSound             = false;
extern bool   alertsEmail             = false;
extern bool   Interpolate             = true;
extern bool   arrowsVisible           = false;
extern string arrowsIdentifier        = "JurkiVltyArrows";
extern color  arrowsUpColor           = DeepSkyBlue;
extern color  arrowsDnColor           = Red;

//
//
//
//
//

double upValues[];
double dnValues[];
double miValues[];
double price[];
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
   for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   IndicatorDigits(5);
   IndicatorBuffers(5);
   SetIndexBuffer(0,upValues);
   SetIndexBuffer(1,dnValues);
   SetIndexBuffer(2,miValues);
   SetIndexBuffer(3,price);
   SetIndexBuffer(4,trend);
   
      //
      //
      //
      //
      //
                  
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);   
      IndicatorShortName(timeFrameToString(timeFrame)+" Jurik volty bands ("+Length+")");
      
   return(0);
}

//
//
//
//
//

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
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { upValues[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //
            
   if (calculateValue || timeFrame==Period())
   {
      for(i=limit; i>=0; i--)
      {
         double vprice = iMA(NULL,0,1,0,MODE_SMA,Price,i+Shift);
         double cprice = iMA(NULL,0,1,0,MODE_SMA,Price,i);
         double upValue;
         double dnValue;
         double miValue;
         
         iVolty(vprice,upValue,dnValue,miValue,Length,i);
         
         //
         //
         //
         //
         //
         
            if (ZeroBind)
            {
               if (Normalize)
               {
                  upValues[i] =  1;
                  dnValues[i] = -1;
                  double diff = (upValue-miValue);
                     if (diff != 0)
                           price[i] = (cprice-miValue)/diff;
                     else  price[i] = 0;              
               }
               else
               {
                  upValues[i] = upValue-miValue;
                  dnValues[i] = dnValue-miValue;
                  price[i]    = (cprice-miValue);
               }
            }
            else
            {
               upValues[i] = upValue;
               dnValues[i] = dnValue;
               price[i]    = cprice;
            }               
            if (ShowMiddle)
            {
               if (ZeroBind) 
                     miValues[i] = 0;
               else  miValues[i] = miValue;
            }
         
            //
            //
            //
            //
            //
               
            if (alertsOnZeroCross)
            {
               if (cprice>miValue) trend[i] =  1;
               if (cprice<miValue) trend[i] = -1;
            }               
            else
            {
               if (cprice>upValue)                   trend[i] =  1;
               if (cprice<dnValue)                   trend[i] = -1;
               if (alertsOnAllBreakOuts || alertsOnAllBreakOutBars)
               if (cprice<upValue && cprice>dnValue) trend[i] =  0;
            }
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
   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         upValues[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,ShowMiddle,ZeroBind,Normalize,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,0,y);
         dnValues[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,ShowMiddle,ZeroBind,Normalize,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,1,y);
         price[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,ShowMiddle,ZeroBind,Normalize,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,3,y);
         trend[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,ShowMiddle,ZeroBind,Normalize,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,4,y);
         manageArrow(i);
         if (ShowMiddle)
            miValues[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,ShowMiddle,ZeroBind,Normalize,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,2,y);

         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
            {
               if (ShowMiddle) miValues[i+k] = miValues[i] + (miValues[i+n]-miValues[i])*k/n;
                               upValues[i+k] = upValues[i] + (upValues[i+n]-upValues[i])*k/n;
                               dnValues[i+k] = dnValues[i] + (dnValues[i+n]-dnValues[i])*k/n;
                               price[i+k]   = price[i]   + (price[i+n]  -price[i])*k/n;
            }               
   }
   manageAlerts();
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

double wrk[][6];
#define bsmax  0
#define bsmin  1
#define volty  2
#define vsum   3
#define avolty 4
#define vprice 5
#define avgLen 65

//
//
//
//
//

void iVolty(double tprice, double& upValue, double& dnValue, double& miValue, double length, int i)
{
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; if (r==0) { for(int k=0; k<5; k++) wrk[0][k]=0; return ; }

   //
   //
   //
   //
   //
   
      double hprice = tprice;
      double lprice = tprice;
        wrk[r][vprice] = tprice;

           for (k=1; k<length && (r-k)>=0; k++)
           {
               hprice = MathMax(wrk[r-k][vprice],hprice);
               lprice = MathMin(wrk[r-k][vprice],lprice);
           }
      
      //
      //
      //
      //
      //
      
      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = hprice - wrk[r-1][bsmax];
      double del2 = lprice - wrk[r-1][bsmin];
	
         wrk[r][volty] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty] = MathAbs(del2); 
         wrk[r][vsum] =	wrk[r-1][vsum] + 0.1*(wrk[r][volty]-wrk[r-10][volty]);
   
         double avg = wrk[r][vsum];  for (k=1; k<avgLen && (r-k)>=0 ; k++) avg += wrk[r-k][vsum];
                                                                           avg /= k;
         wrk[r][avolty] = avg;                                           
            if (wrk[r][avolty] > 0)
               double dVolty = wrk[r][volty]/wrk[r][avolty]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));		
	
         if (del1 > 0) wrk[r][bsmax] = hprice; else wrk[r][bsmax] = hprice - Kv*del1;
         if (del2 < 0) wrk[r][bsmin] = lprice; else wrk[r][bsmin] = lprice - Kv*del2;

   //
   //
   //
   //
   //
      
   dnValue = wrk[r][bsmin];
   upValue = wrk[r][bsmax];
   miValue = (upValue+dnValue)/2.0;
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

      //
      //
      //
      //
      //
            
      static datetime alertTime1 = 0;
      static string   alertWhat1 = "";
      if (alertsOnZeroCross)
      {
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] ==  1) doAlert(alertTime1,alertWhat1,whichBar,"price crossed zero (middle) line up");
            if (trend[whichBar] == -1) doAlert(alertTime1,alertWhat1,whichBar,"price crossed zero (middle) line down");
         }
      }
      else
      {
         if (alertsOnAllBreakOutBars)
               bool condition = true;
         else       condition = (trend[whichBar] != trend[whichBar+1]);
         if (condition)
         {
            if (trend[whichBar] ==  1) doAlert(alertTime1,alertWhat1,whichBar,"price broke upper band");
            if (trend[whichBar] == -1) doAlert(alertTime1,alertWhat1,whichBar,"price broke lower band");
         }
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",timeFrameToString(timeFrame)+" jurik volty bands ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"jurik volty bands"),message);
          if (alertsSound)   PlaySound("alert2.wav");
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

void manageArrow(int i)
{
   if (!calculateValue && arrowsVisible )
   {
         deleteArrow(Time[i]);
         if (trend[i]!=trend[i+1])
         {
            if (trend[i] == 1) drawArrow(i,arrowsUpColor,241,false);
            if (trend[i] ==-1) drawArrow(i,arrowsDnColor,242,true);
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