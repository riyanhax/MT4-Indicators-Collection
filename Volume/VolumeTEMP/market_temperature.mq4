//+------------------------------------------------------------------+
//|                                           Market Temperature.mq4 |
//|                              Copyright c 2004, H. Ignacio Butler |
//|                                        http://                   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2006, H. Ignacio Butler"
#property link      "http://"

#define MAX_PERIOD 300

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int MAPeriod = 22;
extern int MAMODE = MODE_SMA;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2, ExtMapBuffer3);

//----
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
  
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double ma[MAX_PERIOD];
   int x, i;
   if(Bars<=10) return(0);
   ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   int pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
      double val1 = MathAbs(High[pos]-High[pos+1]); 
      double val2 = MathAbs(Low[pos+1]-Low[pos]);
   
      if(val1>=val2)
      {
         ExtMapBuffer1[pos] = val1;
         ExtMapBuffer2[pos] = 0;
      }
      else
      {
         ExtMapBuffer2[pos] = val2;
         ExtMapBuffer1[pos] = 0;
      }
      
      
      for(i = pos, x = 0; i < (pos + MAPeriod); i++, x++)
      {
         
         if(ExtMapBuffer1[i] > 0.0)
            ma[x] = ExtMapBuffer1[i];
         else if (ExtMapBuffer2[i] > 0.0)
            ma[x] = ExtMapBuffer2[i];
         else
            ma[x] = 0.0;
      }
            
      ExtMapBuffer3[pos] = iMAOnArray(ma, MAPeriod, MAPeriod, 0, MAMODE, 0);
      
      pos--;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+