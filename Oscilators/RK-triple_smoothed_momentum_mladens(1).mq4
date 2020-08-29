//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  OrangeRed
#property indicator_width1  2
#property indicator_color2  SpringGreen
#property indicator_width2  2
#property indicator_color3  Yellow
#property indicator_width3  2

#property indicator_level1  0

//
//
//
//
//

extern int MomentumLengthF = 10;
extern int MomentumLengthM = 14;
extern int MomentumLengthS = 21;
extern int MomentumPrice  = PRICE_CLOSE;
double momentumf[];
double momentumm[];
double momentums[];
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
   SetIndexBuffer(0,momentumf);SetIndexLabel(0,"3sm-b0-momfast (F"+MomentumLengthF+")");
   SetIndexBuffer(1,momentumm);SetIndexLabel(1,"3sm-b1-mommed (M"+MomentumLengthM+")");
   SetIndexBuffer(2,momentums);SetIndexLabel(2,"3sm-b2-momslow (S"+MomentumLengthS+")");
   SetIndexBuffer(3,trend);SetIndexLabel(2,"3sm-b3-trendmom");
   
   IndicatorShortName("RK-triple_Smoothed_momentum_mladens (F"+MomentumLengthF+") (S"+MomentumLengthM+") (S"+MomentumLengthS+")");
   return(0);
}
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

   for(int i=limit; i>=0; i--)
   {
       momentumf[i] = iMomentumF(iMA(NULL,0,1,0,MODE_SMA,MomentumPrice,i),MomentumLengthF,1,2,i);
       momentumm[i] = iMomentumM(iMA(NULL,0,1,0,MODE_SMA,MomentumPrice,i),MomentumLengthM,1,2,i);
       momentums[i] = iMomentumS(iMA(NULL,0,1,0,MODE_SMA,MomentumPrice,i),MomentumLengthS,1,2,i);
   //}       
   
      trend[i] = trend[i+1];
      if (momentumf[i] > momentums[i]) trend[i] = .0001;
      if (momentumf[i] < momentums[i]) trend[i] = -.0001;
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

double workMom[];
double iMomentumF(double price, double length, double powSlow, double powFast, int i)
{
   if (ArraySize(workMom)!=Bars) ArrayResize(workMom,Bars);
      i = Bars-i-1; workMom[i] = price;
     
      //
      
      double suma = 0.0, sumwa=0;
      double sumb = 0.0, sumwb=0;
         for(int k=0; k<length; k++)
         {
            double weight = length-k;
               suma  += workMom[i-k] * MathPow(weight,powSlow);
               sumb  += workMom[i-k] * MathPow(weight,powFast);
               sumwa += MathPow(weight,powSlow);
               sumwb += MathPow(weight,powFast);
         }
   return(sumb/sumwb-suma/sumwa);
}

double workMomm[];
double iMomentumM(double price, double length, double powSlow, double powFast, int i)
{
   if (ArraySize(workMomm)!=Bars) ArrayResize(workMomm,Bars);
      i = Bars-i-1; workMomm[i] = price;
      
     //
      
      double suma = 0.0, sumwa=0;
      double sumb = 0.0, sumwb=0;
         for(int k=0; k<length; k++)
         {
            double weight = length-k;
               suma  += workMomm[i-k] * MathPow(weight,powSlow);
               sumb  += workMomm[i-k] * MathPow(weight,powFast);
               sumwa += MathPow(weight,powSlow);
               sumwb += MathPow(weight,powFast);
         }
   return(sumb/sumwb-suma/sumwa);
}

double workMoms[];
double iMomentumS(double price, double length, double powSlow, double powFast, int i)
{
   if (ArraySize(workMoms)!=Bars) ArrayResize(workMoms,Bars);
      i = Bars-i-1; workMoms[i] = price;
      
     //
      
      double suma = 0.0, sumwa=0;
      double sumb = 0.0, sumwb=0;
         for(int k=0; k<length; k++)
         {
            double weight = length-k;
               suma  += workMoms[i-k] * MathPow(weight,powSlow);
               sumb  += workMoms[i-k] * MathPow(weight,powFast);
               sumwa += MathPow(weight,powSlow);
               sumwb += MathPow(weight,powFast);
         }
   return(sumb/sumwb-suma/sumwa);
}