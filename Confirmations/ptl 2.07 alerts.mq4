//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  clrPaleVioletRed
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrPaleVioletRed
#property indicator_color4  clrLimeGreen
#property indicator_color5  clrPaleVioletRed
#property indicator_color6  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  3
#property indicator_width6  3
#property strict

//
//
//
//
//

#define _disLin 1
#define _disBar 2
#define _disArr 4
enum enDisplayType
{
   _dis_line =_disLin,                // Display lines
   _dis_bar  =_disBar,                // Display colored bars
   _dis_arr  =_disArr,                // Display arrows
   _dis_linb =_disLin+_disBar,        // Display lines and colored bars
   _dis_lina =_disLin+_disArr,        // Display lines and arrows
   _dis_bara =_disArr+_disBar,        // Display colored bars and arrows
   _dis_all  =_disLin+_disBar+_disArr // Display all
};
extern ENUM_TIMEFRAMES TimeFrame          = PERIOD_CURRENT;   // Time frame
extern int             SlowLength         = 7;                // Slow length
extern double          SlowPipDisplace    = 0;                // Slow pip displace
extern int             FastLength         = 3;                // Fast length
extern double          FastPipDisplace    = 0;                // Fast pip displace
extern bool            AlertsOn           = false;            // Turn alerts on?
extern bool            AlertsOnCurrent    = true;             // Alerts on current bar?
extern bool            AlertsMessage      = true;             // Alerts message?
extern bool            AlertsSound        = false;            // Alerts sound?
extern bool            AlertsEmail        = false;            // Alerts email?
extern bool            AlertsNotification = false;            // Alerts push notification?
extern enDisplayType   DisplayType        = _disLin+_disArr;  // Display type
extern int             ArrowCodeDn        = 159;              // Arrow code down
extern int             ArrowCodeUp        = 159;              // Arrow code up
extern bool            ArrowOnFirst       = false;            // Arrow on first bars
extern bool            ShowCandles        = false;            // Show candles
extern int             CandleCount        = 500;              // Candles count
extern color           WickColor          = clrGray;          // Wick color
extern color           BodyUpColor        = clrLimeGreen;     // Body up colr
extern color           BodyDownColor      = clrPaleVioletRed; // Body down color
extern color           BodyNeutralColor   = clrSilver;        // Body neutral colr
extern int             BodyWidth          = 4;                // Body width
extern bool            DrawAsBack         = false;            // Draw candles as back?
extern string          UniqueID           = "ptlCandles1";    // Unique ID

double line1[],line2[],hist1[],hist2[],arrou[],arrod[],trend[],trena[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotification,DisplayType,_buff,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   int type1 = !(DisplayType&_disLin) ? DRAW_NONE : DRAW_LINE ;
   int type2 = !(DisplayType&_disBar) ? DRAW_NONE : DRAW_HISTOGRAM;
   int type3 = !(DisplayType&_disArr) ? DRAW_NONE : DRAW_ARROW;
   
   IndicatorBuffers(9);
      SetIndexBuffer(0,line1); SetIndexStyle(0,type1);
      SetIndexBuffer(1,line2); SetIndexStyle(1,type1);
      SetIndexBuffer(2,hist1); SetIndexStyle(2,type2);
      SetIndexBuffer(3,hist2); SetIndexStyle(3,type2);
      SetIndexBuffer(4,arrod); SetIndexStyle(4,type3); SetIndexArrow(4,ArrowCodeDn);
      SetIndexBuffer(5,arrou); SetIndexStyle(5,type3); SetIndexArrow(5,ArrowCodeUp);
      SetIndexBuffer(6,trend);
      SetIndexBuffer(7,trena);
      SetIndexBuffer(8,count);
         indicatorFileName = WindowExpertName();
         TimeFrame         = MathMax(TimeFrame,_Period);  
   IndicatorShortName(timeFrameToString(TimeFrame)+" ptl");
   return(0);
}

//
//
//
//
//

int deinit() { ObjectsDeleteAll(0,UniqueID+":"); return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int numOfCandles = MathMin(Bars,CandleCount); if (numOfCandles==0) numOfCandles=Bars-1;
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame != _Period)
         {
            limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(8,0)*TimeFrame/_Period));
            for (int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
               int x = y;
               if (ArrowOnFirst)
                     {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);          }
               else  {  if (i>0)      x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
               line1[i] = _mtfCall(0,y);
               line2[i] = _mtfCall(1,y);
               trend[i] = _mtfCall(6,y);
               hist1[i] = EMPTY_VALUE;
               hist2[i] = EMPTY_VALUE;
               arrou[i] = EMPTY_VALUE;
               arrod[i] = EMPTY_VALUE;
               if (x!=y)
               {
                  arrod[i] = _mtfCall(4,y);
                  arrou[i] = _mtfCall(5,y);
               }
               if (trend[i]== 1) { hist1[i] = High[i]; hist2[i] = Low[i]; }
               if (trend[i]==-1) { hist2[i] = High[i]; hist1[i] = Low[i]; }                    
               if (ShowCandles && i<numOfCandles) drawCandle(i,High[i],Low[i],Close[i],Open[i],(int)trend[i]);
            }
            return(0);
         }            

   //
   //
   //
   //
   //
      
   double pipMultiplier = Point*MathPow(10,Digits%2);
      for (int i = limit; i >= 0; i--)
      {   
         double thigh1 = High[iHighest(NULL, 0, MODE_HIGH,SlowLength,i)] + SlowPipDisplace*pipMultiplier;
         double tlow1  = Low[iLowest(NULL,   0, MODE_LOW, SlowLength,i)] - SlowPipDisplace*pipMultiplier;
         double thigh2 = High[iHighest(NULL, 0, MODE_HIGH,FastLength,i)] + FastPipDisplace*pipMultiplier;
         double tlow2  = Low[iLowest(NULL,   0, MODE_LOW, FastLength,i)] - FastPipDisplace*pipMultiplier;
            if (i<Bars-1 && Close[i]>line1[i+1])
                  line1[i] = tlow1;
            else  line1[i] = thigh1;             
            if (i<Bars-1 && Close[i]>line2[i+1])
                  line2[i] = tlow2;
            else  line2[i] = thigh2;             
            
            //
            //
            //
            //
            //
            
            hist1[i] = EMPTY_VALUE;
            hist2[i] = EMPTY_VALUE;
            arrou[i] = EMPTY_VALUE;
            arrod[i] = EMPTY_VALUE;
            trena[i] = i<Bars-1 ? trena[i+1] : 0;
            trend[i] = 0;
               if (Close[i]<line1[i] && Close[i]<line2[i]) trend[i] =  1;
               if (Close[i]>line1[i] && Close[i]>line2[i]) trend[i] = -1;
               if (line1[i]>line2[i] || trend[i] ==  1)    trena[i] =  1;
               if (line1[i]<line2[i] || trend[i] == -1)    trena[i] = -1;
               if (trend[i]== 1) { hist1[i] = High[i]; hist2[i] = Low[i]; }
               if (trend[i]==-1) { hist2[i] = High[i]; hist1[i] = Low[i]; }
               if (i<Bars-1 && trena[i]!=trena[i+1])
                  if (trena[i] == 1) 
                        arrod[i] = MathMax(line1[i],line2[i]);
                  else  arrou[i] = MathMin(line1[i],line2[i]);
            if (ShowCandles && i<numOfCandles) drawCandle(i,High[i],Low[i],Close[i],Open[i],(int)trend[i]);
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
  
void drawCandle(int i, double high, double low, double open, double close, int state)
{
   datetime time = Time[i];
   string   name = UniqueID+":"+(string)time+":";
   
      ObjectCreate(name,OBJ_TREND,0,0,0,0,0);
         ObjectSet(name,OBJPROP_COLOR,WickColor);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,high);
         ObjectSet(name,OBJPROP_PRICE2,low);
         ObjectSet(name,OBJPROP_RAY ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
      
   //
   //
   //
   //
   //
         
   name = name+"body";
      ObjectCreate(name,OBJ_TREND,0,0,0,0,0);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,open);
         ObjectSet(name,OBJPROP_PRICE2,close);
         ObjectSet(name,OBJPROP_WIDTH,BodyWidth);
         ObjectSet(name,OBJPROP_RAY  ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
         switch (state)
         {
            case -1: ObjectSet(name,OBJPROP_COLOR,BodyUpColor);   break;
            case  1: ObjectSet(name,OBJPROP_COLOR,BodyDownColor); break;
            default: ObjectSet(name,OBJPROP_COLOR,BodyNeutralColor);
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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
   if (AlertsOn)
   {
      int whichBar = (AlertsOnCurrent) ? 0 : 1;
      if (arrod[whichBar] != EMPTY_VALUE || arrou[whichBar] != EMPTY_VALUE)
      {
         static datetime time1 = 0;
         static string   mess1 = "";
            if (arrou[whichBar] != EMPTY_VALUE) doAlert(time1,mess1," ptl trend changed to up");
            if (arrod[whichBar] != EMPTY_VALUE) doAlert(time1,mess1," ptl trend changed to down");
      }
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message = _Symbol+" "+timeFrameToString(_Period)+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" ptl "+doWhat;
          if (AlertsMessage)      Alert(message);
          if (AlertsEmail)        SendMail(Symbol()+" ptl",message);
          if (AlertsNotification) SendNotification(message);
          if (AlertsSound)        PlaySound("alert2.wav");
   }
}