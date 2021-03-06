//+------------------------------------------------------------------+
//|                                           Schaff Trend Cycle.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

// TDesk code
#include <TDesk.mqh>
TDESKSIGNALS Signal=NONE, OldSignal=NONE;

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_label1  "STC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  2
#property indicator_label2  "STC"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_width2  2
#property indicator_label3  "STC"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_width3  2
#property strict

//
//
//
//
//

input int                 RefreshSeconds     = 30;
extern int                BarsToCalculate    = 100;
input bool                IgnoreOpenCandles  = false;
extern bool               SendTDeskSignals   = true;
extern string             TDeskIdentifier    = "Schaff Trend Cycle TD";
sinput string             S1                 = "---  settings ---";
input ENUM_TIMEFRAMES     TimeFrame          = 0;

input int    STCPeriod       = 10;               // Schaff period
input int    FastMAPeriod    = 23;               // Fast ema period
input int    SlowMAPeriod    = 50;               // Slow ema period
input bool   alertsOn        = true;             // Alerts on true/false?
input bool   alertsOnCurrent = false;            // Alerts on open bar true/false?
input bool   alertsMessage   = true;             // Alerts popup message true/false?
input bool   alertsSound     = true;             // Alerts sound true/false?
input bool   alertsEmail     = false;            // Alerts email true/false?
input bool   alertsPushNotif = false;            // Alerts notification true/false?
input string soundFile       = "alert2.wav";     // Sound file

double stc[],stcUA[],stcUB[],macd[],fastK[],fastD[],fastKK[],trend[];

int trendCyc=3;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(8);
      SetIndexBuffer(0,stc,   INDICATOR_DATA); 
      SetIndexBuffer(1,stcUA, INDICATOR_DATA);
      SetIndexBuffer(2,stcUB, INDICATOR_DATA);
      SetIndexBuffer(3,macd,  INDICATOR_CALCULATIONS);
      SetIndexBuffer(4,fastK, INDICATOR_CALCULATIONS);
      SetIndexBuffer(5,fastD, INDICATOR_CALCULATIONS);
      SetIndexBuffer(6,fastKK,INDICATOR_CALCULATIONS);
      SetIndexBuffer(7,trend, INDICATOR_CALCULATIONS);
   IndicatorShortName("Schhf Trend Cycle TD");//("+(string)STCPeriod+","+(string)FastMAPeriod+","+(string)SlowMAPeriod+")");
// TDesk code

   string tftext=EnumToString(TimeFrame);
   StringReplace(tftext,"PERIOD_","");
   IndicatorShortName(WindowExpertName()+" - "+tftext);

   InitializeTDesk(TDeskIdentifier);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) 
{
   string tftext=EnumToString(TimeFrame);
   StringReplace(tftext,"PERIOD_","");
   DeleteTDeskSignals(Symbol());
  
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int counted_bars=prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(rates_total-counted_bars,rates_total-1);

   //
   //
   //
   //
   //
   
   if (trend[limit]==1) CleanPoint(limit,stcUA,stcUB);
   for(int i = limit; i >= 0; i--)
   {
      macd[i] = iMA(NULL,0,FastMAPeriod,0,MODE_EMA,PRICE_TYPICAL,i)-iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,PRICE_TYPICAL,i);

      double loMacd   = macd[ArrayMinimum(macd,STCPeriod,i)];
      double hiMacd   = macd[ArrayMaximum(macd,STCPeriod,i)]-loMacd;
             fastK[i] = (hiMacd > 0) ? 100*((macd[i]-loMacd)/hiMacd) : (i<rates_total-1) ? fastK[i+1] : 0;
             fastD[i] = (i<rates_total-1) ? fastD[i+1]+0.5*(fastK[i]-fastD[i+1]) : fastK[i];
               
      double loStoch   = fastD[ArrayMinimum(fastD,STCPeriod,i)];
      double hiStoch   = fastD[ArrayMaximum(fastD,STCPeriod,i)]-loStoch;
             fastKK[i] = (hiStoch > 0) ? 100*((fastD[i]-loStoch)/hiStoch) : (i<rates_total-1) ? fastKK[i+1] : 0;
             stc[i]    = (i<rates_total-1) ? stc[i+1]+0.5*(fastKK[i]-stc[i+1]) : fastKK[i];
             stcUA[i]  = EMPTY_VALUE;
             trendCyc=1;
             stcUB[i]  = EMPTY_VALUE;
             trendCyc=2;
             trend[i]  = (i<rates_total-1) ? (stc[i] > stc[i+1]) ? 1 : (stc[i] < stc[i+1]) ? -1 : trend[i+1] : 0;      
             if (trend[i] == 1) PlotPoint(i,stcUA,stcUB,stc);
   //} 
 
 // TDesk code
   if(SendTDeskSignals)
   {Signal=FLAT;
      if(stcUA[i]  == EMPTY_VALUE) Signal=SHORT; else
      if(stcUB[i]  == EMPTY_VALUE) Signal=LONG; 
      //Signal=FLAT;
      if(Signal!=OldSignal)
      {
         PublishTDeskSignal("STC-X",TimeFrame,Symbol(),Signal);
         OldSignal=Signal;
      }
   }}

 
 
 
   
   if (alertsOn)
   {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(" sloping up");
          
            if (trend[whichBar] ==-1) doAlert(" sloping down");       
         
         }         
    }       
 
return(rates_total);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }


  
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
          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Schaff Trend Cycle "+doWhat;
             if (alertsMessage)     Alert(message);
             if (alertsPushNotif )  SendNotification(message);
             if (alertsEmail)       SendMail(_Symbol+" Schaff Trend Cycle ",message);
             if (alertsSound)       PlaySound(soundFile);
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