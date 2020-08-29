//+------------------------------------------------------------------+
//|                                                           XO.mq4 |
//|                                   Original Author SHARIPOV AINUR |
//|               Conversion to MT4 and modification only adoleh2000 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Lime  //XO up
#property  indicator_color2  Red  //XO down

extern double KirPER=10;
double cb,valuel,valueh,CurrentBar;
double Kir ,Hi, Lo, KirUp, KirDn,mode,cnt,cnt1,cur,kr,no;
double ExtMapBuffer1[]; // XO up
double ExtMapBuffer2[]; // Xo down
int loopbegin;




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
     IndicatorBuffers(2);   
//---- drawing settings
      
   SetIndexBuffer(0,ExtMapBuffer1);//bbMacd line
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   
   
   SetIndexBuffer(1,ExtMapBuffer2);//Upperband line
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   
  IndicatorShortName("XO ("+KirPER+"), "+valueh+","+valuel);
  SetIndexLabel(0,"XO Up");
  SetIndexLabel(1,"XO Down");


//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
      int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
         
      loopbegin = Bars-1;
      for(int i = loopbegin; i >= 0; i--)
      {         

if (Kir<1)
{
Hi=Close[i];
Lo=Close[i];
Kir=1;
}


cur=(Close[i]);


if (cur > (Hi+KirPER * Point)) 
{
Kir=Kir+1;
Hi=cur;
Lo=cur-KirPER*Point;
KirUp=1;
KirDn=0;
kr=kr+1;
no=0;
}

if (cur < (Lo-KirPER*Point)) 
{
Lo=cur;
Hi=cur+KirPER*Point;
KirUp=0;
KirDn=1;
Kir=Kir+1;
no=no+1;
kr=0;
}

valueh=kr;
ExtMapBuffer1[i]=valueh;//XO up

if (valueh < 0)
{
ExtMapBuffer1[i] = 0;
} 
if (valueh > 0)
{
ExtMapBuffer1[i] = 1;
} 

valuel=0-no;
ExtMapBuffer2[i]=valuel;// XO down

if (valuel > 0)
{
ExtMapBuffer2[i] = 0;
} 
if (valuel < 0)
{
ExtMapBuffer2[i] = -1;
} 


      
}

   
//----
   return(0);
  }
//+------------------------------------------------------------------+