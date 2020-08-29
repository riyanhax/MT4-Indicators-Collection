//+------------------------------------------------------------------+
//|                                          optimal tracking filter |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  DeepSkyBlue

//
//
//
//
//

extern int  Price  = PRICE_MEDIAN;

//
//
//
//
//

double otf[];
double buff[][3];

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
   SetIndexBuffer(0,otf);

   //
   //
   //
   //
   //
   
   string PriceType;
      switch(Price)
      {
         case PRICE_CLOSE:    PriceType = "Close";    break;  // 0
         case PRICE_OPEN:     PriceType = "Open";     break;  // 1
         case PRICE_HIGH:     PriceType = "High";     break;  // 2
         case PRICE_LOW:      PriceType = "Low";      break;  // 3
         case PRICE_MEDIAN:   PriceType = "Median";   break;  // 4
         case PRICE_TYPICAL:  PriceType = "Typical";  break;  // 5
         case PRICE_WEIGHTED: PriceType = "Weighted"; break;  // 6
      }      

   //
   //
   //
   //
   //

   IndicatorShortName (" Optimal tracking filter ("+PriceType+")");
   return(0);
}
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define _prc  0
#define _tmp1 1
#define _tmp2 2

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(buff,0) != Bars) ArrayResize(buff,Bars);

   //
   //
   //
   //
   //
   //

/*
inputs: Price((h+l)/2);
vars: lambda(0),
alpha(0);
Value1 = .2*(Price - Price[1]) + .8*Value1[1];
Value2 = .1*(H - L) + .8*Value2[1];
if Value2 <>0 then lambda = AbsValue(Value1 / Value2);
alpha = ( -lambda*lambda + SquareRoot(lambda*lambda*lambda*lambda + 16*lambda*lambda)) /8;
Value3 = alpha*Price + (1-alpha)*Value3[1];
Plot1(Value3, "AlphaTrack");
*/
   for(i=limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      buff[r][_prc] = iMA(NULL,0,1,0,MODE_SMA,Price,i);
      
      //
      //
      //
      //
      //

         buff[r][_tmp1] = 0.2*(buff[r][_prc]-buff[r-1][_prc])+0.8*buff[r-1][_tmp1];
         buff[r][_tmp2] = 0.1*(High[i]-Low[i])               +0.8*buff[r-1][_tmp2];
         if (buff[r][_tmp2]!=0)
               double lambda = MathAbs(buff[r][_tmp1]/buff[r][_tmp2]);
         else         lambda = 0;
         double alpha = ( -lambda*lambda + MathSqrt(lambda*lambda*lambda*lambda + 16.0*lambda*lambda))/8.0;

         //
         //
         //
         //
         //

         otf[i] = otf[i+1]+alpha*(buff[r][_prc]-otf[i+1]);
   }
   return(0);
}