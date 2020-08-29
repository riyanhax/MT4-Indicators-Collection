//+------------------------------------------------------------------
//|                                            Stopreversal Mt4.mq4 
//|                                                                  
//|                                                                  
//|                                 Conversion only Dr. Gaines       
//|                                 dr_richard_gaines@yahoo.com 
//|                                 modifications by Emsjoflo joel@emsjoflo.com     
//|                                                                  
//+------------------------------------------------------------------


#property copyright " emsjoflo"
#property link      "automaticforec.invisionzone.com"
#property indicator_chart_window
#include <stdlib.mqh>
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_width1 2 
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_color3 DodgerBlue
#property indicator_color4 Tomato



extern double nPips = 0.004;
extern bool SendAlert = true;
extern bool SendEmail = true;
extern int AlertMinutesB4Close =30;


int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];
double BlueBar[],RedBar[];

void SetLoopCount(int loops)
{
}

void SetIndexValue(int shift, double value)
{
  ExtHistoBuffer[shift] = value;
}

void SetIndexValue2(int shift, double value)
{
  ExtHistoBuffer2[shift] = value;
}

int init()
{
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, ExtHistoBuffer);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, ExtHistoBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(2,BlueBar); 
   SetIndexStyle(3,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(3,RedBar);
   
   
   
   return(0);
}
int start()
{
//+------------------------------------------------------------------

//| Local variables                                                  

//+------------------------------------------------------------------

int shift = 0;
double cnt = 0;
double TrStopLevel = 0;
double PREV = 0;
double pass = 0;

SetLoopCount(0);
// loop from first bar to current bar (with shift=0)
for(shift=Bars-2;shift>=0 ;shift--){ 


if( (Close[shift] == PREV) ) 
{
TrStopLevel=PREV;

}
else 
{
if( (Close[shift+1])<PREV && (Close[shift]<PREV)  ) 
{
TrStopLevel=MathMin(PREV,Close[shift]*(1+nPips));
}
      else 
      {
            if( ((Close[shift+1])>PREV) && (Close[shift]>PREV) ) 
            {
            TrStopLevel=MathMax(PREV,Close[shift]*(1-nPips));
            }

           else 
                  {
                  if( (Close[shift]>PREV) ) 
                  {                   
                  TrStopLevel=Close[shift]*(1-nPips);
                  }

                        else TrStopLevel=Close[shift]*
(1+nPips);
                  }
      }
}


if( Close[shift] > TrStopLevel &&  Close[shift+1]<PREV && PREV !=0 ) 
{
if (CurTime() -iTime(NULL,0,1)==(iTime(NULL,0,1)-iTime(NULL,0,2)-AlertMinutesB4Close*60) 
&& CurTime() -iTime(NULL,0,1)>=(iTime(NULL,0,2)-iTime(NULL,0,3)-AlertMinutesB4Close*60)
&& CurTime() -iTime(NULL,0,2)>=(iTime(NULL,0,1)-iTime(NULL,0,3)-AlertMinutesB4Close*60))
   {
   if(SendAlert) Alert("Look for Buying opportunity soon");
   if(SendEmail) SendMail("Possible Buy setup on "+Symbol(),"Stop Reversal Indicator is anticipating a Buy setup on "+Symbol()+Period()+"in "+AlertMinutesB4Close+" minutes"); 
   }
   RedBar[shift]=Low[shift];
   BlueBar[shift]=High[shift];
//SetOrder(OP_BUY,1,ask,2,0,ask+TakeProfit*Point,blue);
//Alert("buy");
SetIndexValue(shift, TrStopLevel);
}


if( Close[shift] < TrStopLevel &&  Close[shift+1]>PREV  && PREV !=0) 
{
if ((CurTime() -iTime(NULL,0,1))==(iTime(NULL,0,1)-iTime(NULL,0,2)-AlertMinutesB4Close*60)
&& (CurTime() -iTime(NULL,0,1))>=(iTime(NULL,0,2)-iTime(NULL,0,3)-AlertMinutesB4Close*60)
&& (CurTime() -iTime(NULL,0,2))>=(iTime(NULL,0,1)-iTime(NULL,0,3)-AlertMinutesB4Close*60))
   {
   if (SendAlert)Alert("Look for Selling opportunity soon");
   if(SendEmail) SendMail("Possible Sell setup on "+Symbol(),"Stop Reversal Indicator is anticipating a Sellz setup on "+Symbol()+Period()+"in "+AlertMinutesB4Close+" minutes");
   
   }
   
   
   BlueBar[shift]=Low[shift];
   RedBar[shift]=High[shift];
//SetOrder(OP_SELL,1,bid,2,0,bid-TakeProfit*Point,Red);
SetIndexValue2(shift, TrStopLevel);
//Alert("Sell");
}


PREV=TrStopLevel;
//Alert(TrStopLevel);
} 

  return(0);
}

