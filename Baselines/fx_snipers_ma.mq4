//+------------------------------------------------------------------+
//|                                                        |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, FX Sniper "
#property  link      "http://www.metaquotes.net/"

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 2
#property indicator_color1 Lime      
#property indicator_color2 Red


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[],ma[];

extern int MAType = 1;
extern int MAPeriod = 34;
extern int MAShift = 0;
extern int PriceType=0; 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(5);
   
//---- drawing settings
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ma);   
   SetIndexStyle(0,DRAW_LINE,0,2);
   SetIndexStyle(1,DRAW_LINE,0,2);


//---- initialization done
   return(0);
  }

int start()

  {  
      for(int i = Bars-10; i >= 0; i--)
           {
               ma[i]=iMA(NULL,0,MAPeriod,MAShift,MAType,PriceType,i);
           }     
     
     for(int shift = Bars-10; shift >= 0; shift--)
     {  
       ExtMapBuffer1[shift] = ma[shift]; 
       ExtMapBuffer2[shift] = ma[shift]; 
       //Print (ma[shift]);
        if (ma[shift] > ma[shift+1])
        {
        ExtMapBuffer1[shift] = EMPTY_VALUE;
        ExtMapBuffer2[shift+1] = ma[shift+1];
        
        }
       else if (ma[shift] < ma[shift+1]) 
        {
        ExtMapBuffer2[shift] = EMPTY_VALUE; 
        ExtMapBuffer1[shift+1] = ma[shift+1];
        }

      }
    
      return(0);
  }
//+------------------------------------------------------------------+



