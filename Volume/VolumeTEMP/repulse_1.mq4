//+------------------------------------------------------------------+
//|                                                      Repulse.mq4 |
//|                                                        Anaphrais |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Anaphrais"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
 
//---- buffers
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetLevelValue(0,0);
   SetLevelStyle(STYLE_DOT,0,Black); 
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
  
      
   double forcehaussiere=0 ,forcebaissiere=0;
   
   for(int i=300;i>=0;i--)
   { 
   forcehaussiere=iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i)*(((3*Close[i])-(2*Low[i])-Open[i])/Close[i]*100);
   
   forcebaissiere=iMA(NULL,0,5,0,MODE_SMA,PRICE_CLOSE,i)*((Open[i]+(2*High[i])-(3*Close[i]))/Close[i]*100);
   
   ExtMapBuffer1[i]=(forcehaussiere-forcebaissiere);
   }
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+