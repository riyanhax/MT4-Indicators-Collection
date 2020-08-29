//+------------------------------------------------------------------+
//|                                     AllVolumeAverage_v2 600+.mq4 |
//|                             Copyright © 2007-14, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
// List of MAs:
// MA_Method= 0: SMA        - Simple Moving Average
// MA_Method= 1: EMA        - Exponential Moving Average
// MA_Method= 2: Wilder     - Wilder Exponential Moving Average
// MA_Method= 3: LWMA       - Linear Weighted Moving Average 
// MA_Method= 4: SineWMA    - Sine Weighted Moving Average
// MA_Method= 5: TriMA      - Triangular Moving Average
// MA_Method= 6: LSMA       - Least Square Moving Average (or EPMA, Linear Regression Line)
// MA_Method= 7: SMMA       - Smoothed Moving Average
// MA_Method= 8: HMA        - Hull Moving Average by Alan Hull
// MA_Method= 9: ZeroLagEMA - Zero-Lag Exponential Moving Average
// MA_Method=10: DEMA       - Double Exponential Moving Average by Patrick Mulloy
// MA_Method=11: T3_basic   - T3 by T.Tillson (original version)
// MA_Method=12: ITrend     - Instantaneous Trendline by J.Ehlers
// MA_Method=13: Median     - Moving Median
// MA_Method=14: GeoMean    - Geometric Mean
// MA_Method=15: REMA       - Regularized EMA by Chris Satchwell
// MA_Method=16: ILRS       - Integral of Linear Regression Slope 
// MA_Method=17: IE/2       - Combination of LSMA and ILRS 
// MA_Method=18: TriMAgen   - Triangular Moving Average generalized by J.Ehlers
// MA_Method=19: VWMA       - Volume Weighted Moving Average 
// MA_Method=20: JSmooth    - Smoothing by Mark Jurik
// MA_Method=21: SMA_eq     - Simplified SMA
// MA_Method=22: ALMA       - Arnaud Legoux Moving Average
// MA_Method=23: TEMA       - Triple Exponential Moving Average by Patrick Mulloy
// MA_Method=24: T3         - T3 by T.Tillson (correct version)
// MA_Method=25: Laguerre   - Laguerre filter by J.Ehlers

#property copyright "Copyright © 2007-14, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

//---- indicator settings
#property  indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  CLR_NONE
#property indicator_color2  YellowGreen
#property indicator_color3  Orange
#property indicator_color4  Green
#property indicator_color5  Red
#property indicator_color6  Violet
#property indicator_color7  LightBlue
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  1
#property indicator_width7  1

#property indicator_minimum 0

extern int     TimeFrame      =  0;    // TimeFrame in min
extern int     FastLength     =  3;    // Fast MA Period
extern int     FastMode       =  0;    // Fast MA Mode
extern int     SlowLength     = 20;    // Slow MA Period
extern int     SlowMode       =  0;    // Slow MA Mode
extern int     BreakoutPct    = 50;    // Breakout Percent 

extern int     AlertMode      =  0;    // 0-off,1-on 
extern int     SoundsNumber   =  5;    // Number of sounds after Signal
extern int     SoundsPause    =  5;    // Pause in sec between sounds 
extern string  UpSound        = "alert.wav";
extern string  DnSound        = "alert2.wav";
extern int     EmailMode      =  0;    // 0-off,1-on 
extern int     EmailsNumber   =  1;    // Number of emails after Signal


//---- indicator buffers
double Volumes[];
double UpBuffer[];
double DnBuffer[];
double UpBreakout[];
double DnBreakout[];
double FastAvg[];
double SlowAvg[];

double   tmp[][2][2], ma[2][3];
int      draw_begin, fastsize, slowsize;
datetime prevtime[2], preTime, ptime;
string   IndicatorName, TF,  fast_name, slow_name, prevmess, prevemail;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(TimeFrame <= Period()) TimeFrame = Period();
   TF = tf(TimeFrame);
   if(TF  == "Unknown timeframe") TimeFrame = Period();
   
   IndicatorDigits(2);   
//----  
   SetIndexBuffer(0,Volumes   ); SetIndexStyle(0,DRAW_NONE     );
   SetIndexBuffer(1,UpBuffer  ); SetIndexStyle(1,DRAW_HISTOGRAM);   
   SetIndexBuffer(2,DnBuffer  ); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,UpBreakout); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,DnBreakout); SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(5,FastAvg   ); SetIndexStyle(5,DRAW_LINE     );
   SetIndexBuffer(6,SlowAvg   ); SetIndexStyle(6,DRAW_LINE     );   
//----  
   fast_name   = averageName(FastMode,fastsize);
   slow_name   = averageName(SlowMode,slowsize);
   
   IndicatorName = WindowExpertName();
   IndicatorShortName(IndicatorName+"["+TF+"]("+FastLength+","+fast_name+","+SlowLength+","+slow_name+","+BreakoutPct+")");
   
   SetIndexLabel(0,"Volumes");      
   SetIndexLabel(1,NULL     );
   SetIndexLabel(2,NULL     );
   SetIndexLabel(3,NULL     );
   SetIndexLabel(4,NULL     );
   SetIndexLabel(5,"FastAvg");
   SetIndexLabel(6,"SlowAvg");
//----         
   draw_begin = FastLength + SlowLength;
   
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
   SetIndexDrawBegin(5,draw_begin);
   SetIndexDrawBegin(6,draw_begin);   

//---- 
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);       
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0); 
   SetIndexEmptyValue(5,0.0); 
   SetIndexEmptyValue(6,0.0); 
//---- 

   ArrayResize(tmp,MathMax(fastsize,slowsize));

   return(0);
}

//-----
int deinit()
{
   Comment("");
   return(0);
}

//+------------------------------------------------------------------+
//| AllVolumeAverage_v2 600+                                         |
//+------------------------------------------------------------------+
int start()
{
   int shift,limit, counted_bars=IndicatorCounted();
      
   if(counted_bars > 0) limit = Bars - counted_bars - 1;
   if(counted_bars < 0) return(0);
   if(counted_bars < 1)
   { 
   limit = Bars-1;   
      for(int i=limit;i>=0;i--) 
      {
      Volumes[i]     = 0;
      FastAvg[i]     = 0;
      SlowAvg[i]     = 0;
      UpBuffer[i]    = 0;
      DnBuffer[i]    = 0;
      UpBreakout[i]  = 0;
      DnBreakout[i]  = 0;
      }
   }
         
//----
   if(TimeFrame != Period())
   {
   limit = MathMax(limit,TimeFrame/Period());   
      
      for(shift = 0;shift < limit;shift++) 
      {	
      int y = iBarShift(NULL,TimeFrame,Time[shift]);
	   
	   Volumes[shift]    = iCustom(NULL,TimeFrame,IndicatorName,0,FastLength,FastMode,SlowLength,SlowMode,BreakoutPct,0,y);
      UpBuffer[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,FastLength,FastMode,SlowLength,SlowMode,BreakoutPct,1,y);
      DnBuffer[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,FastLength,FastMode,SlowLength,SlowMode,BreakoutPct,2,y);
	   UpBreakout[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,FastLength,FastMode,SlowLength,SlowMode,BreakoutPct,3,y);
	   DnBreakout[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,FastLength,FastMode,SlowLength,SlowMode,BreakoutPct,4,y);
	   FastAvg[shift]    = iCustom(NULL,TimeFrame,IndicatorName,0,FastLength,FastMode,SlowLength,SlowMode,BreakoutPct,5,y);
	   SlowAvg[shift]    = iCustom(NULL,TimeFrame,IndicatorName,0,FastLength,FastMode,SlowLength,SlowMode,BreakoutPct,6,y);
	   }
	
	return(0);
	}
   else 
   for(shift=limit;shift>=0;shift--) 
   {
   Volumes[shift] = Volume[shift];
   
   FastAvg[shift] = allAveragesOnArray(0,Volumes,FastLength,FastMode,fastsize,shift); 
   SlowAvg[shift] = allAveragesOnArray(1,Volumes,SlowLength,SlowMode,slowsize,shift); 
         
   UpBuffer[shift]   = 0;   
   DnBuffer[shift]   = 0;        
   DnBreakout[shift] = 0;   
   UpBreakout[shift] = 0;
   
      
      if(i == Bars - 1 || (Close[shift] >= Close[shift+1]))
      {
      UpBuffer[shift] = Volumes[shift];
      if(FastAvg[shift] > SlowAvg[shift]*(1 + BreakoutPct*0.01)) UpBreakout[shift] = Volumes[shift];
      }
      else
      if(Close[shift] < Close[shift+1])
      {
      DnBuffer[shift] = Volumes[shift];
      if(FastAvg[shift] > SlowAvg[shift]*(1 + BreakoutPct*0.01)) DnBreakout[shift] = Volumes[shift];
      } 
   }
   
   if(AlertMode > 0)
   {
   bool uptrend = UpBreakout[1] > 0;                  
   bool dntrend = DnBreakout[1] > 0;
        
      if(uptrend || dntrend)
      {
      
         if(isNewBar(Period()))
         {
         BoxAlert(uptrend," : Long Volume Breakout at " +DoubleToStr(Close[1],Digits));   
         BoxAlert(dntrend," : Short Volume Breakout at "+DoubleToStr(Close[1],Digits)); 
         }
      
      WarningSound(uptrend,SoundsNumber,SoundsPause,UpSound,Time[1]);
      WarningSound(dntrend,SoundsNumber,SoundsPause,DnSound,Time[1]);
         
         if(EmailMode > 0)
         {
         EmailAlert(uptrend,"New BUY Signal" ," : Long Volume Breakout at " +DoubleToStr(Close[1],Digits),EmailsNumber); 
         EmailAlert(dntrend,"New SELL Signal"," : Short Volume Breakout at "+DoubleToStr(Close[1],Digits),EmailsNumber); 
         }
      }
   }
   
   
           
//---- done
   return(0);
}
//+------------------------------------------------------------------+
string averageName(int mode,int& arraysize)
{   
   string ma_name = "";
   
   switch(mode)
   {
   case 1 : ma_name="EMA"       ; break;
   case 2 : ma_name="Wilder"    ; break;
   case 3 : ma_name="LWMA"      ; break;
   case 4 : ma_name="SineWMA"   ; break;
   case 5 : ma_name="TriMA"     ; break;
   case 6 : ma_name="LSMA"      ; break;
   case 7 : ma_name="SMMA"      ; break;
   case 8 : ma_name="HMA"       ; break;
   case 9 : ma_name="ZeroLagEMA"; break;
   case 10: ma_name="DEMA"      ; arraysize = 2; break;
   case 11: ma_name="T3 basic"  ; arraysize = 6; break;
   case 12: ma_name="InstTrend" ; break;
   case 13: ma_name="Median"    ; break;
   case 14: ma_name="GeoMean"   ; break;
   case 15: ma_name="REMA"      ; break;
   case 16: ma_name="ILRS"      ; break;
   case 17: ma_name="IE/2"      ; break;
   case 18: ma_name="TriMA_gen" ; break;
   case 19: ma_name="VWMA"      ; break;
   case 20: ma_name="JSmooth"   ; arraysize = 5; break;
   case 21: ma_name="SMA_eq"    ; break;
   case 22: ma_name="ALMA"      ; break;
   case 23: ma_name="TEMA"      ; arraysize = 4; break;
   case 24: ma_name="T3"        ; arraysize = 6; break;
   case 25: ma_name="Laguerre"  ; arraysize = 4; break;
   default: ma_name="SMA";
   }
   
   return(ma_name);
   
}


double allAveragesOnArray(int index,double& price[],int period,int mode,int arraysize,int bar)
{
   double MA[3];  
        
    if(prevtime[index] != Time[bar])
    {
    ma[index][2]  = ma[index][1]; 
    ma[index][1]  = ma[index][0]; 
    for(int i=0;i<arraysize;i++) tmp[i][index][1] = tmp[i][index][0];
    
    prevtime[index] = Time[bar]; 
    }
   
   for(i=0;i<3;i++) MA[i] = ma[index][i];   
   
   switch(mode)
   {
   case 1 : ma[index][0] = EMAOnArray(price[bar],ma[index][1],period,bar); break;
   case 2 : ma[index][0] = WilderOnArray(price[bar],ma[index][1],period,bar); break;  
   case 3 : ma[index][0] = LWMAOnArray(price,period,bar); break;
   case 4 : ma[index][0] = SineWMAOnArray(price,period,bar); break;
   case 5 : ma[index][0] = TriMAOnArray(price,period,bar); break;
   case 6 : ma[index][0] = LSMAOnArray(price,period,bar); break;
   case 7 : ma[index][0] = SMMAOnArray(price,ma[index][1],period,bar); break;
   case 8 : ma[index][0] = HMAOnArray(price,period,bar); break;
   case 9 : ma[index][0] = ZeroLagEMAOnArray(price,ma[index][1],period,bar); break;
   case 10: ma[index][0] = DEMAOnArray(index,0,price[bar],period,1,bar); break;
   case 11: ma[index][0] = T3_basicOnArray(index,0,price[bar],period,0.7,bar); break;
   case 12: ma[index][0] = ITrendOnArray(price,MA,period,bar); break;
   case 13: ma[index][0] = MedianOnArray(price,period,bar); break;
   case 14: ma[index][0] = GeoMeanOnArray(price,period,bar); break;
   case 15: ma[index][0] = REMAOnArray(price[bar],MA,period,0.5,bar); break;
   case 16: ma[index][0] = ILRSOnArray(price,period,bar); break;
   case 17: ma[index][0] = IE2OnArray(price,period,bar); break;
   case 18: ma[index][0] = TriMA_genOnArray(price,period,bar); break;
   case 19: ma[index][0] = VWMAOnArray(price,period,bar); break;
   case 20: ma[index][0] = JSmoothOnArray(index,0,price[bar],period,1,bar); break;
   case 21: ma[index][0] = SMA_eqOnArray(price,MA,period,bar); break;
   case 22: ma[index][0] = ALMAOnArray(price,period,0.85,8,bar); break;
   case 23: ma[index][0] = TEMAOnArray(index,price[bar],period,1,bar); break;
   case 24: ma[index][0] = T3OnArray(index,0,price[bar],period,0.7,bar); break;
   case 25: ma[index][0] = LaguerreOnArray(index,price[bar],period,4,bar); break;
   default: ma[index][0] = SMAOnArray(price,period,bar); break;
   }
   
   return(ma[index][0]);
}


double SMAOnArray(double& array[],int per,int bar)
{
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i];
   
   return(Sum/per);
}
                           
// MA_Method=1: EMA - Exponential Moving Average
double EMAOnArray(double price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double ema = price;
   else 
   ema = prev + 2.0/(1+per)*(price - prev); 
   
   return(ema);
}

// MA_Method=2: Wilder - Wilder Exponential Moving Average
double WilderOnArray(double price,double prev,int per,int bar)
{
   if(bar >= Bars - 2) double wilder = price; //SMA(array1,per,bar);
   else 
   wilder = prev + (price - prev)/per; 
   
   return(wilder);
}

// MA_Method=3: LWMA - Linear Weighted Moving Average 
double LWMAOnArray(double& array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= (per - i);
      Sum += array[bar+i]*(per - i);
      }
   if(Weight>0) double lwma = Sum/Weight;
   else lwma = 0; 
   return(lwma);
}

 
// MA_Method=4: SineWMA - Sine Weighted Moving Average
double SineWMAOnArray(double& array[],int per,int bar)
{
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
  
      for(int i = 0;i < per;i++)
      { 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+i]*MathSin(pi*(i+1)/(per+1)); 
      }
   if(Weight>0) double swma = Sum/Weight;
   else swma = 0; 
   return(swma);
}

// MA_Method=5: TriMA - Triangular Moving Average
double TriMAOnArray(double& array[],int per,int bar)
{
   double sma;
   int len = MathCeil((per+1)*0.5);
   
   double sum=0;
   for(int i = 0;i < len;i++) 
   {
   sma = SMAOnArray(array,len,bar+i);
   sum += sma;
   } 
   double trima = sum/len;
   
   return(trima);
}

// MA_Method=6: LSMA - Least Square Moving Average (or EPMA, Linear Regression Line)
double LSMAOnArray(double& array[],int per,int bar)
{   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+per-i];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

// MA_Method=7: SMMA - Smoothed Moving Average
double SMMAOnArray(double& array[],double prev,int per,int bar)
{
   if(bar == Bars - per) double smma = SMAOnArray(array,per,bar);
   else 
   if(bar < Bars - per)
   {
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i+1];
   smma = (Sum - prev + array[bar])/per;
   }
   
   return(smma);
}
                                
// MA_Method=8: HMA - Hull Moving Average by Alan Hull
double HMAOnArray(double& array[],int per,int bar)
{
   double _tmp[];
   int len = MathSqrt(per);
   
   ArrayResize(_tmp,len);
   
   if(bar == Bars - per) double hma = array[bar]; 
   else
   if(bar < Bars - per)
   {
   for(int i=0;i<len;i++) _tmp[i] = 2*LWMAOnArray(array,per/2,bar+i) - LWMAOnArray(array,per,bar+i);  
   hma = LWMAOnArray(_tmp,len,0); 
   }  

   return(hma);
}

// MA_Method=9: ZeroLagEMA - Zero-Lag Exponential Moving Average
double ZeroLagEMAOnArray(double& price[],double prev,int per,int bar)
{
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   
   if(bar >= Bars - lag) double zema = price[bar];
   else 
   zema = alfa*(2*price[bar] - price[bar+lag]) + (1-alfa)*prev;
   
   return(zema);
}

// MA_Method=10: DEMA - Double Exponential Moving Average by Patrick Mulloy
double DEMAOnArray(int index,int num,double price,double per,double v,int bar)
{
   double alpha = 2.0/(1+per);
   if(bar == Bars - 2) {double dema = price; tmp[num][index][0] = dema; tmp[num+1][index][0] = dema;}
   else 
   if(bar <  Bars - 2) 
   {
   tmp[num  ][index][0] = tmp[num  ][index][1] + alpha*(price              - tmp[num  ][index][1]); 
   tmp[num+1][index][0] = tmp[num+1][index][1] + alpha*(tmp[num][index][0] - tmp[num+1][index][1]); 
   dema                 = tmp[num  ][index][0]*(1+v) - tmp[num+1][index][0]*v;
   }
   
   return(dema);
}

// MA_Method=11: T3 by T.Tillson
double T3_basicOnArray(int index,int num,double price,int per,double v,int bar)
{
   double dema1, dema2;
   
   if(bar == Bars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<6;k++) tmp[num+k][index][0] = price;
   }
   else 
   if(bar < Bars - 2) 
   {
   dema1 = DEMAOnArray(index,num  ,price,per,v,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,per,v,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,per,v,bar);
   }
   
   return(T3);
}

// MA_Method=12: ITrend - Instantaneous Trendline by J.Ehlers
double ITrendOnArray(double& price[],double& array[],int per,int bar)
{
   double alfa = 2.0/(per+1);
   if(bar < Bars - 7)
   double it = (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+1] - (alfa - 0.75*alfa*alfa)*price[bar+2] +
   2*(1-alfa)*array[1] - (1-alfa)*(1-alfa)*array[2];
   else
   it = (price[bar] + 2*price[bar+1] + price[bar+2])/4;
   
   return(it);
}
// MA_Method=13: Median - Moving Median
double MedianOnArray(double& price[],int per,int bar)
{
   double array[];
   ArrayResize(array,per);
   
   for(int i = 0; i < per;i++) array[i] = price[bar+i];
   ArraySort(array);
   
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
    
   return(median); 
}
// MA_Method=14: GeoMean - Geometric Mean
double GeoMeanOnArray(double& price[],int per,int bar)
{
   if(bar < Bars - per)
   { 
   double gmean = MathPow(price[bar],1.0/per); 
   for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+i],1.0/per); 
   }
   
   return(gmean);
}
// MA_Method=15: REMA - Regularized EMA by Chris Satchwell 
double REMAOnArray(double price,double& array[],int per,double lambda,int bar)
{
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3) double rema = price;
   else 
   rema = (array[1]*(1+2*lambda) + alpha*(price - array[1]) - lambda*array[2])/(1+lambda); 
   
   return(rema);
}
// MA_Method=16: ILRS - Integral of Linear Regression Slope 
double ILRSOnArray(double& price[],int per,int bar)
{
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
     
   double sum1 = 0;
   double sumy = 0;
      for(int i=0;i<per;i++)
      { 
      sum1 += i*price[bar+i];
      sumy += price[bar+i];
      }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMAOnArray(price,per,bar);
   
   return(ilrs);
}
// MA_Method=17: IE/2 - Combination of LSMA and ILRS 
double IE2OnArray(double& price[],int per,int bar)
{
   double ie = 0.5*(ILRSOnArray(price,per,bar) + LSMAOnArray(price,per,bar));
      
   return(ie); 
}

// MA_Method=18: TriMAgen - Triangular Moving Average Generalized by J.Ehlers
double TriMA_genOnArray(double& array[],int per,int bar)
{
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMAOnArray(array,len1,bar+i);
   double trimagen = sum/len2;
   
   return(trimagen);
}

// MA_Method=19: VWMA - Volume Weighted Moving Average 
double VWMAOnArray(double& array[],int per,int bar)
{
   double Sum = 0;
   double Weight = 0;
   
      for(int i = 0;i < per;i++)
      { 
      Weight+= Volume[bar+i];
      Sum += array[bar+i]*Volume[bar+i];
      }
   if(Weight>0) double vwma = Sum/Weight;
   else vwma = 0; 
   return(vwma);
} 
// MA_Method=20: JSmooth - Smoothing by Mark Jurik
double JSmoothOnArray(int index,int num,double price,int per,double pow,int bar)
{
   double beta = 0.45*(per-1)/(0.45*(per-1)+2);
	double alpha = MathPow(beta,pow);
	
	if(bar == Bars - 2) {tmp[num+4][index][0] = price; tmp[num+0][index][0] = price; tmp[num+2][index][0] = price;}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[num+0][index][0] = (1-alpha)*price + alpha*tmp[num+0][index][1];
	tmp[num+1][index][0] = (price - tmp[num+0][index][0])*(1-beta) + beta*tmp[num+1][index][1];
	tmp[num+2][index][0] = tmp[num+0][index][0] + tmp[num+1][index][0];
	tmp[num+3][index][0] = (tmp[num+2][index][0] - tmp[num+4][index][1])*MathPow((1-alpha),2) + MathPow(alpha,2)*tmp[num+3][index][1];
	tmp[num+4][index][0] = tmp[num+4][index][1] + tmp[num+3][index][0]; 
   }
   return(tmp[num+4][index][0]);
}

// MA_Method=21: SMA_eq     - Simplified SMA
double SMA_eqOnArray(double& price[],double& array[],int per,int bar)
{
   if(bar == Bars - per) double sma = SMAOnArray(price,per,bar);
   else 
   if(bar <  Bars - per) sma = (price[bar] - price[bar+per])/per + array[1]; 
   
   return(sma);
}                 
// MA_Method=22: ALMA by Arnaud Legoux / Dimitris Kouzis-Loukas / Anthony Cascino
double ALMAOnArray(double& price[],int per,double offset,double sigma,int bar)
{
   double m = MathFloor(offset * (per - 1));
	double s = per/sigma;
		
	double w, sum =0, wsum = 0;		
	for (int i=0;i < per;i++) 
	{
	w = MathExp(-((i - m)*(i - m))/(2*s*s));
   wsum += w;
   sum += price[bar+(per-1-i)]*w; 
   }
   
   if(wsum != 0) double alma = sum/wsum; 
   
   return(alma);
}
  
// MA_Method=23: TEMA - Triple Exponential Moving Average by Patrick Mulloy
double TEMAOnArray(int index,double price,int per,double v,int bar)
{
   double alpha = 2.0/(per+1);
	
	if(bar == Bars - 2) {tmp[0][index][0] = price; tmp[1][index][0] = price; tmp[2][index][0] = price;}
	else 
   if(bar <  Bars - 2) 
   {
	tmp[0][index][0] = tmp[0][index][1] + alpha *(price     - tmp[0][index][1]);
	tmp[1][index][0] = tmp[1][index][1] + alpha *(tmp[0][index][0] - tmp[1][index][1]);
	tmp[2][index][0] = tmp[2][index][1] + alpha *(tmp[1][index][0] - tmp[2][index][1]);
	tmp[3][index][0] = tmp[0][index][0] + v*(tmp[0][index][0] + v*(tmp[0][index][0]-tmp[1][index][0]) - tmp[1][index][0] - v*(tmp[1][index][0] - tmp[2][index][0])); 
	}
   
   return(tmp[3][index][0]);
}

// MA_Method=24: T3 by T.Tillson (correct version) 
double T3OnArray(int index,int num,double price,int per,double v,int bar)
{
   double len = MathMax((per + 5.0)/3.0-1,1), dema1, dema2;
   
   if(bar == Bars - 2) 
   {
   double T3 = price; 
   for(int k=0;k<6;k++) tmp[num+k][index][0] = T3;
   }
   else 
   if(bar < Bars - 2) 
   {
   dema1 = DEMAOnArray(index,num  ,price,len,v,bar); 
   dema2 = DEMAOnArray(index,num+2,dema1,len,v,bar); 
   T3    = DEMAOnArray(index,num+4,dema2,len,v,bar);
   }
      
   return(T3);
}

// MA_Method=25: Laguerre filter by J.Ehlers
double LaguerreOnArray(int index,double price,int per,int order,int bar)
{
   double gamma = 1-10.0/(per+9);
   double aPrice[];
   
   ArrayResize(aPrice,order);
   
   for(int i=0;i<order;i++)
   {
      if(bar >= Bars - order) tmp[i][index][0] = price;
      else
      {
         if(i == 0) tmp[i][index][0] = (1 - gamma)*price + gamma*tmp[i][index][1];
         else
         tmp[i][index][0] = -gamma * tmp[i-1][index][0] + tmp[i-1][index][1] + gamma * tmp[i][index][1];
      
      aPrice[i] = tmp[i][index][0];
      }
   }
   double laguerre = TriMA_genOnArray(aPrice,order,0);  

   return(laguerre);
}

string tf(int timeframe)
{
   switch(timeframe)
   {
   case PERIOD_M1:   return("M1");
   case PERIOD_M5:   return("M5");
   case PERIOD_M15:  return("M15");
   case PERIOD_M30:  return("M30");
   case PERIOD_H1:   return("H1");
   case PERIOD_H4:   return("H4");
   case PERIOD_D1:   return("D1");
   case PERIOD_W1:   return("W1");
   case PERIOD_MN1:  return("MN1");
   default:          return("Unknown timeframe");
   }
}         
//------------------------------------------- 

bool isNewBar(int tf)
{
   static datetime pTime;
   bool res=false;
   
   if(tf >= 0)
   {
      if (iTime(NULL,tf,0)!= pTime)
      {
      res=true;
      pTime=iTime(NULL,tf,0);
      }   
   }
   else res = true;
   
   return(res);
}

bool BoxAlert(bool cond,string text)   
{      
   string mess = " "+Symbol()+" "+TF + ":" + " " + IndicatorName + text;
   
   if (cond && mess != prevmess)
	{
	Alert (mess);
	prevmess = mess; 
	return(true);
	} 
  
   return(false);  
}

bool Pause(int sec)
{
   if(TimeCurrent() >= preTime + sec) {preTime = TimeCurrent(); return(true);}
   
   return(false);
}

void WarningSound(bool cond,int num,int sec,string sound,datetime ctime)
{
   static int i;
   
   if(cond)
   {
   if(ctime != ptime) i = 0; 
   if(i < num && Pause(sec)) {PlaySound(sound); ptime = ctime; i++;}       	
   }
}

bool EmailAlert(bool cond,string text1,string text2,int num)   
{      
   string subj = text1 +" from " + IndicatorName + "!!!";    
   string mess = " "+Symbol()+" "+TF + ":" + " " + IndicatorName + text2;
   
   if (cond && mess != prevemail)
	{
	if(subj != "" && mess != "") for(int i=0;i<num;i++) SendMail(subj, mess);  
	prevemail = mess; 
	return(true);
	} 
  
   return(false);  
}	         


