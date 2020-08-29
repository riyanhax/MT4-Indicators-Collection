//+------------------------------------------------------------------+
//|                                     T.S.V._Bullish & Bearish.mq4 |
//|                                                    Sergey_T.S.V. |
//|                                                       &&&&&&&&&& |
//+------------------------------------------------------------------+
#property copyright "Sergey_T.S.V."
#property  indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  Blue
#property indicator_color2 Red
#property indicator_color3 Lime 
extern int period=15;extern int CountBars=3000;
double ExtBuffer0[];double ExtBuffer1[];double ExtBuffer2[];double Up[];double Down[];
int init(){
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,4,Red);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,4,Lime);IndicatorDigits(Digits+1);
   SetIndexBuffer(0,ExtBuffer0);SetIndexBuffer(1,ExtBuffer1);SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(1,Up);SetIndexBuffer(2,Down);
   return(0);}
int start(){
   SetIndexDrawBegin(1,Bars-CountBars+period);SetIndexDrawBegin(2,Bars-CountBars+period);
   int i,counted_bars=IndicatorCounted();bool Pr=false,PrevPr=false;double val,val2;
   if(CountBars<=period)return(0);if(counted_bars<1){ for(i=1;i<=period;i++)Up[CountBars-i]=0.0;
   for(i=1;i<=period;i++)Down[CountBars-i]=0.0;}i=CountBars-period-1;while(i>=0){
   val=iMA(NULL,0,period,1,MODE_SMA,PRICE_HIGH,i);val2=iMA(NULL,0,period,1,MODE_SMA,PRICE_LOW,i);
   if (Close[i]<val2 && PrevPr==true)Pr=false;if (Close[i]>val && PrevPr==false)Pr=true;
   PrevPr=Pr;Up[i]=0.0;Down[i]=0.0;if (Pr==false)Up[i] = val+2*Point; 
   if (Pr==true)Down[i] = val2-2*Point; i--; } 
   return(0);}
//+------------------------------------------------------------------+