//+------------------------------------------------------------------+
//|                                                     pos_size.mq4 |
//|                                       Copyright 2018, Silverapex |
//|                                         https://silverapex.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Silverapex"
#property link      "https://silverapex.co.uk"
#property version   "2.00"
#property strict
#property indicator_chart_window

input int               InpATRperiod=14;         // ATR Periods
input float             InpRisk=1;               // Risk Size %
input float             InpSLfactor=1.5;         // Stop Loss as a factor of ATR
input float             InpTPfactor=1.0;         // Take Profit as a factor of ATR
input int               InpFontSize=9;          // Font size
input color             InpColor=clrMagenta;     // Color
input int               InpBaseCorner=CORNER_RIGHT_UPPER;         // Base Corner 0=UL,1=UR,2=LL,3=LR
input float             InpFixedATR=0;           // Fixed ATR points
input bool              InpBack=false;           // Background object
input bool              InpSelection=false;      // Highlight to move
input bool              InpHidden=true;          // Hidden in the object list
input long              InpZOrder=0;             // Priority for mouse click

string AccntC=AccountCurrency();                   //Currency of Acount eg USD,GBP,EUR
string CounterC=StringSubstr(Symbol(),3,3);        //The Count Currency eg GBPUSD is USD
string ExC=AccntC+CounterC;                        //Create the Pair for account eg USDGBP
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   text_init(ChartID(),"textATR",5,InpFontSize,InpColor,InpFontSize);
   text_init(ChartID(),"textBAL",5,(InpFontSize+2)*2,InpColor,InpFontSize);
   text_init(ChartID(),"textRISK",5,(InpFontSize+2)*3,InpColor,InpFontSize);
   text_init(ChartID(),"texttimeleft",5,(InpFontSize+2)*4,InpColor,InpFontSize);
   text_init(ChartID(),"textBuySL",5,(InpFontSize+2)*5,InpColor,InpFontSize);
   text_init(ChartID(),"textBuyTP",5,(InpFontSize+2)*6,InpColor,InpFontSize);
   text_init(ChartID(),"textSellSL",5,(InpFontSize+2)*7,InpColor,InpFontSize);
   text_init(ChartID(),"textSellTP",5,(InpFontSize+2)*8,InpColor,InpFontSize);
   text_init(ChartID(),"textlotsize",5,(InpFontSize+2)*9,InpColor,InpFontSize);


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
//---
   double ExCRate=1;                                            //Assume Account is same as counter so ExCRate=1
   AccntC=AccountCurrency();                                      //Currency of Acount eg USD,GBP,EUR
   CounterC=StringSubstr(Symbol(),3,3);                           //The Count Currency eg GBPUSD is USD
   ExC=AccntC+CounterC;                                           //Create the Pair for account eg USDGBP
   if(AccntC!=CounterC)
      ExCRate= MarketInfo(ExC,MODE_ASK);                          //Get the correct FX rate for the Account to Counter conversion
   if(ExCRate ==0) ExCRate=1.0;
   double ATRPoints=iATR(NULL,0,InpATRperiod,0);                  //Get the ATR in points to calc SL and TP
   if(InpFixedATR!=0)
      ATRPoints=InpFixedATR;                                      //Override ATR for times when you have had a Flash crash
   double riskVAccntC=AccountEquity()*(InpRisk/100);
   double riskvalue=(ExCRate/1)*riskVAccntC;                      //Risk in Account Currency
   double slpoints=(ATRPoints*InpSLfactor);                      //Risk in Counter Currency
   double riskperpoint=(riskvalue/slpoints)*Point;
   double lotSize=riskperpoint;                                  //Risk in currency per point
   int pipMult=10000;
   if(CounterC=="JPY") {
      lotSize=riskperpoint/100;
      pipMult=100;
   }
   double ATRpips=MathCeil(pipMult*ATRPoints);

//calculate time left this period
   int thisbarminutes=Period();
   double thisbarseconds=thisbarminutes*60;
   double seconds=thisbarseconds -(TimeCurrent()-Time[0]); // seconds left in bar 

   double minutes= MathFloor(seconds/60);
   double hours  = MathFloor(seconds/3600);

   minutes = minutes -  hours*60;
   seconds = seconds - minutes*60 - hours*3600;


   string sText=DoubleToStr(seconds,0);
   if(StringLen(sText)<2) sText="0"+sText;
   string mText=DoubleToStr(minutes,0);
   if(StringLen(mText)<2) mText="0"+mText;
   string hText=DoubleToStr(hours,0);
   if(StringLen(hText)<2) hText="0"+hText;

   if(Period()<240) ObjectSetString(ChartID(),"texttimeleft",OBJPROP_TEXT,"Time Left:"+mText+":"+sText);
   else ObjectSetString(ChartID(),"texttimeleft",OBJPROP_TEXT,"Time Left:"+hText+":"+mText+":"+sText);

   if(InpFixedATR!=0)ObjectSetString(ChartID(),"textATR",OBJPROP_TEXT,StringFormat("*FIXED*ATR(%.0f):%.0f %s", InpATRperiod,ATRpips,"pips"));
   else ObjectSetString(ChartID(),"textATR",OBJPROP_TEXT,StringFormat("ATR(%.0f):%.0f %s", InpATRperiod,ATRpips,"pips"));
   ObjectSetString(ChartID(),"textBAL",OBJPROP_TEXT,StringFormat("Equity:%.2f%s",AccountEquity(),AccntC));
   ObjectSetString(ChartID(),"textRISK",OBJPROP_TEXT,StringFormat("Risk %.1f%%:%.0f %s",InpRisk,riskVAccntC,AccntC));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textBuySL",OBJPROP_TEXT,StringFormat("Buy SL:%.2f",Ask-(ATRPoints*InpSLfactor)));
   else ObjectSetString(ChartID(),"textBuySL",OBJPROP_TEXT,StringFormat("Buy SL:%.4f",Ask-(ATRPoints*InpSLfactor)));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textBuyTP",OBJPROP_TEXT,StringFormat("Buy TP:%.2f",Ask+(ATRPoints*InpTPfactor)));
   else ObjectSetString(ChartID(),"textBuyTP",OBJPROP_TEXT,StringFormat("Buy TP:%.4f",Ask+(ATRPoints*InpTPfactor)));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textSellSL",OBJPROP_TEXT,StringFormat("Sell SL:%.2f",Ask+(ATRPoints*InpSLfactor)));
   else ObjectSetString(ChartID(),"textSellSL",OBJPROP_TEXT,StringFormat("Sell SL:%.4f",Ask+(ATRPoints*InpSLfactor)));
   if (CounterC=="JPY") ObjectSetString(ChartID(),"textSellTP",OBJPROP_TEXT,StringFormat("Sell TP:%.2f",Ask-(ATRPoints*InpTPfactor)));
   else ObjectSetString(ChartID(),"textSellTP",OBJPROP_TEXT,StringFormat("Sell TP:%.4f",Ask-(ATRPoints*InpTPfactor)));
   ObjectSetString(ChartID(),"textlotsize",OBJPROP_TEXT,StringFormat("Volume:%.2f",lotSize));

//--- forced chart redraw
   ChartRedraw(ChartID());

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("textATR");
   ObjectDelete("textBAL");
   ObjectDelete("textRISK");
   ObjectDelete("texttimeleft");
   ObjectDelete("textBuySL");
   ObjectDelete("textBuyTP");
   ObjectDelete("textSellSL");
   ObjectDelete("textSellTP");
   ObjectDelete("textlotsize");
  }
//Function to create a text field in the main Window
// Example call --- text_init(ChartID(),"textATR",1000,30,clrRed,12);
int text_init(const long current_chart_id,const string obj_label,const int x_dist,const int y_dist,const int text_color,const int font_size)
  {

//--- creating label object (it does not have time/price coordinates)
   if(!ObjectCreate(current_chart_id,obj_label,OBJ_LABEL,0,0,0))
     {
      Print("Error: can't create label! code #",GetLastError());
      return(0);
     }
//--- set distance property
   ObjectSet(obj_label,OBJPROP_CORNER,InpBaseCorner);
   ObjectSet(obj_label,OBJPROP_XDISTANCE,x_dist);
   ObjectSet(obj_label,OBJPROP_YDISTANCE,y_dist);
   ObjectSetInteger(current_chart_id,obj_label,OBJPROP_COLOR,text_color);
   ObjectSet(obj_label,OBJPROP_FONTSIZE,font_size);
   return(0);
  }
//+------------------------------------------------------------------+
