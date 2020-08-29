//+------------------------------------------------------------------+
//|                                         Chaikin's Volatility.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DeepSkyBlue
#property indicator_level1 0
//---- input parameters
extern int       iPeriod=10;
extern int       maPeriod=10;
extern int       barsToCount = 2000;
//---- buffers
double chakin[];
double hl[];
double emahl[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,chakin);
   
   SetIndexBuffer(1,hl);
   SetIndexBuffer(2,emahl);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit = barsToCount;
   
//----
   for(int c = 0 ;c <= limit ;c++) hl[c]=High[c]-Low[c];
   for(int e = 0 ;e <= limit ;e++) emahl[e]= iMAOnArray(hl,0,maPeriod,0,MODE_EMA,e);
   
   for(int i = 0 ;i <= limit-20 ;i++)
   {  
      chakin[i] = ( (emahl[i]-emahl[i+iPeriod])/emahl[i+iPeriod] ) *100;  
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+