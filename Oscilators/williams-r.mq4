//+------------------------------------------------------------------+
//|                                                   williams-r.mq4 |
//|        ©2011 Best-metatrader-indicators.com. All rights reserved |
//|                        http://www.best-metatrader-indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011 Best-metatrader-indicators.com."
#property link      "http://www.best-metatrader-indicators.com"
//----
#property indicator_separate_window
#property indicator_minimum -100
#property indicator_maximum 0
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
#property indicator_level1 -20
#property indicator_level2 -80
//---- input parameters
extern int ExtWPRPeriod = 14;
//---- buffers
double ExtWPRBuffer[];
string Copyright="\xA9 WWW.BEST-METATRADER-INDICATORS.COM";  
string MPrefix="FI";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string sShortName;
//---- indicator buffer mapping
   SetIndexBuffer(0, ExtWPRBuffer);
//---- indicator line
   SetIndexStyle(0, DRAW_LINE);
//---- name for DataWindow and indicator subwindow label
   sShortName="%R(" + ExtWPRPeriod + ")";
   IndicatorShortName(sShortName);
   SetIndexLabel(0, sShortName);
//---- first values aren't drawn
   SetIndexDrawBegin(0, ExtWPRPeriod);
//----
   DL("001", Copyright, 5, 20,Gold,"Arial",10,0); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ClearObjects(); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i, nLimit, nCountedBars;  
//---- insufficient data
   if(Bars <= ExtWPRPeriod) 
       return(0);
//---- bars count that does not changed after last indicator launch.
   nCountedBars = IndicatorCounted();
//----Williams’ Percent Range calculation
   i = Bars - ExtWPRPeriod - 1;
   if(nCountedBars > ExtWPRPeriod) 
       i = Bars - nCountedBars - 1;  
   while(i >= 0)
     {
       double dMaxHigh = High[Highest(NULL, 0, MODE_HIGH, ExtWPRPeriod, i)];
       double dMinLow = Low[Lowest(NULL, 0, MODE_LOW, ExtWPRPeriod, i)];      
       if(!CompareDouble((dMaxHigh - dMinLow), 0.0))
           ExtWPRBuffer[i] = -100*(dMaxHigh - Close[i]) / (dMaxHigh - dMinLow);
       i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| CompareDouble function                                           |
//+------------------------------------------------------------------+
bool CompareDouble(double Number1, double Number2)
  {
    bool Compare = NormalizeDouble(Number1 - Number2, 8) == 0;
    return(Compare);
  } 
//+------------------------------------------------------------------+
//| DL function                                                      |
//+------------------------------------------------------------------+
 void DL(string label, string text, int x, int y, color clr, string FontName = "Arial",int FontSize = 12, int typeCorner = 1)
 
{
   string labelIndicator = MPrefix + label;   
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
  }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, y);
   ObjectSetText(labelIndicator, text, FontSize, FontName, clr);
  
}  

//+------------------------------------------------------------------+
//| ClearObjects function                                            |
//+------------------------------------------------------------------+
void ClearObjects() 
{ 
  for(int i=0;i<ObjectsTotal();i++) 
  if(StringFind(ObjectName(i),MPrefix)==0) { ObjectDelete(ObjectName(i)); i--; } 
}
//+------------------------------------------------------------------+