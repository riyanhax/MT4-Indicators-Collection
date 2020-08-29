//+------------------------------------------------------------------

//|                                            Stopreversal Mt4.mq4 
//|                                                                  
//|                                                                  

//|                                 Conversion only Dr. Gaines       

//|                                 dr_richard_gaines@yahoo.com      

//|                                                                  

//+------------------------------------------------------------------


#property copyright " Dominic."
#property link      " http://www.metaquotes.net/"

#property indicator_chart_window
#include <stdlib.mqh>
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_width1 2 
#property indicator_color2 Red
#property indicator_width2 2



extern double nPips = 0.004;// for calculation of arrows
extern int StopPips =40; // for calculation of blue stop line ignored if UseATRStop is true
extern bool UseATRStop = true;//  
extern double ATRmultiplier= 0.45; //  

double stop,atr;
int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];

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
   SetIndexBuffer(0, ExtHistoBuffer);
   SetIndexBuffer(1, ExtHistoBuffer2);
   
   return(0);
}
int deinit()
  {
//----
for(int shift=Bars-2;shift>=0 ;shift--)
   {
   if (ObjectFind(TimeToStr(Time[shift]))>-1) ObjectDelete(TimeToStr(Time[shift]));
   }

//----
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


if( Close[shift] > TrStopLevel &&  Close[shift+1]<PREV && PREV !=0) 
{
if (UseATRStop)
   {
   atr=iATR(NULL,0,14,shift);
   stop =NormalizeDouble(TrStopLevel-atr*ATRmultiplier,MarketInfo(Symbol(),MODE_DIGITS));
   }
   else stop =NormalizeDouble(TrStopLevel-StopPips*Point,MarketInfo(Symbol(),MODE_DIGITS));
if (ObjectFind(TimeToStr(Time[shift]))>-1) ObjectDelete(TimeToStr(Time[shift])); 
ObjectCreate(TimeToStr(Time[shift]),OBJ_TREND,0,Time[shift+1],stop,Time[shift],stop);
ObjectSet(TimeToStr(Time[shift]),OBJPROP_RAY,0);
ObjectSet(TimeToStr(Time[shift]),OBJPROP_COLOR,DodgerBlue);
ObjectSet(TimeToStr(Time[shift]),OBJPROP_WIDTH,2);
Comment(stop);
//SetOrder(OP_BUY,1,ask,2,0,ask+TakeProfit*Point,blue);
//Alert("buy");
SetIndexValue(shift, TrStopLevel);
}


if( Close[shift] < TrStopLevel &&  Close[shift+1]>PREV  && PREV != 
0  ) 
{
//SetOrder(OP_SELL,1,bid,2,0,bid-TakeProfit*Point,Red);
if (UseATRStop)
   {
   atr=iATR(NULL,0,14,shift);
   stop =NormalizeDouble(TrStopLevel+atr*ATRmultiplier,MarketInfo(Symbol(),MODE_DIGITS));
   }
   else stop =NormalizeDouble(TrStopLevel+StopPips*Point,MarketInfo(Symbol(),MODE_DIGITS));
if (ObjectFind(TimeToStr(Time[shift]))>-1) ObjectDelete(TimeToStr(Time[shift])); 
ObjectCreate(TimeToStr(Time[shift]),OBJ_TREND,0,Time[shift+1],stop,Time[shift],stop);
ObjectSet(TimeToStr(Time[shift]),OBJPROP_RAY,0);
ObjectSet(TimeToStr(Time[shift]),OBJPROP_COLOR,DodgerBlue);
ObjectSet(TimeToStr(Time[shift]),OBJPROP_WIDTH,2);

SetIndexValue2(shift, TrStopLevel);
Comment(stop);
//Alert("Sell");
}


PREV=TrStopLevel;
//Alert(TrStopLevel);
} 

  return(0);
}

