//+------------------------------------------------------------------+
//|                                               HA_with_button.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_buffers 4
#property indicator_color1  clrRed
#property indicator_color2  clrRoyalBlue
#property indicator_color3  clrRed
#property indicator_color4  clrRoyalBlue
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  3
#property indicator_width4  3
#property indicator_chart_window

extern bool value_to_toggle = true; // The Value to Toggle

// unique identifier that we can access from multiple places throughout the code
string sButtonName = "toggle_button";

enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};

//---- parameters
extern enMaTypes      MaMetod          = ma_ema;            // Ma1 METHOD
extern int            MaPeriod         = 6;                 // Ma1 Period
extern enMaTypes      MaMetod2         = ma_lwma;           // Ma2 METHOD
extern int            MaPeriod2        = 2;                 // Ma2 Period
extern bool           alertsOn         = true;              // Turn alerts on?
extern bool           alertsOnCurrent  = false;             // Alerts on still opened bar?
extern bool           alertsMessage    = true;              // Alerts should show popup message?
extern bool           alertsSound      = false;             // Alerts should play a sound?
extern bool           alertsNotify     = false;             // Alerts should send notification?
extern bool           alertsEmail      = false;             // Alerts should send email?
extern string         soundFile        = "alert2.wav";      // Alerts sound file
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
double trend[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
  {
//--- indicator buffers mapping
   Toggle()
   IndicatorBuffers(9);
   SetIndexBuffer(0,ExtMapBuffer1); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer3); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,ExtMapBuffer4); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);
   SetIndexBuffer(8,trend);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
   int counted_bars=IndicatorCounted();
   int limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
   
   //
   //
   //
   //
   //
   
   for (int pos=limit; pos >= 0; pos--)
   {  
      double maOpen  = iCustomMa(MaMetod,Open[pos], MaPeriod,pos,0);
      double maClose = iCustomMa(MaMetod,Close[pos],MaPeriod,pos,1);
      double maLow   = iCustomMa(MaMetod,Low[pos],  MaPeriod,pos,2);
      double maHigh  = iCustomMa(MaMetod,High[pos], MaPeriod,pos,3);
      double haOpen  = maOpen;
      if (pos<Bars-1) haOpen  = (ExtMapBuffer5[pos+1]+ExtMapBuffer6[pos+1])/2;
               double haClose = (maOpen+maHigh+maLow+maClose)/4;
               double haHigh  = fmax(maHigh,fmax(haOpen, haClose));
               double haLow   = fmin(maLow, fmin(haOpen, haClose));

               if (haOpen<haClose) { ExtMapBuffer7[pos]=haLow;  ExtMapBuffer8[pos]=haHigh;} 
               else                { ExtMapBuffer7[pos]=haHigh; ExtMapBuffer8[pos]=haLow; } 
               ExtMapBuffer5[pos]=haOpen;
               ExtMapBuffer6[pos]=haClose;

               ExtMapBuffer1[pos]=iCustomMa(MaMetod2,ExtMapBuffer7[pos],MaPeriod2,pos,4);
               ExtMapBuffer2[pos]=iCustomMa(MaMetod2,ExtMapBuffer8[pos],MaPeriod2,pos,5);
               ExtMapBuffer3[pos]=iCustomMa(MaMetod2,ExtMapBuffer5[pos],MaPeriod2,pos,6);
               ExtMapBuffer4[pos]=iCustomMa(MaMetod2,ExtMapBuffer6[pos],MaPeriod2,pos,7);
               trend[pos] = (pos<Bars-1) ? (ExtMapBuffer3[pos]<ExtMapBuffer4[pos]) ? 1 : (ExtMapBuffer3[pos]>ExtMapBuffer4[pos]) ? -1 : trend[pos+1] : 0;
   }   
      
   //
   //
   //
   //
   //
      
    if (alertsOn)
    {
       int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
       if (trend[whichBar] != trend[whichBar+1])
       if (trend[whichBar] == 1)
              doAlert("up");
       else  doAlert("down");       
     }       
return(0);
}
#define _maInstances 8
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   int bars = Bars; r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
   {
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
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
          
          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Heiken_Ashi_Smoothed ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Heiken_Ashi_Smoothed "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   // if the sparam passed to the function is the unique id of the button then toggle it
   if(sparam==sButtonName) Toggle();
   
  }
//+------------------------------------------------------------------+

void Toggle(){
// function to handle toggle
   color cColor  = clrLimeGreen;
   uchar ucArrow = 233;
   // use a string type if you need text on your button
   
   if(value_to_toggle == true){
      cColor = clrRed;
      ucArrow = 234;
   }
   
   CreateButton(sButtonName,cColor,"Wingdings",CharToStr(ucArrow));
   value_to_toggle = !value_to_toggle;
   
   Comment("The value of value_to_toggle is ", value_to_toggle);
       
}

void CreateButton(string sName, color cColor, string sFont = "Wingdings", string sText = ""){
// create a button on the chart

// many of these settings are hard coded below but you can easily have them as paramaters and pass them to the function
// just like I've done already with the color, font and text

   if(ObjectFind(sName)< 0){
      ObjectCreate(0,sName,OBJ_BUTTON,0,0,0);
   }
   
   // these could be external valiables to allow the user to create the button wherever they wanted
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,75);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,25);
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,50);
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,50);
   ObjectSetInteger(0,sName,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   
   ObjectSetString(0,sName,OBJPROP_TEXT,sText);
   ObjectSetInteger(0,sName,OBJPROP_COLOR, cColor);
   // I'm setting the background and border to the same as the chart background
   // as I'm just using a wingding arrow
   long result;

   ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,result);

   color cBack = (color) result;

   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR, cBack);

   ObjectSetInteger(0,sName,OBJPROP_BORDER_COLOR,cBack);
   // make sure our object shows up in the 'Objects List'
   ObjectSetInteger(0,sName,OBJPROP_HIDDEN, false);
   // commmented out some settings as they are not used
   // I would have normally deleted them but left them for completeness
   //ObjectSetInteger(0,sName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   //ObjectSetInteger(0,sName,OBJPROP_STATE,false);
   ObjectSetString(0,sName,OBJPROP_FONT,sFont);
   ObjectSetInteger(0,sName,OBJPROP_FONTSIZE,28);
   
}