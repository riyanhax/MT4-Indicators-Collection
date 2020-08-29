//+------------------------------------------------------------------+
//|                                                  SpikeTrader.mq4 |
//|                                                    Andriy Moraru |
//|                                         http://www.earnforex.com |
//|            							                            2012 |
//+------------------------------------------------------------------+
#property copyright "www.EarnForex.com, 2012"
#property link      "http://www.earnforex.com"

/*
   Trades on spikes that are:
   1) Higher/lower than N preceding bars;
   2) Higher/lower than the previous bar by X percent;
   3) Close in bottom or upper third/half of the bar.
*/

extern double Lots      = 0.1;
extern int Slippage     = 30;

extern int Hold          = 11;
extern int BarsNumber    = 3;
extern double PercentageDifference   = 0.003;
extern double ThirdOrHalf = 0.5;

extern int Magic = 173923183;

int LastBars = 0;
int Timer = 0;

//+------------------------------------------------------------------+
//| Expert Every Tick Function                                       |
//+------------------------------------------------------------------+
int start()
{
	if (IsTradeAllowed() == false) return(0);
	
   //Wait for the new Bar in a chart.
	if (LastBars == Bars) return(0);
	else LastBars = Bars;

   if (Timer == 1) ClosePrev();
   if (Timer > 0) Timer--;

   CheckEntry();	
   
	return(0);
}

//+------------------------------------------------------------------+
//| Check for entry conditions                                       |
//+------------------------------------------------------------------+
void CheckEntry()
{
   if (CheckSellEntry())
   {
      // If found BUY order - close it and open SELL. Otherwise only reset timer.
      if (ClosePrev(OP_SELL)) fSell();
      Timer = Hold;
   }
   else if (CheckBuyEntry())
   {
      // If found SELL order - close it and open BUY. Otherwise only reset timer.
      if (ClosePrev(OP_BUY)) fBuy();
      Timer = Hold;
   }
}

bool CheckSellEntry()
{
   if (High[1] - Low[1] == 0) return(false);
   
   // If the bar isn't higher than at least one of the previous bars - return false.
   for (int i = 2; i < BarsNumber + 2; i++)
      if (High[1] <= High[i]) return(false);

   // If not higher than the previous bar by required percentage difference - return false.
   if ((High[1] - High[2]) / High[2] < PercentageDifference) return(false);
   // If closed above the lower third/half - return false.
   if ((Close[1] - Low[1]) / (High[1] - Low[1]) > ThirdOrHalf) return(false);
   
   return(true);
}

bool CheckBuyEntry()
{
   if (High[1] - Low[1] == 0) return(false);
   
   // If the bar isn't lower than at least one of the previous bars - return false.
   for (int i = 2; i < BarsNumber + 2; i++)
      if (Low[1] >= Low[i]) return(false);

   // If not lower than the previous bar by required percentage difference - return false.
   if ((Low[2] - Low[1]) / Low[2] < PercentageDifference) return(false);
   // If closed below the upper third/half - return false.
   if ((High[1] - Close[1]) / (High[1] - Low[1]) > ThirdOrHalf) return(false);
   
   return(true);
}


//+------------------------------------------------------------------+
//| Close previous position                                          |
//+------------------------------------------------------------------+
bool ClosePrev(int order_type = -1)
{
   int total = OrdersTotal();
   for (int i = 0; i < total; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS) == false) continue;
      if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic))
      {
         if (OrderType() == OP_BUY)
         {
            if (order_type == OP_BUY) return(false);
            RefreshRates();
            OrderClose(OrderTicket(), OrderLots(), Bid, Slippage);
            return(true);
         }
         else if (OrderType() == OP_SELL)
         {
            if (order_type == OP_SELL) return(false);
            RefreshRates();
            OrderClose(OrderTicket(), OrderLots(), Ask, Slippage);
            return(true);
         }
      }
   }
   return(true);
}

//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
int fSell()
{
	RefreshRates();
	int result = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "Adjustable MA", Magic);
	if (result == -1)
	{
		int e = GetLastError();
		Print(e);
	}
	else return(result);
	return(0);
}

//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
int fBuy()
{
	RefreshRates();
	int result = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "Adjustable MA", Magic);
	if (result == -1)
	{
		int e = GetLastError();
		Print(e);
	}
	else return(result);
	return(0);
}
//+------------------------------------------------------------------+

