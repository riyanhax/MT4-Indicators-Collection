//+------------------------------------------------------------------+
//|                                            Anchored momentum.mq4 |
//|                                                           mladen |
//|                                                                  |
//| developed by Rudy Stefenel                                       |
//| Technical analysis of Stoctks and Commodities (TASC)             |
//| february 1998 - article : "Anchored momentum"                    |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrDeepSkyBlue
#property indicator_color3  clrOrange
#property indicator_color4  clrOrange
#property indicator_color5  clrDarkGray
#property indicator_width1  2
#property indicator_width3  2
#property indicator_width5  3

//
//
//
//
//

enum amType
{
   typeGeneral,    // General
   typeMost,       // General with EMA
   typeGeneralEma, // Most
   typeMostEma     // Most with EMA
};

extern ENUM_TIMEFRAMES    TimeFrame        = PERIOD_CURRENT;   // Time frame
extern int                MomPeriod        = 10;
extern int                EmaPeriod        =  7;
extern int                SmaPeriod        =  7;
extern amType             MomentumType     = typeMost;
extern ENUM_APPLIED_PRICE AppliedPrice     = PRICE_CLOSE;
extern bool               alertsOn         = true;
extern bool               alertsOnCurrent  = false;
extern bool               alertsMessage    = true;
extern bool               alertsSound      = true;
extern bool               alertsEmail      = false;
extern bool               alertsNotify     = false;
extern string             soundFile        = "alert2.wav";
extern bool               Interpolate      = true;             // Interpolate in mtf mode

double Momentuu[],Momentud[],Momentdd[],Momentdu[],Momentul[],Buffers[],Buffere[],slope[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,MomPeriod,EmaPeriod,SmaPeriod,MomentumType,AppliedPrice,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,soundFile,_buff,_ind)


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
   IndicatorBuffers(10);
      SetIndexBuffer(0,Momentuu);  SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"Momentum"); 
      SetIndexBuffer(1,Momentud);  SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"Momentum"); 
      SetIndexBuffer(2,Momentdd);  SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexLabel(2,"Momentum"); 
      SetIndexBuffer(3,Momentdu);  SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexLabel(3,"Momentum"); 
      SetIndexBuffer(4,Momentul);
      SetIndexBuffer(5,Buffers);
      SetIndexBuffer(6,Buffere);
      SetIndexBuffer(7,slope);
      SetIndexBuffer(8,trend);
      SetIndexBuffer(9,count);
      
      //
      //
      //
      //
      //
      
      MomPeriod    = fmax(SmaPeriod,MomPeriod);
      MomPeriod    = fmax(EmaPeriod,MomPeriod);
      MomentumType = fmax(fmin(MomentumType,3),0);
      indicatorFileName = WindowExpertName();
      TimeFrame         = fmax(TimeFrame,_Period);
      string type;
      switch (MomentumType)
         {
            case typeGeneral :    type = " General";          break;
            case typeGeneralEma : type = " General with EMA"; break;
            case typeMost :       type = " Most";             break;
            case typeMostEma :    type = " Most with EMA";
         }
      IndicatorShortName(timeFrameToString(TimeFrame)+ type+" ("+SmaPeriod+","+EmaPeriod+","+MomPeriod+")");
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
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame != _Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(9,0)*TimeFrame/_Period));
            for (i=limit;i>=0 && !_StopFlag; i--)
            {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     Momentuu[i] = _mtfCall(0,y);
   	               Momentud[i] = _mtfCall(1,y);
   	               Momentdd[i] = _mtfCall(2,y);
                     Momentdu[i] = _mtfCall(3,y);
                     Momentul[i] = _mtfCall(4,y);
                     slope[i]    = _mtfCall(7,y);
                     trend[i]    = _mtfCall(8,y);
                     
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(Momentul);
            }
            for(i=limit; i>=0; i--) 
            {
   	         Momentuu[i] = (trend[i] == 1 && slope[i] == 1) ? Momentul[i] : EMPTY_VALUE;   
               Momentud[i] = (trend[i] == 1 && slope[i] ==-1) ? Momentul[i] : EMPTY_VALUE;
               Momentdd[i] = (trend[i] ==-1 && slope[i] ==-1) ? Momentul[i] : EMPTY_VALUE;   
               Momentdu[i] = (trend[i] ==-1 && slope[i] == 1) ? Momentul[i] : EMPTY_VALUE;
            }
   return(0);
   }

   
   //
   //
   //
   //
   //
   
   for(i = limit; i >= 0; i--)
   {
      double price = iMA(NULL,0,1,0,MODE_SMA,AppliedPrice,i);
      int    index;

      //
      //
      //
      //
      //
      
      switch (MomentumType)
         {
            case typeGeneral :
                  index       = i+(MomPeriod-((SmaPeriod-1)/2.00));
                  Buffers[i]  = iMA(NULL,0,SmaPeriod,0,MODE_SMA,AppliedPrice,i);
                  if (Buffers[index] != 0) Momentul[i] = 100.00 * (price / Buffers[index] - 1.00);
             break;
                        
                  //
                  //
                  //
                  //
                  //
                                          
            case typeMost :                                    
                  Buffers[i]  = iMA(NULL,0,2.00*MomPeriod+1,0,MODE_SMA,AppliedPrice,i);
                  if (Buffers[i] != 0) Momentul[i] = 100.00 * (price / Buffers[i] - 1.00);
             break;

                  //
                  //
                  //
                  //
                  //
                  
            case typeGeneralEma :
                  index       = i+(MomPeriod-((SmaPeriod-1)/2.00));
                  Buffers[i]  = iMA(NULL,0,SmaPeriod,0,MODE_SMA,AppliedPrice,i);
                  Buffere[i]  = iMA(NULL,0,EmaPeriod,0,MODE_EMA,AppliedPrice,i);
                  if (Buffers[index] != 0) Momentul[i] = 100.00 * (Buffere[i] / Buffers[index] - 1.00);
             break;
             
                  //
                  //
                  //
                  //
                  //
                                          
              case typeMostEma :
                    Buffers[i]  = iMA(NULL,0,2.00*MomPeriod+1,0,MODE_SMA,AppliedPrice,i);
                    Buffere[i]  = iMA(NULL,0,EmaPeriod,0,MODE_EMA,AppliedPrice,i);
                    if (Buffers[i] != 0) Momentul[i] = 100.00 * (Buffere[i] / Buffers[i] - 1.00);
         }
         trend[i] = (i<Bars-1) ? (Momentul[i]>0)             ? 1 : (Momentul[i]<0)             ? -1 : trend[i+1] : 0;
         slope[i] = (i<Bars-1) ? (Momentul[i]>Momentul[i+1]) ? 1 : (Momentul[i]<Momentul[i+1]) ? -1 : slope[i+1] : 0;
         Momentuu[i] = (trend[i] == 1 && slope[i] == 1) ? Momentul[i] : EMPTY_VALUE;   
         Momentud[i] = (trend[i] == 1 && slope[i] ==-1) ? Momentul[i] : EMPTY_VALUE;
         Momentdd[i] = (trend[i] ==-1 && slope[i] ==-1) ? Momentul[i] : EMPTY_VALUE;   
         Momentdu[i] = (trend[i] ==-1 && slope[i] == 1) ? Momentul[i] : EMPTY_VALUE;
         
   }
   if (alertsOn)
   {
      int whichBar = (alertsOnCurrent) ? 0 : 1;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("crossing zero up");
      else  doAlert("crossing zero down");       
    }
   return(0);
}

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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Anchored momentum "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(_Symbol+" Anchored momentum ",message);
             if (alertsNotify)  SendNotification(message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

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

