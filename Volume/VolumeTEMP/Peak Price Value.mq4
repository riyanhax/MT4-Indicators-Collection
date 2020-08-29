//+------------------------------------------------------------------+
//|                                                     Помошник.mq4 |
//|                                                     Yuriy Tokman |
//| ISQ#481971287                              yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern string __настройки_нидикатора__ = "Здесь изменяем";
extern bool Добавить_обём = false ;
extern bool Перевернуть_вычисления = false ;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   
   IndicatorShortName("Помошник");
   
   SetIndexLabel(0," ISQ#481971287  ");
   SetIndexLabel(1," yuriytokman@gmail.com  ");
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
   
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   //---- main loop
   for(int i=0; i<limit; i++)
   {
     double v,z,h,l,x,y;
     double MA1 =iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,i);
     double MA2 =iMA(NULL,0,12,0,MODE_EMA,PRICE_CLOSE,i);   
     if (Добавить_обём == false)v=1;else v=Volume[i];
     z =(MA1-MA2)*v;
     l =Low[i]-MA1;
     h =High[i]-MA1;
     if (Перевернуть_вычисления == false){x=l;y=h;}else{x=h;y=l;}
     if(z>0&&l>0)ExtMapBuffer1[i]=x/Point*v;else ExtMapBuffer1[i]=0;
     if(z<0&&h<0)ExtMapBuffer2[i]=y/Point*v;else ExtMapBuffer2[i]=0;
//----
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+