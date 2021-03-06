//+------------------------------------------------------------------+
//|                                                     Blau_Mtm.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property link      "www.forex-station.com"
#property copyright "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 5 
#property indicator_color1  clrLinen
#property indicator_width2  2
#property indicator_color2  clrLimeGreen
#property indicator_width2  2
#property indicator_color3  clrLimeGreen
#property indicator_width3  2
#property indicator_color4  clrRed
#property indicator_width4  2
#property indicator_color5  clrRed
#property indicator_width5  2
#property strict

extern ENUM_TIMEFRAMES   TimeFrame   = PERIOD_CURRENT; // Time frame
input int                Length      = 2;              // Momentum length
input int                SmLen1      = 20;             // First smooth length
input int                SmLen2      = 5;              // Second momentum length
input int                SmLen3      = 3;              // Third momentum length
input ENUM_APPLIED_PRICE Price       = PRICE_CLOSE;    // Applied price
extern bool              Interpolate = true;           // Interpolate in multi time frame mode   

double val[],mom[],momUa[],momUb[],momDa[],momDb[],valc[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Length,SmLen1,SmLen2,SmLen3,Price,_buff,_ind)

int OnInit()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,val,  INDICATOR_DATA); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,momUa,INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,momUb,INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE); 
   SetIndexBuffer(3,momDa,INDICATOR_DATA); SetIndexStyle(3,DRAW_LINE); 
   SetIndexBuffer(4,momDb,INDICATOR_DATA); SetIndexStyle(4,DRAW_LINE);  
   SetIndexBuffer(5,mom);
   SetIndexBuffer(6,valc);
   SetIndexBuffer(7,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
   
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(TimeFrame)+" William Blau Momentum oscillator");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){    }

//
//
//
//
//

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& time[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[])

{
   int i,limit=fmin(rates_total-prev_calculated+1,rates_total-1); count[0] = limit;
      if (TimeFrame!=_Period)
      {
         limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(7,0)*TimeFrame/_Period));
         if (valc[limit]== 1) CleanPoint(limit,momUa,momUb);
         if (valc[limit]==-1) CleanPoint(limit,momDa,momDb);
         for (i=limit;i>=0 && !_StopFlag; i--)
         {
             int y = iBarShift(NULL,TimeFrame,time[i]);
                val[i]   = _mtfCall(0,y);
                momUa[i] = momUb[i] = EMPTY_VALUE;
                momDa[i] = momDb[i] = EMPTY_VALUE; 
                valc[i]  = _mtfCall(6,y);
                 
                //
                //
                //
                //
                //
                     
                if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                   #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                   int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                      for(n = 1; (i+n)<rates_total && time[i+n] >= btime; n++) continue;	
                      for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) _interpolate(val);                                      
         }   
         for(i=limit; i>=0; i--)
         {
            
            if (valc[i] ==  1) PlotPoint(i,momUa,momUb,val);
            if (valc[i] == -1) PlotPoint(i,momDa,momDb,val);     
         }
   return(rates_total);
   }
   
   //
   //
   //
   //
   //
   
   if (valc[limit]== 1) CleanPoint(limit,momUa,momUb);
   if (valc[limit]==-1) CleanPoint(limit,momDa,momDb);
   for(i=limit;i>=0 && !_StopFlag; i--)
   {
      mom[i] = iMA(NULL,0,1,0,MODE_SMA,Price,i)-iMA(NULL,0,1,0,MODE_SMA,Price,(int)fmin(rates_total-1,i+Length));
      double avg = iEma(iEma(iEma(     mom[i], SmLen1,i,rates_total,0),SmLen2,i,rates_total,1),SmLen3,i,rates_total,2);
      double ava = iEma(iEma(iEma(fabs(mom[i]),SmLen1,i,rates_total,3),SmLen2,i,rates_total,4),SmLen3,i,rates_total,5);
             val[i] = (ava != 0) ? 100.0*avg/ava : 0;
             valc[i] = (i<rates_total-1) ? (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? -1 : valc[i+1] : 0;
             momUa[i] = momUb[i] = EMPTY_VALUE; if (valc[i] ==  1) PlotPoint(i,momUa,momUb,val);
             momDa[i] = momDb[i] = EMPTY_VALUE; if (valc[i] == -1) PlotPoint(i,momDa,momDb,val); 
   } 
 return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workEma[][6];
double iEma(double price, double period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= bars) ArrayResize(workEma,bars); i = bars-i-1;

   //
   //
   //
   //
   //
   
   workEma[i][instanceNo] = price;  
   double alpha = 2.0 / (1.0+period);
   if (i>0)
          workEma[i][instanceNo] = workEma[i-1][instanceNo]+alpha*(price-workEma[i-1][instanceNo]);
   return(workEma[i][instanceNo]);
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
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



