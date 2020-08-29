//+------------------------------------------------------------------+
//|                                         i-Custom bams-bung 2.mq4 |
//|                                         Fed77     Copyright 2014 |
//|                                                http://cashbux.ru |
//+------------------------------------------------------------------+
#property copyright "Fed77     Copyright 2014"
#property link      "http://cashbux.ru"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 CornflowerBlue
#property indicator_color2 LightSalmon
#property indicator_color3 CornflowerBlue
#property indicator_color4 LightSalmon
#property indicator_color5 CornflowerBlue
#property indicator_color6 LightSalmon


#property indicator_width5 2
#property indicator_width6 2




extern int    Length=14;      // Bollinger Bands Period
extern int    Deviation=2;    // Deviation was 2
extern double MoneyRisk=0.02; // Offset Factor
int    Signal=1;       // Display signals mode: 1-Signals & Stops; 0-only Stops; 2-only Signals;
int    Line=1;         // Display line mode: 0-no,1-yes  
extern int    Nbars=1000;
//---- indicator buffers
double UpTrendBuffer[];
double DownTrendBuffer[];
double UpTrendSignal[];
double DownTrendSignal[];
double UpTrendLine[];
double DownTrendLine[];
bool SoundON=false;
bool TurnedUp = false;
bool TurnedDown = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   string short_name;
//---- indicator line
   
   SetIndexBuffer(0,UpTrendBuffer);
   SetIndexBuffer(1,DownTrendBuffer);
   SetIndexBuffer(2,UpTrendSignal);
   SetIndexBuffer(3,DownTrendSignal);
   SetIndexBuffer(4,UpTrendLine);
   SetIndexBuffer(5,DownTrendLine);
   SetIndexStyle(0,DRAW_ARROW,0,0);
   SetIndexStyle(1,DRAW_ARROW,0,0);
   SetIndexStyle(2,DRAW_ARROW,0);
   SetIndexStyle(3,DRAW_ARROW,0);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
   SetIndexArrow(2,233);
   SetIndexArrow(3,234);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="i-Custom bams-bung 2("+Length+","+Deviation+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend Stop");
   SetIndexLabel(1,"DownTrend Stop");
   SetIndexLabel(2,"UpTrend Signal");
   SetIndexLabel(3,"DownTrend Signal");
   SetIndexLabel(4,"UpTrend Line");
   SetIndexLabel(5,"DownTrend Line");
//----
   SetIndexDrawBegin(0,Length);
   SetIndexDrawBegin(1,Length);
   SetIndexDrawBegin(2,Length);
   SetIndexDrawBegin(3,Length);
   SetIndexDrawBegin(4,Length);
   SetIndexDrawBegin(5,Length);
//----
   return(0);
  }

//+------------------------------------------------------------------+
//|    i-Custom bams-bung 2                                     |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift,trend;
   double smax[25000],smin[25000],bsmax[25000],bsmin[25000];
   
   for (shift=Nbars;shift>=0;shift--)
   {
   UpTrendBuffer[shift]=0;
   DownTrendBuffer[shift]=0;
   UpTrendSignal[shift]=0;
   DownTrendSignal[shift]=0;
   UpTrendLine[shift]=EMPTY_VALUE;
   DownTrendLine[shift]=EMPTY_VALUE;
   }
   
   for (shift=Nbars-Length-1;shift>=0;shift--)
   {	
     smax[shift]=iBands(NULL,0,Length,Deviation,0,PRICE_CLOSE,MODE_UPPER,shift);
	  smin[shift]=iBands(NULL,0,Length,Deviation,0,PRICE_CLOSE,MODE_LOWER,shift);
	
	  if (Close[shift]>smax[shift+1]) trend=1; 
	  if (Close[shift]<smin[shift+1]) trend=-1;
		 	
	  if(trend>0 && smin[shift]<smin[shift+1]) smin[shift]=smin[shift+1];
	  if(trend<0 && smax[shift]>smax[shift+1]) smax[shift]=smax[shift+1];
	  	  
	  bsmax[shift]=smax[shift]+0.5*(MoneyRisk-1)*(smax[shift]-smin[shift]);
	  bsmin[shift]=smin[shift]-0.5*(MoneyRisk-1)*(smax[shift]-smin[shift]);
		
	  if(trend>0 && bsmin[shift]<bsmin[shift+1]) bsmin[shift]=bsmin[shift+1];
	  if(trend<0 && bsmax[shift]>bsmax[shift+1]) bsmax[shift]=bsmax[shift+1];
	  
	  if (trend>0) 
	  {
	     if (Signal>0 && UpTrendBuffer[shift+1]==-1.0)
	     {
	     UpTrendSignal[shift]=bsmin[shift];
	     UpTrendBuffer[shift]=bsmin[shift];
	     if(Line>0) UpTrendLine[shift]=bsmin[shift];
	     
     if (SoundON==true && shift==0 && !TurnedUp)
         {
     Alert("i-Custom bams-bung 2 --> ",Symbol(),"@TF",Period());
            TurnedUp = true;
            TurnedDown = false;
     }
	     }
	     else
	     {
	     UpTrendBuffer[shift]=bsmin[shift];
	     if(Line>0) UpTrendLine[shift]=bsmin[shift];
	     UpTrendSignal[shift]=-1;
	     }
	  if (Signal==2) UpTrendBuffer[shift]=0;   
	  DownTrendSignal[shift]=-1;
	  DownTrendBuffer[shift]=-1.0;
	  DownTrendLine[shift]=EMPTY_VALUE;
	  }
	  if (trend<0) 
	  {
	  if (Signal>0 && DownTrendBuffer[shift+1]==-1.0)
	     {
	     DownTrendSignal[shift]=bsmax[shift];
	     DownTrendBuffer[shift]=bsmax[shift];
	     if(Line>0) DownTrendLine[shift]=bsmax[shift];
     if (SoundON==true && shift==0 && !TurnedDown)
         {
     Alert("i-Custom bams-bung 2 --> ",Symbol(),"@TF",Period());
            TurnedDown = true;
            TurnedUp = false;
     }
	     }
	     else
	     {
	     DownTrendBuffer[shift]=bsmax[shift];
	     if(Line>0)DownTrendLine[shift]=bsmax[shift];
	     DownTrendSignal[shift]=-1;
	     }
	  if (Signal==2) DownTrendBuffer[shift]=0;    
	  UpTrendSignal[shift]=-1;
	  UpTrendBuffer[shift]=-1.0;
	  UpTrendLine[shift]=EMPTY_VALUE;
	  }
	  
	 }
	return(0);	
 }

