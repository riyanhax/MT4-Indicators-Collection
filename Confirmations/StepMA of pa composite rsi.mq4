//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrDarkGray
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrOrange
#property indicator_color4  clrOrange
#property indicator_width1  2
#property indicator_width2  3
#property indicator_width3  3
#property indicator_width4  3
#property strict

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

extern double             PaCycles           = 1.0;         // phase accumulation cycle
extern double             PaFilter           = 1.0;         // phase accumulation filter
extern enPrices           RsiPrice           = pr_close;    // Rsi price
extern int                RsiDepth           = 3;           // Depth of rsi
extern bool               RsiFast            = false;       // rsi fast
extern double             Sensitivity        = 4;           // Sensivity Factor
extern double             StepSize           = 5;           // Constant Step Size
extern bool               alertsOn           = false;       // Turn alerts on
extern bool               alertsOnCurrent    = true;        // Alerts on still opened bar
extern bool               alertsMessage      = true;        // Alerts should show message
extern bool               alertsNotification = false;       // Alerts should send notification
extern bool               alertsSound        = false;       // Alerts should play a sound
extern bool               alertsEmail        = false;       // Alerts should send email

double rsi[];
double LineBuffer[];
double DnBuffera[];
double DnBufferb[];
double smin[];
double smax[];
double trend[];

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
   IndicatorBuffers(7);
   SetIndexBuffer(0,rsi); 
   SetIndexBuffer(1,LineBuffer); 
   SetIndexBuffer(2,DnBuffera);
   SetIndexBuffer(3,DnBufferb);
   SetIndexBuffer(4,smin);
   SetIndexBuffer(5,smax);
   SetIndexBuffer(6,trend);
   RsiDepth = fmax(fmin(RsiDepth,25),2);
   IndicatorShortName("StepMA of pa composite rsi(("+DoubleToStr(PaCycles,2)+","+(string)RsiDepth+","+(string)Sensitivity+","+(string)StepSize+")");

   return(0);
}
int deinit() { return(0); }     

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
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
        
      if (trend[limit]==-1) CleanPoint(limit,DnBuffera,DnBufferb);
      for(int i=limit; i>=0; i--) 
      {
         if (i<Bars-1)
         {
            double RsiPeriod;
            double price  = getPrice(RsiPrice,Open,Close,High,Low,i);
            RsiPeriod = fmax(3,iHilbertPhase(price,PaFilter,PaCycles,i));
            rsi[i] = fabs(iCompRsi(price,RsiPeriod,RsiDepth,RsiFast,i)*100.0);
   	      LineBuffer[i] = iStepMa(Sensitivity,StepSize,0.5,rsi[i],rsi[i],rsi[i],i);
   	      DnBuffera[i]  = EMPTY_VALUE;
   	      DnBufferb[i]  = EMPTY_VALUE;
   	      if (trend[i]==-1) PlotPoint(i,DnBuffera,DnBufferb,LineBuffer);
   	    }
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

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workStep[][3];
#define _smin   0
#define _smax   1
#define _trend  2

double iStepMa(double sensitivity, double stepSize, double stepMulti, double phigh, double plow, double pprice, int r)
{
   if (ArrayRange(workStep,0)!=Bars) ArrayResize(workStep,Bars);
   if (sensitivity == 0) sensitivity = 0.0001; r = Bars-r-1;
   if (stepSize    == 0) stepSize    = 0.0001;
      double result = 0; 
	   double size = sensitivity*stepSize;

      //
      //
      //
      //
      //
      
      if (r==0)
      {
         workStep[r][_smax]  = phigh+2.0*size*stepMulti;
         workStep[r][_smin]  = plow -2.0*size*stepMulti;
         workStep[r][_trend] = 0;
         return(pprice);
      }

      //
      //
      //
      //
      //
      
      workStep[r][_smax]  = phigh+2.0*size*stepMulti;
      workStep[r][_smin]  = plow -2.0*size*stepMulti;
      workStep[r][_trend] = workStep[r-1][_trend];
            if (pprice>workStep[r-1][_smax]) workStep[r][_trend] =  1;
            if (pprice<workStep[r-1][_smin]) workStep[r][_trend] = -1;
            if (workStep[r][_trend] ==  1) { if (workStep[r][_smin] < workStep[r-1][_smin]) workStep[r][_smin]=workStep[r-1][_smin]; result = workStep[r][_smin]+size*stepMulti; }
            if (workStep[r][_trend] == -1) { if (workStep[r][_smax] > workStep[r-1][_smax]) workStep[r][_smax]=workStep[r-1][_smax]; result = workStep[r][_smax]-size*stepMulti; }
      trend[Bars-r-1] = workStep[r][_trend]; 

   return(result); 
} 

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workCompRsi[][26];
double iCompRsi(double price, double period, int depth, bool fast, int i, int instanceNo=0)
{
   double alpha;
   if (ArrayRange(workCompRsi,0) !=Bars) ArrayResize(workCompRsi,Bars);
   if (!fast)
        alpha = 2.0/(1.0 + period);
   else alpha = 2.0/(2.0 + (period-1.0)/2.0);
   instanceNo *= 26; i = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   double CU = 0;
   double CD = 0;
   for (int k=0; k<=depth; k++)
   {
      if (i == 0)
            workCompRsi[i][instanceNo+k] = price;
      else  workCompRsi[i][instanceNo+k] = workCompRsi[i-1][instanceNo+k]+alpha*(price-workCompRsi[i-1][instanceNo+k]);

      //
      //
      //
      //
      //
         
      price = workCompRsi[i][k+instanceNo];
      if (k>0)
         if (workCompRsi[i][instanceNo+k-1] >= workCompRsi[i][instanceNo+k])
              CU += workCompRsi[i][instanceNo+k-1] - workCompRsi[i][instanceNo+k  ];
         else CD += workCompRsi[i][instanceNo+k  ] - workCompRsi[i][instanceNo+k-1];
   }
   double trsi = 0; if (CU + CD != 0) trsi = CU / (CU + CD); 
   return(trsi);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workHil[][9];
#define _price      0
#define _smooth     1
#define _detrender  2
#define _period     3
#define _instPeriod 4
#define _phase      5
#define _deltaPhase 6
#define _Q1         7
#define _I1         8

double iHilbertPhase(double price, double filter, double cyclesToReach, int i, int s=0)
{
   if (ArrayRange(workHil,0)!=Bars) ArrayResize(workHil,Bars);
   int r = Bars-i-1; s = s*9;
      
   //
   //
   //
   //
   //
      
      workHil[r][s+_price]      = price; 
      if (r<6) { workHil[r][s+_smooth]=price; return(0); }
      workHil[r][s+_smooth]     = (4.0*workHil[r][s+_price]+3.0*workHil[r-1][s+_price]+2.0*workHil[r-2][s+_price]+workHil[r-3][s+_price])/10.0;
      workHil[r][s+_detrender]  = calcComp(r,_smooth,s);
      workHil[r][s+_Q1]         = 0.15*calcComp(r,_detrender,s)  +0.85*workHil[r-1][s+_Q1];
      workHil[r][s+_I1]         = 0.15*workHil[r-3][s+_detrender]+0.85*workHil[r-1][s+_I1];
      workHil[r][s+_phase]      = workHil[r-1][s+_phase];
      workHil[r][s+_instPeriod] = workHil[r-1][s+_instPeriod];

      //
      //
      //
      //
      //
           
         if (MathAbs(workHil[r][s+_I1])>0)
                     workHil[r][s+_phase] = 180.0/M_PI*MathArctan(MathAbs(workHil[r][s+_Q1]/workHil[r][s+_I1]));
           
         if (workHil[r][s+_I1]<0 && workHil[r][s+_Q1]>0) workHil[r][s+_phase] = 180.0-workHil[r][s+_phase];
         if (workHil[r][s+_I1]<0 && workHil[r][s+_Q1]<0) workHil[r][s+_phase] = 180.0+workHil[r][s+_phase];
         if (workHil[r][s+_I1]>0 && workHil[r][s+_Q1]<0) workHil[r][s+_phase] = 360.0-workHil[r][s+_phase];

      //
      //
      //
      //
      //
                        
      workHil[r][s+_deltaPhase] = workHil[r-1][s+_phase]-workHil[r][s+_phase];

         if (workHil[r-1][s+_phase]<90.0 && workHil[r][s+_phase]>270.0)
             workHil[r][s+_deltaPhase] = 360.0+workHil[r-1][s+_phase]-workHil[r][s+_phase];
             workHil[r][s+_deltaPhase] = MathMax(MathMin(workHil[r][s+_deltaPhase],60),7);
      
            //
            //
            //
            //
            //
            
           double alpha    = 2.0/(1.0+MathMax(filter,1));    
            double phaseSum = 0; int k=0; for (; phaseSum<cyclesToReach*360.0 && (r-k)>0; k++) phaseSum += workHil[r-k][s+_deltaPhase];
            if (k>0) workHil[r][s+_instPeriod]= k;
                     workHil[r][s+_period] = workHil[r-1][s+_period]+alpha*(workHil[r][s+_instPeriod]-workHil[r-1][s+_period]);
   return (workHil[r][s+_period]);
}

//
//
//
//
//

double calcComp(int r, int from, int s)
{
   return((0.0962*workHil[r  ][s+from] + 
           0.5769*workHil[r-2][s+from] - 
           0.5769*workHil[r-4][s+from] - 
           0.0962*workHil[r-6][s+from]) * (0.075*workHil[r-1][s+_period] + 0.54));
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
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars);
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

          message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" StepMa of RSI changed trend to "+doWhat;
             if (alertsMessage)      Alert(message);
             if (alertsNotification) SendNotification(message);
             if (alertsEmail)        SendMail(StringConcatenate(Symbol()," StepMa of RSI "),message);
             if (alertsSound)        PlaySound("alert2.wav");
      }
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
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}