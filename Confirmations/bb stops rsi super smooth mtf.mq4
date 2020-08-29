//+------------------------------------------------------------------+
//|                                                           rsiSS  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers    7
#property indicator_color1     clrBlue
#property indicator_color2     clrMaroon
#property indicator_color3     clrMaroon
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
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
   pr_highlow,    // High/low
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_hahighlow   // Heiken ashi high/low
};

enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};

enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};
 
extern ENUM_TIMEFRAMES TimeFrame            = PERIOD_CURRENT;  // Time frame
extern int             RsiPeriod            = 10;              // Rsi period
extern enRsiTypes      RsiMethod            = rsi_rsx;         // Rsi type
extern enPrices        RsiPrice             = pr_close;        // Rsi price to use
extern int             RsiSmoothing         = 20;              // Super smoothing period
extern int             BandsPeriod          = 20;              // Bands period
extern enMaTypes       BandsMaType          = ma_sma;          // Bands average type
extern double          BandsDeviation       = 1;               // Bands deviation
extern bool            BandsDeviationSample = false;           // Bands deviation with sample correction?
extern double          BandsRisk            = 1;               // Bands risk
extern int             BBUpDotSize          = 1;               // Upper band dot size
extern color           BBUpDotColor         = clrGreen;        // Upper band color
extern int             BBDnDotSize          = 1;               // Lower band dot size
extern color           BBDnDotColor         = clrRed;          // Lower band color
extern bool            Interpolate          = true;            // Interpolate in multi time frame mode?

//
//
//
//
//

double rsi[],rsida[],rsidb[],bblu[],bbld[],upa[],dna[],amax[],amin[],bmin[],bmax[],trend[],slope[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiMethod,RsiPrice,RsiSmoothing,BandsPeriod,BandsMaType,BandsDeviation,BandsDeviationSample,BandsRisk,BBUpDotSize,BBUpDotColor,BBDnDotSize, BBDnDotColor,_buff,_y)

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
    IndicatorBuffers(14);
    SetIndexBuffer(0, rsi);
    SetIndexBuffer(1, rsida);
    SetIndexBuffer(2, rsidb);
    SetIndexBuffer(3, bblu);     SetIndexStyle(3,DRAW_ARROW,EMPTY,BBUpDotSize,BBUpDotColor); SetIndexArrow(3,159);
    SetIndexBuffer(4, bbld);     SetIndexStyle(4,DRAW_ARROW,EMPTY,BBDnDotSize,BBDnDotColor); SetIndexArrow(4,159);
    SetIndexBuffer(5, upa);      SetIndexStyle(5,DRAW_ARROW,EMPTY,BBUpDotSize,BBUpDotColor); SetIndexArrow(5,108);
    SetIndexBuffer(6, dna);      SetIndexStyle(6,DRAW_ARROW,EMPTY,BBDnDotSize,BBDnDotColor); SetIndexArrow(6,108);
    SetIndexBuffer(7, amax);
    SetIndexBuffer(8, amin);
    SetIndexBuffer(9, bmax);
    SetIndexBuffer(10,bmin);
    SetIndexBuffer(11,trend);
    SetIndexBuffer(12,slope);
    SetIndexBuffer(13,count);
   
    indicatorFileName = WindowExpertName();
    TimeFrame         = fmax(TimeFrame,_Period);  
    
   IndicatorShortName(timeFrameToString(TimeFrame)+" bb stops of "+getRsiName((int)RsiMethod)+" super smoother ("+(string)RsiPeriod+","+(string)RsiSmoothing+")");
return(0);
}
int deinit() {  return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(13,0)*TimeFrame/_Period));
               if  (slope[limit] == -1) CleanPoint(limit,rsida,rsidb);
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     rsi[i]   = _mtfCall(0,y);
                     rsida[i] = EMPTY_VALUE;
                     rsidb[i] = EMPTY_VALUE;
                     bblu[i]  = EMPTY_VALUE; 
                     bbld[i]  = EMPTY_VALUE;
                     bmax[i]  = _mtfCall( 9,y);
                     bmin[i]  = _mtfCall(10,y);
                     trend[i] = _mtfCall(11,y);
                     slope[i] = _mtfCall(12,y);
                 
                     //
                     //
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           {
                              _interpolate(rsi);
                              _interpolate(bmax);
                              _interpolate(bmin);
                           }                           
              }
              for (i=limit; i >= 0; i--)
              {
                   if (trend[i] ==  1) bblu[i] = bmin[i];
                   if (trend[i] == -1) bbld[i] = bmax[i];
                   upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? bblu[i] : EMPTY_VALUE :  EMPTY_VALUE;
                   dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? bbld[i] : EMPTY_VALUE :  EMPTY_VALUE;
	                if (slope[i] == -1) PlotPoint(i,rsida,rsidb,rsi);  
	            }  
               return(0);
           }

   //
   //
   //
   //
   //
   
     if  (slope[limit] == -1) CleanPoint(limit,rsida,rsidb);
     for (i=limit; i >= 0; i--)
     {
        rsi[i] = iRsi(RsiMethod,iSsm(getPrice(RsiPrice,Open,Close,High,Low,i),RsiSmoothing,i,0),RsiPeriod,i);
        double dev = iDeviation(rsi[i],BandsPeriod,BandsDeviationSample,i);
        double ma  = iCustomMa(BandsMaType,rsi[i],BandsPeriod,i);
                 amax[i]  = ma+dev*BandsDeviation;
                 amin[i]  = ma-dev*BandsDeviation;
   	           bmax[i]  = amax[i]+0.5*(BandsRisk-1)*(amax[i]-amin[i]);
	  	           bmin[i]  = amin[i]-0.5*(BandsRisk-1)*(amax[i]-amin[i]);
	  	           rsida[i] = EMPTY_VALUE;
                 rsidb[i] = EMPTY_VALUE;
                 slope[i] = (i<Bars-1) ? (rsi[i]>rsi[i+1])  ? 1 : (rsi[i]<rsi[i+1])  ? -1 : slope[i+1] : 0;  
                 trend[i] = (i<Bars-1) ? (rsi[i]>amax[i+1]) ? 1 : (rsi[i]<amin[i+1]) ? -1 : trend[i+1] : 0;
                         if (i<Bars-1)
                         {
                             if (trend[i]==-1 && amax[i]>amax[i+1]) amax[i] = amax[i+1];
                             if (trend[i]== 1 && amin[i]<amin[i+1]) amin[i] = amin[i+1];
                             if (trend[i]==-1 && bmax[i]>bmax[i+1]) bmax[i] = bmax[i+1];
                             if (trend[i]== 1 && bmin[i]<bmin[i+1]) bmin[i] = bmin[i+1];
                         }                  
                 bblu[i]  = EMPTY_VALUE; 
                 bbld[i]  = EMPTY_VALUE;
                 if (trend[i] ==  1) bblu[i] = bmin[i];
                 if (trend[i] == -1) bbld[i] = bmax[i];
                 upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? bblu[i] : EMPTY_VALUE :  EMPTY_VALUE;
                 dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? bbld[i] : EMPTY_VALUE :  EMPTY_VALUE;
	              if (slope[i] == -1) PlotPoint(i,rsida,rsidb,rsi);    
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

#define Pi 3.14159265358979323846264338327950288
double workSsm[][2];
#define _tprice  0
#define _ssm     1

double workSsmCoeffs[][4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3

double iSsm(double price, double period, int i, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_speriod] != period)
   {
      workSsmCoeffs[instanceNo][_speriod] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_sc2] = b1;
         workSsmCoeffs[instanceNo][_sc3] = -a1*a1;
         workSsmCoeffs[instanceNo][_sc1] = 1.0 - workSsmCoeffs[instanceNo][_sc2] - workSsmCoeffs[instanceNo][_sc3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2; i=Bars-i-1;
      workSsm[i][s+_ssm]    = price;
      workSsm[i][s+_tprice] = price;
      if (i>1)
      {  
          workSsm[i][s+_ssm] = workSsmCoeffs[instanceNo][_sc1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0 + 
                               workSsmCoeffs[instanceNo][_sc2]*workSsm[i-1][s+_ssm]                                + 
                               workSsmCoeffs[instanceNo][_sc3]*workSsm[i-2][s+_ssm]; }
   return(workSsm[i][s+_ssm]);
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

string rsiMethodNames[] = {"RSI","Slow RSI","Rapid RSI","Harris RSI","RSX","Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=fmax(fmin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

#define rsiInstances 1
double workRsi[][rsiInstances*13];
#define _price  0
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1

double iRsi(int rsiMode, double price, double period, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case rsi_rsi:
         {
         double alpha = 1.0/fmax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += fabs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/fmax(k,1);
                  workRsi[r][z+_changa] =                                         sum/fmax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(     change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(fabs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         }
         
      //
      //
      //
      //
      //
      
      case rsi_wil :
         {         
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if (r<1)
                  workRsi[r][z+_rsival] = 50;
            else               
               if(up + dn == 0)
                     workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/fmax(period,1))*(50            -workRsi[r-1][z+_rsival]);
               else  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/fmax(period,1))*(100*up/(up+dn)-workRsi[r-1][z+_rsival]);
            return(workRsi[r][z+_rsival]);      
         }
      
      //
      //
      //
      //
      //

      case rsi_rap :
         {
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if(up + dn == 0)
                  return(50);
            else  return(100 * up / (up + dn));      
         }            

      //
      //
      //
      //
      //

      
      case rsi_har :
         {
            double avgUp=0,avgDn=0; double up=0; double dn=0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][instanceNo+_price]- workRsi[r-k-1][instanceNo+_price];
               if(diff>0)
                     { avgUp += diff; up++; }
               else  { avgDn -= diff; dn++; }
            }
            if (up!=0) avgUp /= up;
            if (dn!=0) avgDn /= dn;
            double rs = 1;
               if (avgDn!=0) rs = avgUp/avgDn;
               return(100-100/(1.0+rs));
         }               

      //
      //
      //
      //
      //
      
      case rsi_rsx :  
         {   
            double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
            if (r<period) { for (int k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

            //
            //
            //
            //
            //
      
            double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
            double moa = fabs(mom);
            for (int k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            if (moa != 0)
                 return(fmax(fmin((mom/moa+1.0)*50.0,100.00),0.00)); 
            else return(50);
         }            
            
      //
      //
      //
      //
      //
      
      case rsi_cut :
         {
            double sump = 0;
            double sumn = 0;
            for (int k=0; k<(int)period && r-k-1>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0) sump += diff;
                  if (diff < 0) sumn -= diff;
            }
            if (sumn > 0)
                  return(100.0-100.0/(1.0+sump/sumn));
            else  return(50);
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

#define _maInstances 1
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

#define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double value, int length, bool isSample, int i, int instanceNo=0)
{
   if (ArrayRange(workDev,0)!=Bars) ArrayResize(workDev,Bars); i=Bars-i-1; workDev[i][instanceNo] = value;
                 
   //
   //
   //
   //
   //
   
      double oldMean   = value;
      double newMean   = value;
      double squares   = 0; int k;
      for (k=1; k<length && (i-k)>=0; k++)
      {
         newMean  = (workDev[i-k][instanceNo]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k][instanceNo]-oldMean)*(workDev[i-k][instanceNo]-newMean);
         oldMean  = newMean;
      }
      return(MathSqrt(squares/MathMax(k-isSample,1)));
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

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
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
         double haHigh  = fmax(high[i],fmax(haOpen,haClose));
         double haLow   = fmin(low[i] ,fmin(haOpen,haClose));

         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
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
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
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
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
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


