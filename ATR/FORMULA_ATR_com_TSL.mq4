//+------------------------------------------------------------------+
//|                                              No Nonsense ATR.mq4 |
//|                   rpsreal Copyright 2019, rpsreal Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict
#property copyright "DxVena"
#property description "No Nonsense ATR"

//---- input parameters
extern int        ATR_TP_PERIOD        = 14;       
extern double     ATR_TP_MULTIPLIER    = 2.5;
extern int        ATR_SL_PERIOD        = 14;       
extern double     ATR_SL_MULTIPLIER    = 1.0;
extern char       ATR_SHIFT            = 0; 
extern int        ATR_digits           = 0;
extern char       text_corner          = 0;
extern int        text_size            = 12;
extern color      text_color           = Gold;  

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
   ObjectCreate("ATR_text", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ATR_text"," No Nonsense ATR",text_size, "Verdana", text_color);
   ObjectSet("ATR_text", OBJPROP_CORNER, text_corner);
   ObjectSet("ATR_text", OBJPROP_XDISTANCE, 0);
   ObjectSet("ATR_text", OBJPROP_YDISTANCE, 20);
   return(INIT_SUCCEEDED);
}
 
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){
   ObjectDelete("ATR_text"); // apagar objeto
   return(0);
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
//---
    double SL, TP;
    string text;
    
    
    TP=((iATR(NULL,0,ATR_TP_PERIOD,ATR_SHIFT)/Point)/10)*ATR_TP_MULTIPLIER;
    SL=((iATR(NULL,0,ATR_SL_PERIOD,ATR_SHIFT)/Point)/10)*ATR_SL_MULTIPLIER;
    
    text=StringConcatenate("\n ATR pips = ",  NormalizeDouble(SL,ATR_digits),  "   ",  "Trailing SL = ",  NormalizeDouble(TP,ATR_digits));  
    ObjectSetText("ATR_text",text,text_size, "Verdana", text_color);
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
