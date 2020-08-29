//+------------------------------------------------------------------+
//|                                                HMA color nrp.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Gray
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

extern string TimeFrame        = "Current time frame";
extern int    HMA_Period       = 35;
extern int    HMA_PriceType    = 0;
extern int    HMA_Method       = 3;
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = true;
extern bool   alertsEmail      = false;
extern bool   ShowArrows       = false;
extern string arrowsIdentifier = "HMA Arrows";
extern double arrowsUpperGap   = 0.5;
extern double arrowsLowerGap   = 0.5;
extern color  arrowsUpColor    = LimeGreen;
extern color  arrowsDnColor    = Red;
extern color  arrowsUpCode     = 241;
extern color  arrowsDnCode     = 242;
extern int    arrowsUpSize     = 2;
extern int    arrowsDnSize     = 2;
extern bool   Interpolate      = true;


int HalfPeriod;
int HullPeriod;

//
//
//
//
//

double ind_buffer0[];
double ind_buffer1[];
double ind_buffer2[];
double ind_buffer3[];
double buffer[];
double trend[];

string indicatorFileName;
bool   returnBars;
int    timeFrame;


//+------------------------------------------------------------------
//|                                                                 |
//+------------------------------------------------------------------

int init()
{
   HMA_Period = MathMax(2,HMA_Period);
   HalfPeriod = MathFloor(HMA_Period/2);
   HullPeriod = MathFloor(MathSqrt(HMA_Period));
   
   //
   //
   //
   //
   //
   
   IndicatorBuffers(6);
   SetIndexBuffer(0,ind_buffer0); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ind_buffer1); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ind_buffer2);
   SetIndexBuffer(3,ind_buffer3);
   SetIndexBuffer(4,buffer);
   SetIndexBuffer(5,trend);

      timeFrame         = stringToTimeFrame(TimeFrame);
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame=="returnBars");
   IndicatorShortName("HMA("+HMA_Period+","+timeFrame+")");
   return(0);
}

int deinit()
{
   deleteArrows();
    
return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { ind_buffer0[0] = limit+1; return(0); }
           if (timeFrame != Period())
           {
               limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,timeFrame,Time[i]);
                     ind_buffer0[i] = EMPTY_VALUE;
                     ind_buffer1[i] = EMPTY_VALUE;
                     ind_buffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"",HMA_Period,HMA_PriceType,HMA_Method,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,2,y);
                     trend[i]       = iCustom(NULL,timeFrame,indicatorFileName,"",HMA_Period,HMA_PriceType,HMA_Method,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,5,y);
                        if (trend[i]== 1) ind_buffer0[i] = ind_buffer2[i];
                        if (trend[i]==-1) ind_buffer1[i] = ind_buffer2[i];
                     
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
                        for(int x = 1; x < n; x++) 
                        {
                           ind_buffer2[i+x] = ind_buffer2[i] + (ind_buffer2[i+n] - ind_buffer2[i])* x/n;                             
                              if (ind_buffer0[i] != EMPTY_VALUE) ind_buffer0[i+x] = ind_buffer2[i+x];
                              if (ind_buffer1[i] != EMPTY_VALUE) ind_buffer1[i+x] = ind_buffer2[i+x];
                  }
               }
               return(0);     
           }

   //
   //
   //
   //
   //
   
   for(i=limit; i>=0; i--)
         buffer[i]=iMA(NULL,0,HalfPeriod,0,HMA_Method,HMA_PriceType,i)*2-
                   iMA(NULL,0,HMA_Period,0,HMA_Method,HMA_PriceType,i);
   for(i=limit; i>=0; i--)
   {
      ind_buffer3[i] = iMAOnArray(buffer,0,HullPeriod,0,HMA_Method,i);
      ind_buffer2[i] = ind_buffer3[i]-ind_buffer3[i+1];
      ind_buffer0[i] = EMPTY_VALUE;
      ind_buffer1[i] = EMPTY_VALUE;
      
      //
      //
      //
      //
      //

      trend[i] = trend[i+1];            
         if (ind_buffer2[i] > 0) trend[i] =  1; 
         if (ind_buffer2[i] < 0) trend[i] = -1; 
         if (trend[i] ==  1) ind_buffer0[i] = ind_buffer2[i];
         if (trend[i] == -1) ind_buffer1[i] = ind_buffer2[i];
         manageArrow(i); 
   }
   manageAlerts();
   return(0);
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

       message =  timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" hull trend changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" hull trend",message);
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
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
      }
   }
}               

//
//
//
//
//

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,int theWidth, bool up)
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
         ObjectSet(name,OBJPROP_WIDTH,theWidth);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
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
   StringToUpper(tfs);
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