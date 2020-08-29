//+------------------------------------------------------------------+
//|                                                      STOPLEVEL.mq4 |
//|                                                     Tokman Yuriy |
//|  29 окт€бр€ 2008 года                      yuriytokman@gmail.com |
//|                                            ICQ#:481-971-287      |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   ObjectCreate("yuriytokman@gmail.com",OBJ_HLINE,0,0,0);
   ObjectCreate("ICQ#:481-971-287",OBJ_HLINE,0,0,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete ("yuriytokman@gmail.com");
   ObjectDelete ("ICQ#:481-971-287");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {        
    ObjectSet("yuriytokman@gmail.com",OBJPROP_PRICE1,Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point);
    ObjectSet("ICQ#:481-971-287",OBJPROP_PRICE1,Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point);                       
//----
   return(0);
  }
//+------------------------------------------------------------------+