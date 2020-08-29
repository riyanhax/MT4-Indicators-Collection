//+------------------------------------------------------------------+
//|                                           all Time_In_Corner.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, SoloatovS Corp."
#property link      "SolomatovS@GMail.com"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1

extern color    UP   = Black;
extern color    DOWN = Black;
extern color    DOJI = Black;
extern bool     time = true;
extern color    TIME = White;
extern bool     volume = false;
extern color    VOLUME = Black;
extern string   symbol1 = "EURUSD";
extern string   symbol2 = "GBPUSD";
extern string   symbol3 = "EURGBP";
extern string   symbol4 = "";
extern string   symbol5 = "";
extern string   symbol6 = "";
extern string   symbol7 = "";
extern string   symbol8 = "";
extern string   symbol9 = "";
extern string   symbol10 = "";
extern string   symbol11 = "";
extern string   symbol12 = "";
extern string   symbol13 = "";
extern string   symbol14 = "";
extern string   symbol15 = "";
extern string   symbol16 = "";
extern string   symbol17 = "";
extern string   symbol18 = "";
extern string   symbol19 = "";
extern string   symbol20 = "";

string   symbol, SYMBOL[], TimeFrame;
int      HandleWindow, KolSybmol = 20;

int init()
{
   int      Len, i=0;
   symbol = Symbol();

   IndicatorShortName(symbol);
   if(StringLen(symbol1) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol1;
      i++;
   }
   if(StringLen(symbol2) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol2;
      i++;
   }
   if(StringLen(symbol3) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol3;
      i++;
   }
   if(StringLen(symbol4) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol4;
      i++;
   }
   if(StringLen(symbol5) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol5;
      i++;
   }
   if(StringLen(symbol6) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol6;
      i++;
   }
   if(StringLen(symbol7) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol7;
      i++;
   }
   if(StringLen(symbol8) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol8;
      i++;
   }
   if(StringLen(symbol9) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol9;
      i++;
   }
   if(StringLen(symbol10) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol10;
      i++;
   }
   if(StringLen(symbol11) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol11;
      i++;
   }
   if(StringLen(symbol12) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol12;
      i++;
   }
   if(StringLen(symbol13) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol13;
      i++;
   }
   if(StringLen(symbol14) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol14;
      i++;
   }
   if(StringLen(symbol15) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol15;
      i++;
   }
   if(StringLen(symbol16) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol16;
      i++;
   }
   if(StringLen(symbol17) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol17;
      i++;
   }
   if(StringLen(symbol18) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol18;
      i++;
   }
   if(StringLen(symbol19) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol19;
      i++;
   }
   if(StringLen(symbol20) == 0)   KolSybmol--;
   else
   {
      ArrayResize(SYMBOL, ArraySize(SYMBOL)+1);
      SYMBOL[i]   = symbol20;
      i++;
   }

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(HandleWindow);
   return (0);
}

int start()
{
   int    i, TimeFrame_VOLUME;
   color  COLOR;
   datetime Date = TimeCurrent();
   double OPEN, CLOSE, M1, M5, M15, M30, H1, H4, D1, W1, MN1;

   HandleWindow = WindowFind(symbol);

   ObjectCreate("ASK", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
   ObjectSet("ASK", OBJPROP_XDISTANCE, 523);
   ObjectSet("ASK", OBJPROP_YDISTANCE, 2);
   ObjectSetText("ASK", "...ASK...", 10, "Comic Sans", UP);

   ObjectCreate("BID", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
   ObjectSet("BID", OBJPROP_XDISTANCE, 593);
   ObjectSet("BID", OBJPROP_YDISTANCE, 2);
   ObjectSetText("BID", "...BID...", 10, "Comic Sans", DOWN);

   //Выводим Пары (Символы)
   for(i=0; i<KolSybmol; i++)
   {
      ObjectCreate(SYMBOL[i], OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(SYMBOL[i], OBJPROP_XDISTANCE, 3);
      ObjectSet(SYMBOL[i], OBJPROP_YDISTANCE, 23+i*20);
      ObjectSetText(SYMBOL[i], SYMBOL[i], 10, "Comic Sans", UP);
      //Ставим цену на прокупку (ASK)
      ObjectCreate(SYMBOL[i]+"ASK", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(SYMBOL[i]+"ASK", OBJPROP_XDISTANCE, 523);
      ObjectSet(SYMBOL[i]+"ASK", OBJPROP_YDISTANCE, 23+i*20);
      ObjectSetText(SYMBOL[i]+"ASK", DoubleToStr(MarketInfo(SYMBOL[i], MODE_ASK), Digits), 10, "Comic Sans", UP);
      //Ставим цену на продажу (BID)
      ObjectCreate(SYMBOL[i]+"BID", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(SYMBOL[i]+"BID", OBJPROP_XDISTANCE, 593);
      ObjectSet(SYMBOL[i]+"BID", OBJPROP_YDISTANCE, 23+i*20);
      ObjectSetText(SYMBOL[i]+"BID", DoubleToStr(MarketInfo(SYMBOL[i], MODE_BID), Digits), 10, "Comic Sans", DOWN);
   }

   //Выводим ТаймФрейм
   for(int k=0; k<9; k++)
   {
      switch(k)
      {
         case 0: TimeFrame = "...M1..";  break;
         case 1: TimeFrame = "...M5..";  break;
         case 2: TimeFrame = "..M15..";  break;
         case 3: TimeFrame = "..M30..";  break;
         case 4: TimeFrame = "...H1..";  break;
         case 5: TimeFrame = "...H4..";  break;
         case 6: TimeFrame = "...D1..";  break;
         case 7: TimeFrame = "...W1..";  break;
         case 8: TimeFrame = "..MN1..";  break;
      }
      ObjectCreate(symbol+k, OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+k, OBJPROP_XDISTANCE, k * 43 + 100);
      ObjectSet(symbol+k, OBJPROP_YDISTANCE, 5);
      ObjectSetText(symbol+k, TimeFrame, 10, "Terminal", UP);
   }

   //Выводим "Светофорчик"
   for(k=0; k<KolSybmol; k++)
   {
      M1  = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_M1,  0), Digits);
      M5  = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_M5,  0), Digits);
      M15 = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_M15, 0), Digits);
      M30 = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_M30, 0), Digits);
      H1  = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_H1,  0), Digits);
      H4  = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_H4,  0), Digits);
      D1  = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_D1,  0), Digits);
      W1  = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_W1,  0), Digits);
      MN1 = NormalizeDouble(iOpen(SYMBOL[k], PERIOD_MN1, 0), Digits);
      CLOSE=NormalizeDouble(iClose(SYMBOL[k],PERIOD_M1,  0), Digits);

      for(i=0; i<9; i++)
      {
         switch(i)
         {
            case 0: OPEN = M1;  TimeFrame_VOLUME = PERIOD_M1;  break;
            case 1: OPEN = M5;  TimeFrame_VOLUME = PERIOD_M5;  break;
            case 2: OPEN = M15; TimeFrame_VOLUME = PERIOD_M15; break;
            case 3: OPEN = M30; TimeFrame_VOLUME = PERIOD_M30; break;
            case 4: OPEN = H1;  TimeFrame_VOLUME = PERIOD_H1;  break;
            case 5: OPEN = H4;  TimeFrame_VOLUME = PERIOD_H4;  break;
            case 6: OPEN = D1;  TimeFrame_VOLUME = PERIOD_D1;  break;
            case 7: OPEN = W1;  TimeFrame_VOLUME = PERIOD_W1;  break;
            case 8: OPEN = MN1; TimeFrame_VOLUME = PERIOD_MN1; break;
         }
         COLOR = COLOR_FUNK(OPEN, CLOSE);
         ObjectCreate(SYMBOL[k]+k+i, OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
         ObjectSet(SYMBOL[k]+k+i, OBJPROP_XDISTANCE, i * 43 + 100);
         ObjectSet(SYMBOL[k]+k+i, OBJPROP_YDISTANCE, 25+k*20);
         ObjectSet(SYMBOL[k]+k+i, OBJPROP_ARROWCODE, 111);
         ObjectSetText(SYMBOL[k]+k+i, "ЫЫЫЫЫЫЫЫ", 10, "Terminal", COLOR);
         if(volume == true)
         {
            ObjectCreate(SYMBOL[k]+k+i+"Volume", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
            ObjectSet(SYMBOL[k]+k+i+"Volume", OBJPROP_XDISTANCE, i * 43 + 108);
            ObjectSet(SYMBOL[k]+k+i+"Volume", OBJPROP_YDISTANCE, 25+k*20);
            ObjectSet(SYMBOL[k]+k+i+"Volume", OBJPROP_ARROWCODE, 111);
            ObjectSetText(SYMBOL[k]+k+i+"Volume", DoubleToStr(MathAbs(iOpen(SYMBOL[k], TimeFrame_VOLUME, 0) - iClose(SYMBOL[k], TimeFrame_VOLUME, 0))/Point, 0), 8, "Terminal", VOLUME);
         }
      }
   }

   //Выводим Время до закрытия свечей текущей пары (символа)
   if(time == true)
   {
      M1  = NormalizeDouble(iTime(symbol, PERIOD_M1,  0), Digits);
      M5  = NormalizeDouble(iTime(symbol, PERIOD_M5,  0), Digits);
      M15 = NormalizeDouble(iTime(symbol, PERIOD_M15, 0), Digits);
      M30 = NormalizeDouble(iTime(symbol, PERIOD_M30, 0), Digits);
      H1  = NormalizeDouble(iTime(symbol, PERIOD_H1,  0), Digits);
      H4  = NormalizeDouble(iTime(symbol, PERIOD_H4,  0), Digits);
      D1  = NormalizeDouble(iTime(symbol, PERIOD_D1,  0), Digits);
      W1  = NormalizeDouble(iTime(symbol, PERIOD_W1,  0), Digits);
      MN1 = NormalizeDouble(iTime(symbol, PERIOD_MN1, 0), Digits);

      ObjectCreate(symbol+"_M1", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_M1", OBJPROP_XDISTANCE, 1090);
      ObjectSet(symbol+"_M1", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_M1", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_M1", "M1:...."+TimeToStr(MathAbs(M1+PERIOD_M1*60 - TimeCurrent()), TIME_SECONDS), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_M5", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_M5", OBJPROP_XDISTANCE, 960);
      ObjectSet(symbol+"_M5", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_M5", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_M5", "M5:...."+TimeToStr(MathAbs(M5+PERIOD_M5*60 - TimeCurrent()), TIME_SECONDS), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_M15", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_M15", OBJPROP_XDISTANCE, 830);
      ObjectSet(symbol+"_M15", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_M15", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_M15", "M15:..."+TimeToStr(MathAbs(M15+PERIOD_M15*60 - TimeCurrent()), TIME_SECONDS), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_M30", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_M30", OBJPROP_XDISTANCE, 700);
      ObjectSet(symbol+"_M30", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_M30", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_M30", "M30:..."+TimeToStr(MathAbs(M30+PERIOD_M30*60 - TimeCurrent()), TIME_SECONDS), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_H1", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_H1", OBJPROP_XDISTANCE, 570);
      ObjectSet(symbol+"_H1", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_H1", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_H1", "H1:...."+TimeToStr(MathAbs(H1+PERIOD_H1*60 - TimeCurrent()), TIME_SECONDS), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_H4", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_H4", OBJPROP_XDISTANCE, 440);
      ObjectSet(symbol+"_H4", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_H4", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_H4", "H4:...."+TimeToStr(MathAbs(H4+PERIOD_H4*60 - TimeCurrent()), TIME_SECONDS), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_D1", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_D1", OBJPROP_XDISTANCE, 310);
      ObjectSet(symbol+"_D1", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_D1", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_D1", "D1:...."+TimeToStr(MathAbs(D1+PERIOD_D1*60 - TimeCurrent()), TIME_SECONDS), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_W1", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_W1", OBJPROP_XDISTANCE, 180);
      ObjectSet(symbol+"_W1", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_W1", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_W1", "W1:...."+TIME_HOUR(MathAbs(W1+PERIOD_W1*60 - TimeCurrent())), 10, "Comic Sans", TIME);

      ObjectCreate(symbol+"_MN1", OBJ_LABEL, HandleWindow, 0, 0, 0, 0);
      ObjectSet(symbol+"_MN1", OBJPROP_XDISTANCE, 50);
      ObjectSet(symbol+"_MN1", OBJPROP_YDISTANCE, 0);
      ObjectSet(symbol+"_MN1", OBJPROP_CORNER, 1);
      ObjectSetText(symbol+"_MN1", "MN1:."+TIME_HOUR(MathAbs(MN1+PERIOD_MN1*60 - TimeCurrent())), 10, "Comic Sans", TIME);
   }
   return(0);
}


color COLOR_FUNK(double OPEN, double CLOSE)
{
   if(CLOSE >  OPEN)  return(UP);
   if(CLOSE <  OPEN)  return(DOWN);
   if(CLOSE == OPEN)  return(DOJI);
}

string TIME_HOUR(datetime time)
{
   string HOURS, MINUTES, SECONDS;
   HOURS    = DoubleToStr(MathFloor(time / 60 / 24), 0); if(StringLen(HOURS)   == 1)  HOURS   = "0"+HOURS;
   MINUTES  = DoubleToStr(MathMod(time / 60, 60), 0);    if(StringLen(MINUTES) == 1)  MINUTES = "0"+MINUTES;
   SECONDS  = DoubleToStr(MathMod(time, 60), 0);         if(StringLen(SECONDS) == 1)  SECONDS = "0"+SECONDS;
   return(HOURS+":"+MINUTES+":"+SECONDS);
}