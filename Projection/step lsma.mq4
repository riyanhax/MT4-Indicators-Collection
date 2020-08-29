//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3 
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrOrange
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
#property strict


input int     inpLength        = 20;      // Lsma length
input double  Sensitivity      = 2;       // Sensivity Factor
input double  StepSize         = 5;       // Constant Step Size
input bool    HighLow          = false;   // High/Low Mode Switch (more sensitive)


double val[],valda[],valdb[],smin[],smax[],valc[];


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
   IndicatorBuffers(6);
   SetIndexBuffer(0,val,  INDICATOR_DATA); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,valda,INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE); 
   SetIndexBuffer(2,valdb,INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE); 
   SetIndexBuffer(3,smin);
   SetIndexBuffer(4,smax);
   SetIndexBuffer(5,valc);
   IndicatorSetString(INDICATOR_SHORTNAME,"Step Lsma("+(string)inpLength+","+(string)Sensitivity+","+(string)StepSize+")");   
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){     }


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
                 const int&      spread[] )
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1;

   //
   //
   //
   //
   //
        
   double useSize = _Point*pow(10,fmod(_Digits,2));
   if (valc[i]==-1) CleanPoint(i,valda,valdb);
   for (; i>=0 && !_StopFlag; i--)
   {
      double thigh,tlow;
         if (HighLow)
	            { thigh=iLsma(low[i]  ,inpLength,i,rates_total,0); tlow =iLsma(high[i] ,inpLength,i,rates_total,1); } 	
	      else  { thigh=iLsma(close[i],inpLength,i,rates_total,0); tlow =iLsma(close[i],inpLength,i,rates_total,1); }
   	   val[i]   = iStepMa(Sensitivity,StepSize,useSize,thigh,tlow,close[i],i,rates_total);
   	   valda[i] = valdb[i] = EMPTY_VALUE; if (valc[i] == -1) PlotPoint(i,valda,valdb,val);
   	     
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

#define lsmaInstances 2
#define lsmaWorkBufferx1 1*lsmaInstances
double workLinr[][lsmaWorkBufferx1];
double iLsma(double price, int period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= bars) ArrayResize(workLinr,bars); r = bars-r-1;

   //
   //
   //
   //
   //
   
      period = fmax(period,1);
      workLinr[r][instanceNo] = price;
      if (r<period) return(price);
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
return(3.0*lwma/lwmw-2.0*sma/period);
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

double iStepMa(double sensitivity, double stepSize, double stepMulti, double phigh, double plow, double pprice, int r, int bars)
{
   if (ArrayRange(workStep,0)!=bars) ArrayResize(workStep,bars);
   if (sensitivity == 0) sensitivity = 0.0001; r = bars-r-1;
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
      valc[bars-r-1] = workStep[r][_trend]; 

   return(result); 
} 

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
