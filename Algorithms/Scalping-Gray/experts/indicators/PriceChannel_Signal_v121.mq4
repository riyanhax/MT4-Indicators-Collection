//+------------------------------------------------------------------+
//|                                       PriceChannel_Signal_v1.mq4 |
//|                           Copyright © 2007, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

//---- indicator parameters
extern int     Length         =  9;    // Price Channel Period
extern int     Applied_Price  =  0;    // Applied Price:0-C,1-O,2-H,3-L,4-Median,5-Typical,6-Weighted 
extern double  Risk           =  3;    // Risk Factor in units (0...10) 
extern int     UseReEntry     =  0;    // Re-Entry Mode: 0-off,1-on
extern int     AlertMode      =  0;    // Alert Mode: 0-off,1-on

//---- indicator buffers
double UpSignal[];
double DnSignal[]; 
double UpEntry[];
double DnEntry[]; 
double smax[];
double smin[];
double trend[];

bool   UpTrendAlert=false, DownTrendAlert=false;
datetime prevTime; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   string short_name;
//---- drawing settings
   IndicatorBuffers(7);
      
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,108);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,108);
   SetIndexStyle(2,DRAW_ARROW);
   //SetIndexArrow(2,108);
   SetIndexStyle(3,DRAW_ARROW);
   //SetIndexArrow(3,108);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- indicator short name
   IndicatorShortName("PriceChannel_Signal("+Length+")");
   SetIndexLabel(0,"UpSignal");
   SetIndexLabel(1,"DnSignal");
   SetIndexLabel(2,"UpRe-Entry");
   SetIndexLabel(3,"DnRe-Entry");
   SetIndexDrawBegin(0,Length);
   SetIndexDrawBegin(1,Length);
   SetIndexDrawBegin(2,Length);
   SetIndexDrawBegin(3,Length);
//---- indicator buffers mapping
   SetIndexBuffer(0,UpSignal);
   SetIndexBuffer(1,DnSignal);
   SetIndexBuffer(2,UpEntry);
   SetIndexBuffer(3,DnEntry);
   SetIndexBuffer(4,smax);
   SetIndexBuffer(5,smin);
   SetIndexBuffer(6,trend);
   
//---- initialization done
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   if(Bars<=Length) return(0);
   int CountedBars=IndicatorCounted();
//---- check for possible errors
   if (CountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (CountedBars>0) CountedBars--;
   limit=Bars-CountedBars;
//---- 
   for(int i=limit; i>=0; i--)
   { 
   double price  = iMA(NULL,0,1,0,0,Applied_Price,i);
   double price1 = iMA(NULL,0,1,0,0,Applied_Price,i+1);
   double price2 = iMA(NULL,0,1,0,0,Applied_Price,i+2);
         
   double hi = High[iHighest(NULL,0,MODE_HIGH,Length,i)];   
   double lo = Low[iLowest(NULL,0,MODE_LOW,Length,i)];
   
   smax[i] = hi - (33-Risk)*(hi-lo)/100;
   smin[i] = lo + (33-Risk)*(hi-lo)/100;
   
   trend[i]=trend[i+1]; 
	   
	if ( price > smax[i])  trend[i]=1; 
	if ( price < smin[i])  trend[i]=-1;

      if(trend[i]>0)
	   {
	   if (trend[i+1]<0) UpSignal[i] = Low[i]-0.5*iATR(NULL,0,Length,i);
	   if (UseReEntry > 0 && price > smax[i] && price1 <= smax[i+1]) UpEntry[i] = Low[i]-0.5*iATR(NULL,0,Length,i); 
	   DnSignal[i]=EMPTY_VALUE; DnEntry[i]=EMPTY_VALUE;
	   }
	   else
	   if(trend[i]<0)
	   {
	   if (trend[i+1]>0) DnSignal[i] = High[i]+0.5*iATR(NULL,0,Length,i);
	   if (UseReEntry > 0 && price < smin[i] && price1 >= smin[i+1]) DnEntry[i] = High[i]+0.5*iATR(NULL,0,Length,i); 
	   UpSignal[i]=EMPTY_VALUE; UpEntry[i]=EMPTY_VALUE;
	   }
   	         
//----------   
      if (i==0 && AlertMode > 0)
      {
         if (trend[i] > 0 && Volume[0]>0)
         {
            if (trend[i+1]<0 && !UpTrendAlert)
	         {
	         string Message = " "+Symbol()+" M"+Period()+": Signal for BUY";
	         Alert (Message); 
	         UpTrendAlert=true; DownTrendAlert=false;
	         } 
	      
	         if (UseReEntry>0 && trend[i+1]>0 && price1 > smax[i] && price2 < smax[i+1] && Time[i]!=prevTime)
	         {
	         Message = " "+Symbol()+" M"+Period()+": Re-Entry for BUY";
	         Alert (Message);
	         prevTime = Time[i];
	         }
	      }
	      else
	      if (trend[i] < 0 && Volume[0]>0)
	      {
            if ( trend[i+1]>0 && !DownTrendAlert)
	         {
	         Message = " "+Symbol()+" M"+Period()+": Signal for SELL";
	         Alert (Message); 
	         DownTrendAlert=true; UpTrendAlert=false;     
	         }
	         
	         if (UseReEntry>0 && trend[i+1]<0 && price1 < smin[i] && price2 > smin[i+1] && Time[i]!=prevTime)
	         {
	         Message = " "+Symbol()+" M"+Period()+": Re-Entry for SELL";
	         Alert (Message);
	         prevTime = Time[i];
	         }
	      } 	  
      }	
	} 	         

//---- done
   return(0);
}
//+------------------------------------------------------------------+