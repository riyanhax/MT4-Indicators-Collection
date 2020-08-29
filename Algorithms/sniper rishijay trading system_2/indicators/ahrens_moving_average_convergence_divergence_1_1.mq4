//+------------------------------------------------------------------+
//|                     AhrensMovingAverageConvergenceDivergence.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_color3 clrBlue
//--- input parameters
extern int       FastPeriod=12;
extern int       SlowPeriod=26;
extern int       SignalPeriod=9;
double fastAMA[];
double slowAMA[];
double HISTOGRAM[];
double MACD[];
double SIGNAL[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

 IndicatorShortName("AhrensMovingAverage");
  IndicatorDigits(Digits);  
   IndicatorBuffers(5);
   SetIndexBuffer(0,MACD);
   SetIndexBuffer(1,SIGNAL);
   SetIndexBuffer(2,HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
	
   SetIndexBuffer(3,slowAMA);
   SetIndexBuffer(4,fastAMA);
  
  
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit=MathMin(Bars-counted_bars,Bars-2);
   

          for( i=limit; i>=0; i--)
		    {
		   
		      double MedianPrice = (High[i] + Low[i]) / 2;
			   double MedianMA1   = (fastAMA[i+1]+fastAMA[i+FastPeriod])/2; 			
			      fastAMA[i]      =  fastAMA[i+1]+((MedianPrice-MedianMA1)/FastPeriod);
			   double MedianMA2   = (slowAMA[i+1]+slowAMA[i+SlowPeriod])/2; 			
			      slowAMA[i]      =  slowAMA[i+1]+((MedianPrice-MedianMA2)/SlowPeriod);
			      MACD[i]         =  fastAMA[i]-slowAMA[i];
		      double MedianMA3   = (SIGNAL[i+1]+SIGNAL[i+SignalPeriod])/2; 		
		         SIGNAL[i]       =  SIGNAL[i+1]+((MACD[i]-MedianMA3)/SignalPeriod);
		         HISTOGRAM[i]    =  MACD[i]-SIGNAL[i];		   
		      }
   return(0);
}