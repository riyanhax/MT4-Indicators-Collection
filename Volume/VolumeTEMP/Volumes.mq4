//+------------------------------------------------------------------+
//|                                                      Volumes.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 3
#property indicator_color1  Black
#property indicator_color2  Green
#property indicator_color3  Red
#property indicator_width2  2
#property indicator_width3  2
//---- indicator buffers
double ExtVolumesBuffer[];
double ExtVolumesUpBuffer[];
double ExtVolumesDownBuffer[];
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtVolumesBuffer);       
   SetIndexBuffer(1,ExtVolumesUpBuffer);
   SetIndexBuffer(2,ExtVolumesDownBuffer);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
//---- sets default precision format for indicators visualization
   IndicatorDigits(0);   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Volumes");
   SetIndexLabel(0,"Volumes");      
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
//---- sets drawing line empty value
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);       
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Volumes                                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nLimit,nCountedBars;
//---- bars count that does not changed after last indicator launch.
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted
   if(nCountedBars>0) nCountedBars--;
   nLimit=Bars-nCountedBars;
//----
   for(i=0; i<nLimit; i++)
     {
      double dVolume=Volume[i];
      if(i==Bars-1 || dVolume>Volume[i+1])
        {
         ExtVolumesBuffer[i]=dVolume;
         ExtVolumesUpBuffer[i]=dVolume;
         ExtVolumesDownBuffer[i]=0.0;        
        }
      else
        {
         ExtVolumesBuffer[i]=dVolume;
         ExtVolumesUpBuffer[i]=0.0;
         ExtVolumesDownBuffer[i]=dVolume;        
        } 
     }        
//---- done
   return(0);
  }
//+------------------------------------------------------------------+