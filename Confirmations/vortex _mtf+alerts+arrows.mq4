//+------------------------------------------------------------------+
//|                                                       vortex.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  DeepSkyBlue
#property indicator_color2  Red
#property indicator_width1  2
#property indicator_width2  2

//
//
//
//
//

extern string TimeFrame        = "current time frame";
extern int    VortexPeriod     = 14;
extern bool   ShowDifference   = false;
extern bool   Interpolate      = true;

extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsNotify     = false;
extern bool   alertsEmail      = false;
extern string soundfile        = "alert2.wav"; 

extern bool   ShowArrows       = true;
extern string arrowsIdentifier = "Vortex Arrows";
extern color  arrowsUpColor    = LimeGreen;
extern color  arrowsDnColor    = Red;

//
//
//
//
//

double vopBuffer[];
double vomBuffer[];
double vmpBuffer[];
double vmmBuffer[];
double rngBuffer[];
double difBuffer[];
double trend[];

//
//
//
//
//

string IndicatorFileName;
int    timeFrame;
bool   calculateVor;
bool   returningBars;


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
   IndicatorBuffers(7);
   SetIndexBuffer(1,vomBuffer);
   SetIndexBuffer(2,vmpBuffer);
   SetIndexBuffer(3,vmmBuffer);
   SetIndexBuffer(4,rngBuffer);
   SetIndexBuffer(6,trend);
   if (ShowDifference)
   {
      SetIndexBuffer(0,difBuffer);
      SetIndexBuffer(5,vopBuffer);
         SetIndexStyle(0,DRAW_HISTOGRAM);
         SetIndexStyle(1,DRAW_NONE);
   }
   else      
   {
      SetIndexBuffer(0,vopBuffer);
      SetIndexBuffer(5,difBuffer);
         SetIndexStyle(0,DRAW_LINE);
         SetIndexStyle(1,DRAW_LINE);
   }
   
      //
      //
      //
      //
      //
      
         IndicatorFileName = WindowExpertName();
         calculateVor      = (TimeFrame=="calculateVor");
         returningBars     = (TimeFrame=="returnBars");
         timeFrame         = stringToTimeFrame(TimeFrame);

      //
      //
      //
      //
      //
         
   IndicatorShortName("Vortex "+timeFrameToString(timeFrame)+" ( "+VortexPeriod+")");         
   return(0);
}

int deinit() 
{ 
   if (!calculateVor && ShowArrows) deleteArrows();
   
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
   int limit,i;

   if(counted_bars < 0)   return(-1);
   if(counted_bars > 0)   counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-2);
               if (returningBars)  { vomBuffer[0] = limit; return(0); }
           
   //
   //
   //
   //
   //

   if (calculateVor || timeFrame==Period())
   {
      for(i = limit; i >= 0; i--)
      {
         rngBuffer[i] = MathMax(High[i],Close[i+1])-MathMin(Low[i],Close[i+1]);
         vmpBuffer[i] = MathAbs(High[i] - Low[i+1]);
         vmmBuffer[i] = MathAbs(Low[i] - High[i+1]);
         vopBuffer[i] = EMPTY_VALUE;
         vomBuffer[i] = EMPTY_VALUE;

         if ((Bars-i)<VortexPeriod) continue;
         
         //
         //
         //
         //
         //
         
            double vmpSum = 0;
            double vmmSum = 0;
            double rngSum = 0;
            for (int k=0; k<VortexPeriod; k++)
            {
               vmpSum += vmpBuffer[i+k];
               vmmSum += vmmBuffer[i+k];
               rngSum += rngBuffer[i+k];
            }
            if (rngSum !=0)
            {
               vopBuffer[i] = vmpSum/rngSum;
               vomBuffer[i] = vmmSum/rngSum;
            }
            difBuffer[i] = vopBuffer[i]-vomBuffer[i];
            trend[i]     = trend[i+1];
            if (ShowDifference)
            {
              if (difBuffer[i]>0) trend[i] = 1;
              if (difBuffer[i]<0) trend[i] =-1;
            }
            else
            {
              if (vopBuffer[i]>vomBuffer[i]) trend[i] = 1;
              if (vopBuffer[i]<vomBuffer[i]) trend[i] =-1;
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
   
   if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,IndicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         if (ShowDifference)
                difBuffer[i] = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateVor",VortexPeriod,ShowDifference,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundfile,ShowArrows,arrowsIdentifier,arrowsUpColor,arrowsDnColor,0,y);
         else { vomBuffer[i] = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateVor",VortexPeriod,ShowDifference,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundfile,ShowArrows,arrowsIdentifier,arrowsUpColor,arrowsDnColor,0,y);
                vopBuffer[i] = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateVor",VortexPeriod,ShowDifference,false,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundfile,ShowArrows,arrowsIdentifier,arrowsUpColor,arrowsDnColor,1,y);
         } 

         //
         //
         //
         //
         //
      
         if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            double factor = 1.0 / n;
            for(k = 1; k < n; k++)
            {
               if (ShowDifference)
                     difBuffer[i+k]  = k*factor*difBuffer[i+n]  + (1.0-k*factor)*difBuffer[i];
               else  
                  {
                     vomBuffer[i+k]  = k*factor*vomBuffer[i+n]  + (1.0-k*factor)*vomBuffer[i];
                     vopBuffer[i+k]  = k*factor*vopBuffer[i+n]  + (1.0-k*factor)*vopBuffer[i];
                  }                
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Vortex ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Vortex "),message);
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
   if (ShowArrows)
   {
      deleteArrow(Time[i]);
      if (trend[i]!=trend[i+1])
      {
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,225,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,226,true);
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
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+ gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] - gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}
void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}