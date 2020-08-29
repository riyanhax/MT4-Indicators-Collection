//+------------------------------------------------------------------+
//|                               Guppy Multiple Moving Averages.mq4 |
//|                              Copyright 2015, Dmitriy Kudryashov. |
//|                       https://www.mql5.com/ru/users/dlim0n4ik.dk |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Dmitriy Kudryashov."
#property link      "https://www.mql5.com/ru/users/dlim0n4ik.dk"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 15
#property indicator_plots   15
/*
Версия 1.00
- Реализация индикатора по стратегии Дерила Гуппи (Daryl Guppy).
Версия 2.00
- Реализовано переключение вида отображения ЛИНИИ или СТРЕЛКИ;
- Добавлена возможность включение и выключение Main Moving Average.

*/
//--- plot fMA0
#property indicator_label1  "fMA0"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot fMA1
#property indicator_label2  "fMA1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot fMA2
#property indicator_label3  "fMA2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot fMA3
#property indicator_label4  "fMA3"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot fMA4
#property indicator_label5  "fMA4"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot fMA5
#property indicator_label6  "fMA5"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot sMA0
#property indicator_label7  "sMA0"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGreen
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot sMA1
#property indicator_label8  "sMA1"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrGreen
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot sMA2
#property indicator_label9  "sMA2"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrGreen
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot sMA3
#property indicator_label10  "sMA3"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrGreen
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- plot sMA4
#property indicator_label11  "sMA4"
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrGreen
#property indicator_style11  STYLE_SOLID
#property indicator_width11  1
//--- plot sMA5
#property indicator_label12  "sMA5"
#property indicator_type12   DRAW_LINE
#property indicator_color12  clrGreen
#property indicator_style12  STYLE_SOLID
#property indicator_width12  1
//--- plot mMA
#property indicator_label13  "mMA"
#property indicator_type13   DRAW_LINE
#property indicator_color13  clrBlue
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1
//--- plot BUY
#property indicator_label14  "BUY"
#property indicator_type14   DRAW_ARROW
#property indicator_color14  clrGreen
#property indicator_style14  STYLE_SOLID
#property indicator_width14  1
//--- plot SELL
#property indicator_label15  "SELL"
#property indicator_type15   DRAW_ARROW
#property indicator_color15  clrRed
#property indicator_style15  STYLE_SOLID
#property indicator_width15  1

enum ENUM_DISPLAY_STYLE {Line = 0, Arrow = 1};
input ENUM_DISPLAY_STYLE DiS = 0;
input bool UseMainMA = false;
//--- indicator buffers
double         fMA0Buffer[];
double         fMA1Buffer[];
double         fMA2Buffer[];
double         fMA3Buffer[];
double         fMA4Buffer[];
double         fMA5Buffer[];
double         sMA0Buffer[];
double         sMA1Buffer[];
double         sMA2Buffer[];
double         sMA3Buffer[];
double         sMA4Buffer[];
double         sMA5Buffer[];
double         mMABuffer[];
double         BUYBuffer[];
double         SELLBuffer[];

//--- Буферы напраления тренда Fast Moving Average 
bool fastTrendUP=FALSE;
bool fastTrendDOWN=FALSE;
//--- Буферы напраления тренда Slow Moving Average 
bool slowTrendUP=FALSE;
bool slowTrendDOWN=FALSE;

int Cont = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fMA0Buffer);
   SetIndexBuffer(1,fMA1Buffer);
   SetIndexBuffer(2,fMA2Buffer);
   SetIndexBuffer(3,fMA3Buffer);
   SetIndexBuffer(4,fMA4Buffer);
   SetIndexBuffer(5,fMA5Buffer);
   SetIndexBuffer(6,sMA0Buffer);
   SetIndexBuffer(7,sMA1Buffer);
   SetIndexBuffer(8,sMA2Buffer);
   SetIndexBuffer(9,sMA3Buffer);
   SetIndexBuffer(10,sMA4Buffer);
   SetIndexBuffer(11,sMA5Buffer);
   SetIndexBuffer(12,mMABuffer);

   
SetIndexStyle(13, DRAW_ARROW, EMPTY);
SetIndexArrow(13, SYMBOL_ARROWUP);
SetIndexBuffer(13, BUYBuffer);

SetIndexStyle(14, DRAW_ARROW, EMPTY);
SetIndexArrow(14, SYMBOL_ARROWDOWN);
SetIndexBuffer(14, SELLBuffer);
   
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(13,PLOT_ARROW,159);
   PlotIndexSetInteger(14,PLOT_ARROW,159);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
int i;
int limit=rates_total-prev_calculated;
for(i=0; i<limit; i++)
   {
//--- Расчет Fast Moving Average -------------------------------------
   double fMA0=iMA(NULL,0,3,0,MODE_EMA,PRICE_CLOSE,i);
   double fMA1=iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,i);
   double fMA2=iMA(NULL,0,8,0,MODE_EMA,PRICE_CLOSE,i);
   double fMA3=iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,i);
   double fMA4=iMA(NULL,0,12,0,MODE_EMA,PRICE_CLOSE,i);
   double fMA5=iMA(NULL,0,15,0,MODE_EMA,PRICE_CLOSE,i);
//--------------------------------------------------------------------

//--- Расчет Slow Moving Average -------------------------------------
   double sMA0=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i);
   double sMA1=iMA(NULL,0,35,0,MODE_EMA,PRICE_CLOSE,i);
   double sMA2=iMA(NULL,0,40,0,MODE_EMA,PRICE_CLOSE,i);
   double sMA3=iMA(NULL,0,45,0,MODE_EMA,PRICE_CLOSE,i);
   double sMA4=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,i);
   double sMA5=iMA(NULL,0,55,0,MODE_EMA,PRICE_CLOSE,i);
//--------------------------------------------------------------------

   if(DiS == 0)
      {
//--- Присвоение буферу значений Fast Moving Average -----------------
      fMA0Buffer[i]=fMA0;
      fMA1Buffer[i]=fMA1;
      fMA2Buffer[i]=fMA2;
      fMA3Buffer[i]=fMA3;
      fMA4Buffer[i]=fMA4;
      fMA5Buffer[i]=fMA5;
//--------------------------------------------------------------------

//--- Присвоение буферу значений Slow Moving Average -----------------
      sMA0Buffer[i]=sMA0;
      sMA1Buffer[i]=sMA1;
      sMA2Buffer[i]=sMA2;
      sMA3Buffer[i]=sMA3;
      sMA4Buffer[i]=sMA4;
      sMA5Buffer[i]=sMA5;
//--------------------------------------------------------------------

      }
//--- Расчет Main Moving Average -------------------------------------
   double mMA=iMA(NULL,0,200,0,MODE_EMA,PRICE_CLOSE,i);
   if(UseMainMA == true)
      {
      mMABuffer[i]=mMA;
      }
   else
      {
      mMABuffer[i]=EMPTY_VALUE;
      }  
//--------------------------------------------------------------------
   if(DiS == 1)
      {
//--- Условия определения тренда по Fast Moving Average --------------
      if(fMA0 > fMA1 > fMA2 > fMA3 > fMA4 > fMA5)
         {
         fastTrendUP = TRUE;
         fastTrendDOWN = FALSE;
         }
      if(fMA0 < fMA1 < fMA2 < fMA3 < fMA4 < fMA5)
         {
         fastTrendUP = FALSE;
         fastTrendDOWN = TRUE;
         }
//--------------------------------------------------------------------

//--- Условия определения тренда по Slow Moving Average --------------
      if(sMA0 > sMA1 > sMA2 > sMA3 > sMA4 > sMA5)
         {
         slowTrendUP = TRUE;
         slowTrendDOWN = FALSE;
         }
      if(sMA0 < sMA1 < sMA2 < sMA3 < sMA4 < sMA5)
         {
         slowTrendUP = FALSE;
         slowTrendDOWN = TRUE;
         }
//--------------------------------------------------------------------

      if(fastTrendUP == TRUE && slowTrendUP == TRUE && Cont != 1)
         {
         SELLBuffer[i]=High[i]+(20*Point);       //Стрелка ВВЕРХ
         Cont = 1;
         }
      else
         {
         if(fastTrendDOWN == TRUE && slowTrendDOWN == TRUE && Cont !=2)
            {
            BUYBuffer[i]=Low[i]-(20*Point);   //Стрелка ВНИЗ
            Cont = 2;
            }
         }
      }
   }
   return(rates_total);
   
}
//+------------------------------------------------------------------+
