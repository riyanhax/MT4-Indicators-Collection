//+------------------------------------------------------------------+
//|                                                 JMASlope_MTF.mq4 |
//|                      Copyright © 2007, ASystem Group             |
//|                                        asystem2000@rambler.ru    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Asystem2000"
#property link      "asystem2000@rambler.ru"

// Простой индикатор, который который позволяет построить в разных таймфреймах аналог индикатора JMASlope
// Если у Вас базовый индикатор JMASlope имеет другое название исправьте в параметре Indicator
// Теоретически этот инидикатор может обслужить любой инидикатор и построить его гистограмму в разных
// таймфреймах.
// Единственное условие: базовый индикатор должен иметь два входных параметра с типом integer

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red
//---- input parameters
extern int       TimeFrame=0;
extern int       Length=14;
extern int       Phase=0;
extern string    Note="Можете поменять имя инидикатора, если не совпадает";
extern string    Indicator="JMASlope";

//---- buffers
double B_Up[];
double B_Dn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  if (TimeFrame!=0)
  { 
  if (TimeFrame<Period())
     {
       Alert("Настраиваемый таймфрейм должен быть больше текущего или равен 0");
       deinit();
       return(0);
     }
  }   
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,0,0);
   SetIndexBuffer(0,B_Up);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,0);
   SetIndexBuffer(1,B_Dn);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    limit=Bars-counted_bars-1;
   int    C_time;
   int    Bar_Shift;
   if (limit==0) return(0);
//----
   int i=0;
   while(i<limit)
   {
     C_time=Time[i];
     Bar_Shift=iBarShift(NULL,TimeFrame,C_time,false);
     B_Up[i]=iCustom(NULL,TimeFrame,Indicator,Length,Phase,0,Bar_Shift);
     B_Dn[i]=iCustom(NULL,TimeFrame,Indicator,Length,Phase,1,Bar_Shift); 
     i++;
   }
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+