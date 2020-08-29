#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 DodgerBlue
#property indicator_color3 CadetBlue
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 RoyalBlue
#property indicator_color7 RoyalBlue
#property indicator_color8 PaleGreen

//---- input parameters
extern int       TCCIp=7;
extern int       CCIp=13;
extern double    overbslevel=200.0;
extern double    triglevel=50.0;
extern double    weight=1.0;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"Turbo CCI");
   SetIndexStyle(1,DRAW_LINE,1,3);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(2,"CCI");
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE,1,3);
   SetIndexLabel(3,"CCI");
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE,1,3);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_LINE,STYLE_DASH,1);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexStyle(6,DRAW_LINE,STYLE_DASH,1);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexStyle(7,DRAW_LINE,STYLE_DASH,1);
   SetIndexBuffer(7,ExtMapBuffer8);
   
   SetIndexDrawBegin(0,50);
   SetIndexDrawBegin(1,50);
   SetIndexDrawBegin(2,50);
   SetIndexDrawBegin(3,50);
   SetIndexDrawBegin(4,50);
   SetIndexDrawBegin(5,50);
   SetIndexDrawBegin(6,50);
   SetIndexDrawBegin(7,50);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
int trend_counter=0;
string trend="ZERO";
int start()
  {
   
   int    counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   //if(counted_bars>0) counted_bars=-1;
   int limit=Bars-counted_bars;
   //if (limit>Bars-CCIp-1)limit=Bars-CCIp-1;
   //Comment(Bars+"    "+limit); 
   double Kw=0.0;
   int alt=0;
//---- 
   for (int shift = 0; shift<=limit;shift++)
   {  
   
      double CCI=iCCI(NULL,0,CCIp,PRICE_TYPICAL,shift);
      double TCCI=iCCI(NULL,0,TCCIp,PRICE_TYPICAL,shift);  
     
      if (weight==0)Kw=0; 
      else
      {  Kw=weight*iATR(NULL,0,7,shift)/iATR(NULL,0,49,shift);
         CCI=CCI*Kw;
         TCCI=TCCI*Kw;
      }
      if(TCCI>overbslevel+50)TCCI=overbslevel+50;
      if(CCI>overbslevel+50)CCI=overbslevel+50;
      if(CCI<-overbslevel-50)CCI=-overbslevel-50;
      if(TCCI<-overbslevel-50)TCCI=-overbslevel-50;
      ExtMapBuffer1[shift]=TCCI;
      ExtMapBuffer2[shift]=CCI;
      ExtMapBuffer3[shift]=CCI;
      ExtMapBuffer4[shift]=overbslevel;
      ExtMapBuffer5[shift]=-overbslevel;
      ExtMapBuffer6[shift]=triglevel;
      ExtMapBuffer7[shift]=-triglevel;
      ExtMapBuffer8[shift]=0;
      
      if (shift==0)
      {	if (CCI>0) 
		    if (trend=="UP" && limit>1)trend_counter+=1; else {trend_counter=1;trend="UP";}
	        else if (trend=="DOWN" && Bars-counted_bars>1) trend_counter+=1; else {trend_counter=1;trend="DOWN";} 	
      
	      Comment("CCI is trending ",trend," during last ",trend_counter," bar(s)");
      }		
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+