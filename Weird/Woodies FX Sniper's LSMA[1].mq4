//+------------------------------------------------------------------+
//|                                                        |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, FX Sniper "
#property  link      "http://www.metaquotes.net/"

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 2
#property indicator_color1 Red      
#property indicator_color2 Lime


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
extern int Rperiod = 14;
extern int Draw4HowLongg = 1500;
extern int Type = 3; 
int Draw4HowLong,shift,i,loopbegin,width,length,c;
double sum[];
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
   
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexStyle(1,DRAW_LINE,0,2);


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
         if(Type==1)
         tmp = ( i - lengthvar)*High[length-i+shift];
         if (Type==2)
         tmp = ( i - lengthvar)*Low[length-i+shift];
         if(Type==3)
         tmp = ( i - lengthvar)*Close[length-i+shift];
         
         sum[1]+=tmp;
         }
         wt[shift] = sum[1]*6/(length*(length+1));
         
//========== COLOR CODING ===========================================               
        
       ExtMapBuffer1[shift] = wt[shift]; 
       ExtMapBuffer2[shift] = wt[shift]; 
       
        if (wt[shift] > wt[shift+1])
        {
        ExtMapBuffer1[shift] = EMPTY_VALUE;
        ExtMapBuffer2[shift+1] = wt[shift+1];
        
        }
       else if (wt[shift] < wt[shift+1]) 
        {
        ExtMapBuffer2[shift] = EMPTY_VALUE; 
        ExtMapBuffer1[shift+1] = wt[shift+1];
        }

      }
    
      return(0);
  }
//+------------------------------------------------------------------+



