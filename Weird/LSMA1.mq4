//+------------------------------------------------------------------+
//|                                                        |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, FX Sniper "
#property  link      "http://www.metaquotes.net/"

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property indicator_color1 Red      
#property indicator_color2 Green


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

extern int Rperiod = 25;
extern int Draw4HowLongg = 300;
int Draw4HowLong;
int shift;
int i;
int loopbegin;
double sum[];
int length;
double lengthvar;
double tmp ;
double wt[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   
//---- drawing settings
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,sum);
   SetIndexBuffer(3,wt);
   SetIndexStyle(0,DRAW_LINE,1,3);
   SetIndexStyle(1,DRAW_LINE,1,3);
  
//---- initialization done
   return(0);
  }

int start()

  {   Draw4HowLong = Bars-Rperiod - 5;
      length = Rperiod;
      loopbegin = Draw4HowLong - length - 1;
 
      for(shift = loopbegin; shift >= 0; shift--)
      { 
         sum[1] = 0;
         for(i = length; i >= 1  ; i--)
         {
         lengthvar = length + 1;
         lengthvar /= 3;
         tmp = 0;
         tmp = ( i - lengthvar)*Close[length-i+shift];
         sum[1]+=tmp;
         }
         wt[shift] = sum[1]*6/(length*(length+1));
         
//========== COLOR CODING ===========================================               
        
       ExtMapBuffer1[shift] = wt[shift]; //red
       ExtMapBuffer2[shift] = wt[shift]; //green
       
        if (wt[shift] > Close[shift])
            ExtMapBuffer2[shift] = EMPTY_VALUE;
        else
        if (wt[shift] < Close[shift]) 
            ExtMapBuffer1[shift] = EMPTY_VALUE;         
         }
      return(0);
  }
//+------------------------------------------------------------------+



