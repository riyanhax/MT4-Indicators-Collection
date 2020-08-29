//------------------------------------------------------------------
#property link      "www.forex-station.com"
#property copyright "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property strict
#property indicator_buffers 3
#property indicator_label1  "Blau TVI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_width1  2
#property indicator_label2  "Blau TVI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label3  "Blau TVI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2

//
//
//
//
//

input double          tr     = 12;              // Period 1
input double          s      = 12;              // Period 2
input double          u      = 5;               // Period 3
input double          levUp  = 4.0;             // Upper level
input double          levDn  = -4.0;            // Lower level
input color           levClr = clrMediumOrchid; // Level color
input ENUM_LINE_STYLE levSty = STYLE_DOT;       // Level style 

double val[],valda[],valdb[],valc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valda,INDICATOR_DATA);
   SetIndexBuffer(2,valdb,INDICATOR_DATA);
   SetIndexBuffer(3,valc);
   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble( INDICATOR_LEVELVALUE,0,levUp);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,levSty);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,levClr);  
   IndicatorSetDouble( INDICATOR_LEVELVALUE,1,levDn);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,levSty);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,levClr);  
   IndicatorSetDouble( INDICATOR_LEVELVALUE,2,0);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,levSty);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,levClr);  

   IndicatorSetString(INDICATOR_SHORTNAME,"Blau TVI ("+DoubleToStr(tr,2)+","+DoubleToStr(s,2)+","+DoubleToStr(u,2)+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){ } 

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; 
   if (valc[i]==-1) iCleanPoint(i,valda,valdb);
   for (; i>=0 && !_StopFlag; i--)
   {
      double upTic = (tick_volume[i]+(close[i]-open[i])/_Point)/2.0;
      double dnTic = (tick_volume[i]-upTic);
      double avgUp = iEma(iEma(upTic,tr,i,rates_total,0),s,i,rates_total,1);
      double avgDn = iEma(iEma(dnTic,tr,i,rates_total,2),s,i,rates_total,3);
      val[i] = (avgUp+avgDn != 0) ? iEma(100.0*(avgUp-avgDn)/(avgUp+avgDn),u,i,rates_total,4) : 0;   
      valda[i] = valdb[i] = EMPTY_VALUE;
      valc[i]  = (i<rates_total-1) ? (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? -1 : valc[i+1] : 0;
      if (valc[i] == -1) iPlotPoint(i,valda,valdb,val);     
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

double workEma[][5];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);  r = _bars-r-1;

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void iCleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

