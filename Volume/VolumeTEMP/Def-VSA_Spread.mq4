//+------------------------------------------------------------------+
//|                                              VSA_Spread Zoom.mq4 |
//|                                              V.1.0               |
//+------------------------------------------------------------------+
//| ANYONE CAN IMPROVE THIS CODE, IT' S UNDER GPL                    |
//| BUT PLEASE INSERT YOUR REFERENCE AND CHANGELOG                   |
//|                                                                  |
//| IN CASE YOU IMPROVE THE CODE OR FOUND BUGS EMAIL ME              |
//|                                                                  |
//| Defcon                                  defcon1nowhere@gmail.com |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 5

#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Blue
#property indicator_color6 Magenta

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 1
#property indicator_width6 1

//----
extern int   MaxBars=500;
extern int   SMA1period = 3;
extern int   SMA2period = 20;

extern color ColorSpread1 = Black;
extern color ColorSpread2 = Black;
extern color ColorCloseDW = Red;
extern color ColorCloseUP = Green;
extern color ColorSMA1 = Blue;
extern color ColorSMA2 = Blue;

//---- buffers
double BufferSpread1[];
double BufferSpread2[];
double BufferCloseDW[];
double BufferCloseUP[];
double BufferSMA1[];
double BufferSMA2[];

//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM, 0, 1, ColorSpread1);
   SetIndexBuffer(0, BufferSpread1);
   
   SetIndexStyle(1,DRAW_HISTOGRAM, 0, 1, ColorSpread2);
   SetIndexBuffer(1, BufferSpread2);
   
   SetIndexStyle(2,DRAW_HISTOGRAM, 0, 2, ColorCloseDW);
   SetIndexBuffer(2, BufferCloseDW);
   
   SetIndexStyle(3,DRAW_HISTOGRAM, 0, 2, ColorCloseUP);
   SetIndexBuffer(3, BufferCloseUP);  
   
   SetIndexStyle(4,DRAW_LINE, 0, 1, ColorSMA1);
   SetIndexBuffer(4, BufferSMA1);   
   
   SetIndexStyle(5,DRAW_LINE, 0, 1, ColorSMA2);
   SetIndexBuffer(5, BufferSMA2);   
//----
   SetIndexDrawBegin(0,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(3,0);     
   SetIndexDrawBegin(4,0);  
   SetIndexDrawBegin(5,0);
//---- indicator buffers mapping
   SetIndexBuffer(0,BufferSpread1);
   SetIndexBuffer(1,BufferSpread2);
   SetIndexBuffer(2,BufferCloseDW);
   SetIndexBuffer(3,BufferCloseUP);
   SetIndexBuffer(4,BufferSMA1);
   SetIndexBuffer(5,BufferSMA2);
//---- initialization done
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
   double haClose,haSpread,SMA1,SMA2;
   int j;
   
   if(Bars<=10) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   for(int pos=MaxBars;pos>=0;pos--)
      {
         
      if(Close[pos]<(High[pos]+Low[pos]/2)) 
         {
        
         haClose=Close[pos]-((High[pos]+Low[pos])/2);
         if(haClose<=0)
            {
            BufferCloseDW[pos]=haClose;
            BufferCloseUP[pos]=0;
            }
            
         if(haClose>=0)
            {
            BufferCloseDW[pos]=0;
            BufferCloseUP[pos]=haClose;
         }
            
      }
         
      if(Close[pos]>(High[pos]+Low[pos]/2))
         {
            haClose=Close[pos]-((High[pos]+Low[pos])/2);
            BufferCloseDW[pos]=0;
            BufferCloseUP[pos]=haClose;
         }       
          
      haSpread=(High[pos]-Low[pos]);
      BufferSpread1[pos]=haSpread/2;
      BufferSpread2[pos]=-haSpread/2;

      SMA1=0;
      
      for(j=pos; j<pos+SMA1period; j++)
         {
            SMA1=( ( (High[j]-Low[j]) /2 )+SMA1 );
         }
                  
      BufferSMA1[pos]=(SMA1/SMA1period);
      
      SMA2=0;
      
      for(j=pos; j<pos+SMA2period; j++)
         {
            SMA2=( ( (High[j]-Low[j]) /2 )+SMA2 );
         }
                  
      BufferSMA2[pos]=(SMA2/SMA2period);
                           
    }
    
    
//----
   return(0);
  }
//+------------------------------------------------------------------+