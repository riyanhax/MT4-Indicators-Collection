//+-------------------+
//| V1+V2_v4.mq4 |
//+-------------------+                                                         

#property copyright "Bolla 2007"
#property link      "http://www.forex-tsd.com/"

#include <stdlib.mqh>



extern double MinFreeMarginPct= 50;


//inputs esterni
extern double TakeProfitLong     = 27;
extern double TakeProfitShort    = 27;
extern int     DLong             = 20;
extern int     DShort            = 20;
extern double Multiplier         = 2;
extern int    MaxTrades          = 8;
extern int    Slippage           = 3;
extern bool   UseSound           = false;

//variabili globali
string  Name_Expert    = "V1+V2_v4";
double  stopLossB      = 0; 
double  stopLossS      = 0; 
string  NameFileSound  = "alert.wav";
double  InitLots       = 0.01;
double  MaxLot         = 2.56;
int     SL             = 0;
double  sB=0,sS=0;
int c,j;
double LotsB,LotsS,Long,Short;
double LastB=0,LastS=1000; 
extern int     MagicLong=800111;
extern int     MagicShort=800222;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {

  return(0);
  }

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  return(0);
  }

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()

   {
   
   if(Bars<1)   {Print("bars less than 1");return(0);}
   
   double   Price=iClose(NULL,0,0);
   
   if (!ExistPositions()) {sB=0; sS=0;}
   int T=0;
   int B=0;  
   for(int i=0;i<OrdersTotal();i++) 
      { 
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderComment()==Name_Expert)   
        { 
        int type=OrderType();
        switch(type)
           {
           case OP_BUY:
              sB=1;
              T++;
              LastB=OrderOpenPrice();
              break;
           case OP_SELL:
              sS=2;
              B++;
              LastS=OrderOpenPrice();
              break;
           }
        }    
      }



   LotsB=InitLots;
   LotsS=InitLots;
   LotsB=MathFloor(LotsB*100)/100;
   LotsS=MathFloor(LotsS*100)/100;
   if (LotsB<0.01) LotsB=0.01;
   if (LotsS<0.01) LotsS=0.01;


   for (j=0;j<T;j++) {LotsB=Multiplier*LotsB;}
   for (j=0;j<B;j++) {LotsS=Multiplier*LotsS;}

   if (AccountBalance()>10000) MaxLot=25.6;
   if (LotsB>MaxLot) LotsB=MaxLot; 
   if (LotsS>MaxLot) LotsS=MaxLot; 
   if (LotsB>2.56) LotsB=0.1; 
   if (LotsS>2.56) LotsS=0.1; 


   if (T==0) { Long=1000;}
   if (B==0) {Short=-1000;}
   if ((T>0)||(B>0))
      {
      if ((sB==1)&&(Long>LastB)) Long=LastB;
      if ((sS==2)&&(Short<LastS)) Short=LastS;
      }

   if ((T==MaxTrades)||(B==MaxTrades)) c=1;
   if ((T==0)||(B==0)) c=0;


   double spread=(Ask-Bid)/Point;

   if ((sB==0)&&(c==0))  {OpenBuy();sB=1;} 
   if ((sS==0)&&(c==0))  {OpenSell();sS=2;}   

   if ((T<MaxTrades)&&(B<MaxTrades))
      {
      if ((sB==1)&&(Price<=(LastB-(DLong+spread)*Point))&&(c==0))   {OpenBuy();sB=1;return(0);}
      if ((sS==2)&&(Price>=(LastS+(DShort)*Point))&&(c==0))         {OpenSell();sS=2;return(0);}
      if ((sB==1)&&(Price>=(Long+TakeProfitLong*Point))&&(AccountProfit()>0))          {closeAllOrders(0);sB=0;return(0);}
      if ((sS==2)&&(Price<=(Short-(TakeProfitShort+spread)*Point))&&(AccountProfit()>0)) {closeAllOrders(1);sS=0;return(0);} 
      }
  return (0);
}


// - - - - - - FUNZIONI - - - - - - -


 

bool ExistPositions()
   {
   for(int i=0;i<OrdersTotal(); i++)
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderComment()==Name_Expert) return(True);
         else return(false);
      }   
}

void OpenBuy()
   { 
   double ldLot, ldStop, ldTake; 
   string lsComm; 
   ldLot = GetSizeLotB(); 
    if (stopLossB==0) { ldStop=0; }
	else {ldStop = Bid+Point*stopLossB; }
   ldTake = NormalizeDouble(GetTakeProfitBuy(),Digits); 
   lsComm = GetCommentForOrder();
   
 
   if (AccountFreeMargin()< (AccountBalance()*(MinFreeMarginPct/100))){
   Print("Cannot Trade Because the Margin is Lower Than ",MinFreeMarginPct,"%");}

   OrderSend(Symbol(),OP_BUY,ldLot,NormalizeDouble(Ask,Digits),Slippage,ldStop,ldTake,lsComm,MagicLong,0,NULL);

   if (UseSound) PlaySound(NameFileSound);
   
}
 
void OpenSell()
   { 
   double ldLot, ldStop, ldTake; 
   string lsComm; 
   ldLot = GetSizeLotS();
   if (stopLossS==0) { ldStop=0; }
	else {ldStop = Bid+Point*stopLossS; }
   ldTake = NormalizeDouble(GetTakeProfitSell(),Digits); 
   lsComm = GetCommentForOrder();
   
   
   if (AccountFreeMargin()< (AccountBalance()*(MinFreeMarginPct/100))){
   Print("Cannot Trade Because the Margin is Lower Than ",MinFreeMarginPct,"%");}
   
   OrderSend(Symbol(),OP_SELL,ldLot,NormalizeDouble(Bid,Digits),Slippage,ldStop,ldTake,lsComm,MagicShort,0,NULL); 

   if (UseSound) PlaySound(NameFileSound);
   
}

void closeAllOrders(int type)
   {
   for(int c=0;c<OrdersTotal();c++)
      {
      OrderSelect(c,SELECT_BY_POS,MODE_TRADES); 
      if (OrderSymbol()==Symbol() && OrderComment()==Name_Expert && OrderType()==OP_BUY && type==0)
         {
         OrderClose(OrderTicket(), OrderLots(), Bid,Slippage, White);
         }
      if (OrderSymbol()==Symbol() && OrderComment()==Name_Expert && OrderType()==OP_SELL && type==1)
         {
         OrderClose(OrderTicket(), OrderLots(), Ask,Slippage, White);
         }   
      if (OrderSymbol()==Symbol() && OrderComment()==Name_Expert && OrderType() > 1)  {OrderDelete(OrderTicket());
      }
   }
} 




string GetCommentForOrder() {return(Name_Expert);} 
double GetSizeLotB() {return(LotsB);} 
double GetSizeLotS() {return(LotsS);} 
double GetTakeProfitBuy() {return(Ask+TakeProfitLong*Point);} 
double GetTakeProfitSell() {return(Bid-TakeProfitShort*Point);} 


