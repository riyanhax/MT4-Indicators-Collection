//+------------------------------------------------------------------+
//|                                             VolumeAverage_v1.mq4 |
//|                           Copyright © 2007, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

//---- indicator settings
#property  indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 6
#property indicator_color1  Black
#property indicator_color2  LightBlue
#property indicator_color3  YellowGreen
#property indicator_color4  Orange
#property indicator_color5  Green
#property indicator_color6  Red
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2

extern int  MA_Length     = 50; // Average Period
extern int  BreakoutPcnt  = 50; // Percent of Breakout
extern int  MA_Mode       =  1; // Mode of Moving Average
//---- indicator buffers
double Volumes[];
double AvgVolumes[];
double UpBuffer[];
double DnBuffer[];
double UpBrk[];
double DnBrk[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,Volumes);
   SetIndexBuffer(1,AvgVolumes);       
   SetIndexBuffer(2,UpBuffer);
   SetIndexBuffer(3,DnBuffer);
   SetIndexBuffer(4,UpBrk);
   SetIndexBuffer(5,DnBrk);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_HISTOGRAM);
//---- sets default precision format for indicators visualization
   IndicatorDigits(0);   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Volume Average("+MA_Length+","+BreakoutPcnt+","+MA_Mode+")");
   SetIndexLabel(0,"Volumes");      
   SetIndexLabel(1,"AvgVolumes");
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);
//---- sets drawing line empty value
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);       
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0); 
   SetIndexEmptyValue(5,0.0); 
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
   for(i=0; i<nLimit; i++) Volumes[i] = Volume[i];
   
   for(i=0; i<nLimit; i++)
   {
   AvgVolumes[i] = iMAOnArray(Volumes,0,MA_Length,0,MA_Mode,i);
      
      if(i==Bars-1 || (Close[i] >= Close[i+1]))
      {
      UpBuffer[i] = Volumes[i];
         if(Volumes[i] > AvgVolumes[i]*(1 + BreakoutPcnt*0.01)) 
         {UpBrk[i] = Volumes[i]; UpBuffer[i] = 0;} else UpBrk[i] = 0;
      DnBuffer[i] = 0.0;        
      DnBrk[i] = 0.0;
      }
      else
      if(Close[i] < Close[i+1])
      {
      DnBuffer[i] = Volumes[i];
         if(Volumes[i] > AvgVolumes[i]*(1 + BreakoutPcnt*0.01)) 
         {DnBrk[i] = Volumes[i]; DnBuffer[i] = 0;} else DnBrk[i] = 0;
      UpBuffer[i] = 0.0;        
      UpBrk[i] = 0.0;
      } 
   }        
//---- done
   return(0);
}
//+------------------------------------------------------------------+

