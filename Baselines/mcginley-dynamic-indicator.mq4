//+------------------------------------------------------------------+
//|                                   McGinley Dynamic Indicator.mq4 |
//+------------------------------------------------------------------+
// Coded by smjones
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_width1 2


extern string     Note = "NumberOfBars = 0 means all bars";
extern int        NumberOfBars = 1000;
extern int        Periods = 12;
extern int        Smoothing = 125;


int               mult = 1;

double            buffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
      if ( Digits == 3 || Digits == 5 )
         mult = 10;
//---- indicators
      SetIndexBuffer(0,buffer1);
      SetIndexStyle(0,DRAW_LINE);
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
   
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   if ( NumberOfBars == 0 ) 
      NumberOfBars = Bars-counted_bars;
   limit=NumberOfBars;

   for(int i=0; i<limit; i++)   
      {
         
         //  Ref(Mov(C,12,E),-1)+((C-(Ref(Mov(C,12,E),-1))) / (C/(Ref(Mov(C,12,E),-1))*125))
            
         buffer1[i] = 
         //  Ref(Mov(C,12,E),-1)
         iMA(NULL,0,Periods,0,MODE_EMA,PRICE_CLOSE,i+1) 
         // +
         +
         // ( (C - (Ref(Mov(C,12,E),-1)) )
         ( (Close[i] - (iMA(NULL,0,Periods,0,MODE_EMA,PRICE_CLOSE,i+1)))
         // /
         /
         // (C/(Ref(Mov(C,12,E),-1))*125))
         (Close[i] / (iMA(NULL,0,Periods,0,MODE_EMA,PRICE_CLOSE,i+1)) * Smoothing) );
          
      
      }
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+