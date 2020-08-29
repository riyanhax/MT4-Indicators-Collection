//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"

#property indicator_chart_window
#property indicator_buffers 4
#property strict

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};

extern int      CalcPeriod = 15;              // Calculation period
extern enPrices CalcPrice  = pr_close;        // Price
extern color    ColorUp    = clrDeepSkyBlue;  // Color for up trend
extern color    ColorDown  = clrSandyBrown;   // Color for down trend
extern int      LinesWidth = 2;               // Lines width for lines
extern int      BodyWidth  = 2;               // Body width for candles

double val1[],val2[],val3[],val4[],val0[],trend[];

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
   IndicatorBuffers(6);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
   SetIndexBuffer(2,val3);
   SetIndexBuffer(3,val4);
   SetIndexBuffer(4,val0);
   SetIndexBuffer(5,trend);
   return(0);
}

int start()
{
   static long sChartStyle=-1;
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit=MathMin(Bars-counted_bars,Bars-1);
   //
   //
   //
   //
   //

      long chartStyle; ChartGetInteger(0,CHART_MODE,0,chartStyle);
      if (sChartStyle != chartStyle)
      {
         sChartStyle=chartStyle; limit=Bars-1;
         switch ((int)chartStyle)
         {
            case CHART_BARS:
               SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,1,ColorUp);
               SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,1,ColorDown);
               SetIndexStyle(2,DRAW_NONE);
               SetIndexStyle(3,DRAW_NONE);
               break;
            case CHART_LINE:
               SetIndexStyle(0,DRAW_LINE,EMPTY,LinesWidth,ColorUp);
               SetIndexStyle(1,DRAW_LINE,EMPTY,LinesWidth,ColorDown);
               SetIndexStyle(2,DRAW_LINE,EMPTY,LinesWidth,ColorDown);
               SetIndexStyle(3,DRAW_NONE);
               break;
            default :               
               SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,1        ,ColorUp);
               SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,1        ,ColorDown);
               SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,BodyWidth,ColorUp);
               SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,BodyWidth,ColorDown);
         }
      }
      
      //
      //
      //
      //
      //

      if (chartStyle==CHART_LINE) CleanPoint(limit,val2,val3);      
      for(int i = limit; i >= 0; i--)
      {
         double price = getPrice(CalcPrice,Open,Close,High,Low,i);
         val0[i]  = iEma(price,CalcPeriod,i);
         val1[i]  = EMPTY_VALUE;
         val2[i]  = EMPTY_VALUE;
         val3[i]  = EMPTY_VALUE;
         val4[i]  = EMPTY_VALUE;
         trend[i] = 0; 
         if (val0[i]<price) trend[i] =  1;
         if (val0[i]>price) trend[i] = -1;
         if (trend[i]==1)
         {
            val3[i] = MathMax(Open[i],Close[i]);
            val4[i] = MathMin(Open[i],Close[i]);
            if (chartStyle!=CHART_LINE)
            {
               val1[i] = High[i];
               val2[i] = Low[i];
            }
            else
            {
               val1[i] = val0[i];
               val2[i] = EMPTY_VALUE;
               val3[i] = EMPTY_VALUE;
            }
         }
         if (trend[i]==-1)
         {
            val3[i] = MathMin(Open[i],Close[i]);
            val4[i] = MathMax(Open[i],Close[i]);
            if (chartStyle!=CHART_LINE)
            {
               val2[i] = High[i];
               val1[i] = Low[i];
            }
            else { val1[i] = val0[i]; PlotPoint(i,val2,val3,val0); }
         }
      }
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

double workEma[][1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars); r = Bars-r-1;

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
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
//

double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (price)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
   }
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