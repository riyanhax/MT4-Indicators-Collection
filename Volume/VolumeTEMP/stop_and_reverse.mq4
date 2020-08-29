//+------------------------------------------------------------------+
//|                                             stop_and_reverse.mq4 |
//|                      Copyright © 2008, Silas Palmer.             |
//|                                      http://www.silaspalmer.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Silas Palmer."
#property link      "http://www.silaspalmer.com"
#include <stderror.mqh>
#include <stdlib.mqh>

// #property show_confirm
// Uncomment to enable confirmation

//+------------------------------------------------------------------+
//| script "close all orders on a chart, place one in opposite direction to last opened order"     |
//+------------------------------------------------------------------+
int start()
  {
   // Change these amounts to suit your needs
   
   int lotbucks = 50000; // 1 lot for every x dollars in your account. 
   int Slippage = 3; // Standard amount
   
   // Note script auto-detects minimum lot size
   // It also automatically scales lots based on currency pair 
   // (so that a 1 pip move will be $1 per lotbuck regardless of the pair chosen)
   
//----
   int cmd = -1; // Nothing (buy=0 sell=1)
   int i;
   double lots,minl,maxl,pipbucks,step; 
   
   // Calculate lots
   pipbucks = MarketInfo(Symbol(),MODE_TICKVALUE);
   minl = MarketInfo(Symbol(),MODE_MINLOT);
   maxl = MarketInfo(Symbol(),MODE_MAXLOT);
   step = MarketInfo(Symbol(),MODE_LOTSTEP);
   // Scale lots so 1 pip = $1 at 1 lot

   lots = MathFloor( (((10 / pipbucks) * AccountFreeMargin()) / lotbucks) / step) * step;
   if (lots < minl) lots = minl;
   if (lots > maxl) lots = maxl;    

   for ( i=0; i<OrdersTotal(); i++ ) // Loop through orders
       if ( OrderSelect ( i, SELECT_BY_POS, MODE_TRADES ) ) {
         if ( OrderSymbol() == Symbol() ) {
            if (OrderType() == OP_BUY) {
               cmd = OP_SELL; // sell
               // Close buy Order
               OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Blue);
               }
            if (OrderType() == OP_SELL ) {
               cmd = OP_BUY; // buy         
               // Close sell order 
               OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Blue);             
               }
            }
         }
      
   if(cmd==OP_BUY) {
      // buy  
      if ( OrderSend( Symbol(), OP_BUY, lots, Ask, Slippage, 0, 0, "Opened Buy Order", 0, 0, Orange ) > 0 )
         Print ( "Opened Buy Order at ", Ask );
      else 
         Alert ( "Could not open Buy order for ", Symbol(), " ", lots, " at ", Ask, " Error=", ErrorDescription(GetLastError()) );
      }   
   if (cmd==OP_SELL) {
      // sell
      if ( OrderSend( Symbol(), OP_SELL, lots, Bid, Slippage, 0, 0, "Opened Buy Order", 0, 0, Yellow ) > 0 )
         Print ( "Opened Sell Order at ",Bid );
      else 
         Alert ( "Could not open Sell order for ", Symbol(), " ", lots, " at ", Bid, " Error=", ErrorDescription(GetLastError()) );  
      }
   
   if (cmd==-1) {
      Alert ( "Cannot stop and reverse. No orders open.");
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+