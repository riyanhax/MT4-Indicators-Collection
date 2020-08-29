//------------------------------------------------------------------
#property copyright   "copyright© mladen"
#property description "McGinley dynamic average"
#property description "made for metatrader by mladen"
#property description "for more visit www.forex-tsd.com"
#property link        "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers    3
#property indicator_color1     LimeGreen
#property indicator_color2     Orange
#property indicator_color3     Orange
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property strict

enum maMethod
{
   ma_sma,  // Simple moving average
   ma_ema,  // Exponential moving average
   ma_smma, // Smoothed moving average
   ma_lwma, // Linear weighted moving average
   ma_gen   // Generic moving average
};
extern int                McgPeriod   = 21;           // Average period
extern ENUM_APPLIED_PRICE McgPrice    = PRICE_CLOSE;  // Price to use
extern double             McgConstant = 0.6;          // Constant
extern maMethod           McgMaMethod = ma_ema;       // Average mode

double mcg[];
double mcgda[];
double mcgdb[];
double slope[];
double ma[];

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
   IndicatorBuffers(5);
   SetIndexBuffer(0,mcg);
   SetIndexBuffer(1,mcgda);
   SetIndexBuffer(2,mcgdb);
   SetIndexBuffer(3,slope);
   SetIndexBuffer(4,ma);
   
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--; 
         int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   if (slope[limit]==-1) CleanPoint(limit,mcgda,mcgdb);
   for(int i=limit; i>=0; i--)
   {
      if (McgMaMethod<ma_gen)
         ma[i] = iMA(NULL,0,McgPeriod,0,(int)McgMaMethod,McgPrice,i);
      else         
         ma[i] = (iMA(NULL,0,McgPeriod,0,MODE_SMA ,McgPrice,i)+
                  iMA(NULL,0,McgPeriod,0,MODE_EMA ,McgPrice,i)+
                  iMA(NULL,0,McgPeriod,0,MODE_SMMA,McgPrice,i)+
                  iMA(NULL,0,McgPeriod,0,MODE_LWMA,McgPrice,i))/4.0;
      
      if (i<(Bars-1) && ma[i+1]!=0)
      {
         double price = iMA(NULL,0,1,0,MODE_SMA,McgPrice,i);
         mcg[i]   = ma[i+1]+(price-ma[i+1])/(McgConstant*McgPeriod*MathPow(price/ma[i+1],4));
         mcgda[i] = EMPTY_VALUE;
         mcgdb[i] = EMPTY_VALUE;
         slope[i] = slope[i+1];
            if (mcg[i]>mcg[i+1]) slope[i] =  1;
            if (mcg[i]<mcg[i+1]) slope[i] = -1;
            if (slope[i]==-1) PlotPoint(i,mcgda,mcgdb,mcg);
      }               
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
   if (i>Bars-2) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>Bars-3) return;
   if (first[i+1] == EMPTY_VALUE)
         if (first[i+2] == EMPTY_VALUE) 
               { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
         else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else        { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}