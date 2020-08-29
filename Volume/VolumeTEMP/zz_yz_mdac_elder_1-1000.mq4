//
// MDAC по элдеру
//
#property  copyright "Copyright © 2007, YURAZ"
#property  link      "yzh@mail.ru"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 6

#property  indicator_color1  Green
#property  indicator_color2  MediumBlue
#property  indicator_color3  Red 
#property  indicator_color4  SeaGreen
#property  indicator_color5  Yellow

#property  indicator_color6  Chocolate // Ivory

//---- indicator parameters

extern int FastMA_Period=12;
extern int SlowMA_Period=26;
extern int SignalMA_Period=9;

int FastMA_Shift=0;
int FastMA_Method=1;
int FastMA_Price=0;
int FastMA_Timeframe=0;
int SlowMA_Shift=0;
int SlowMA_Method=1;
int SlowMA_Price=0;
int SlowMA_Timeframe=0;
int SignalMA_Shift=0;
int SignalMA_Method=0;


//---- indicator buffers

double     ind_buffer1[];
double     ind_buffer2[];

double     ExtBuffer1[];
double     ExtBuffer2[];
double     ExtBuffer3[];
double     ExtBuffer4[];

int Shift;
int MA_Period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if (FastMA_Price>6 || FastMA_Price<0) FastMA_Price=0;
   if (FastMA_Method>3 || FastMA_Method<0) FastMA_Method=1;
   if (FastMA_Period<=0) FastMA_Period=12;
   if (SlowMA_Price>6 || SlowMA_Price<0) SlowMA_Price=0;
   if (SlowMA_Method>3 || SlowMA_Method<0) SlowMA_Method=1;
   if (SlowMA_Period<=0) SlowMA_Period=26;
   if (SignalMA_Method>3 || SignalMA_Method<0) SignalMA_Method=0;
   if (SignalMA_Period<=0) SignalMA_Period=9;
   if (FastMA_Shift<0) FastMA_Shift=0;
   if (SlowMA_Shift<0) SlowMA_Shift=0;  
   if (FastMA_Shift>=SlowMA_Shift)
     {
      Shift=FastMA_Shift;
     }
   else 
     {
      Shift=SlowMA_Shift;
     }
   if (FastMA_Period>=SlowMA_Period)
     {
      FastMA_Period=12;
      SlowMA_Period=26;
     }  
   if (SignalMA_Period>=SlowMA_Period)
     {
      MA_Period=SignalMA_Period;
     }
   else 
     {
      MA_Period=SlowMA_Period;
     }  
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexDrawBegin(0,MA_Period+Shift+4*SignalMA_Period);
   SetIndexBuffer(0,ExtBuffer1);
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexDrawBegin(1,MA_Period+Shift+4*SignalMA_Period);
   SetIndexBuffer(1,ExtBuffer2);
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexDrawBegin(2,MA_Period+Shift+4*SignalMA_Period);
   SetIndexBuffer(2,ExtBuffer3);
   
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexDrawBegin(3,MA_Period+Shift+4*SignalMA_Period);
   SetIndexBuffer(3,ExtBuffer4);
   
   SetIndexStyle(4,DRAW_NONE);
   SetIndexDrawBegin(4,MA_Period+Shift+4*SignalMA_Period);
   SetIndexBuffer(4,ind_buffer1);
   
   SetIndexStyle(5,DRAW_LINE);
   SetIndexDrawBegin(5,MA_Period+Shift+4*SignalMA_Period);
   SetIndexBuffer(5,ind_buffer2);
   SetIndexShift(5,SignalMA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("yzMACDCOLOR ("+FastMA_Period+","+SlowMA_Period+","+SignalMA_Period+")");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,"yzMACDCOLOR");
   SetIndexLabel(5,"Signal");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   double prev,current, Sprev,Scurrent;
   int counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);

   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;




   for(int i=0; i<limit; i++)
   {
         ind_buffer1[i]=iMA(Symbol(),FastMA_Timeframe,FastMA_Period,FastMA_Shift,FastMA_Method,FastMA_Price,i) - 
         iMA(Symbol(),SlowMA_Timeframe,SlowMA_Period,SlowMA_Shift,SlowMA_Method,SlowMA_Price,i);

   }

   for( int j = 0; j <= limit-1;   j++)
   {
       ind_buffer2[j]=iMAOnArray(ind_buffer1,Bars,SignalMA_Period,0,SignalMA_Method,j);
   }

   for(i=0, j = 0; i <= limit-1; i++ , j++)
   {


      current=ind_buffer1[i];
      prev=ind_buffer1[i+1];

      Scurrent = ind_buffer2[i];
      Sprev = ind_buffer2[i+1];
      ExtBuffer1[i]=0.0; 
      ExtBuffer2[i]=0.0;
      ExtBuffer3[i]=0.0;
      ExtBuffer4[i]=0.0;
/*
1)  СЛ - значение больше предыдущего;
     ГГ  - значение больше предыдущего - полоска зеленая.

2)  СЛ - значение больше предыдущего; 
     ГГ  - значение ровное с предыдмущим - полоска зеленая.

3)  СЛ - значение ровное с предыдмущим; 
     ГГ  - значение больше предыдущего - полоска зеленая,

4)  СЛ - значение больше предыдущего; 
     ГГ  - значение меньше предыдмущего - полоска синяя.

5)  СЛ - значение ровное с предыдмущим;
     ГГ - значение ровное с предыдмущим - полоска синяя. 

6)  СЛ  - значение меньше предыдмущего; 
     ГГ  - значение больше предыдущего - полоска синяя.

7)  СЛ  - значение меньше предыдмущего; 
     ГГ  - значение меньше предыдмущего - полоска красная. 

8) СЛ - значение ровное с предыдмущим;
    ГГ  - значение меньше предыдмущего  - полоска красная. 

9)  СЛ  - значение меньше предыдмущего; 
      ГГ - значение ровное с предыдмущим - полоска красная.
*/
      if(( current > prev) && (Scurrent > Sprev) )
      {
         ExtBuffer1[i]=current; // Green
         ExtBuffer2[i]=0.0;
         ExtBuffer3[i]=0.0;
         ExtBuffer4[i]=0.0;
      }
      else
      if( ( current< prev) && (Scurrent < Sprev)   ) // 7-е условие
      {
         ExtBuffer1[i]=0.0; 
         ExtBuffer2[i]=0.0; 
         ExtBuffer3[i]=current; // // Red
         ExtBuffer4[i]=0.0;
      }
      else
      if( (current > prev)&& (Scurrent < Sprev)  ) 
      {
         ExtBuffer1[i]=0.0; 
         ExtBuffer2[i]=current; // MediumBlue
         ExtBuffer3[i]=0.0;  
         ExtBuffer4[i]=0.0;
      }
      else
      if( (current < prev)&& (Scurrent > Sprev)  ) 
      {
         ExtBuffer1[i]=0.0; 
         ExtBuffer2[i]=current; // MediumBlue
         ExtBuffer3[i]=0.0;  
         ExtBuffer4[i]=0.0;
      }
   }
   return(0);
}
