//+------------------------------------------------------------------+
//|                                                  SMI_Correct.mq4 |
//|                                      re-write by transport_david |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 White
//----
#property indicator_maximum 100
#property indicator_minimum -100
//----
#property indicator_level1 50
#property indicator_level2 0
#property indicator_level3 -50
//---- input parameters
// MetaStock uses H/L (13) , 1st EMA(25) , 2nd EMA(2) , no signal line
// fmlabs does not recommend any settings
extern int Period_Q= 13; // HH LL
extern int Period_R= 25; // 1st EMA
extern int Period_S=  2; // 2nd EMA
extern int Signal=5; // Signal EMA
extern int ShowBars=1000;
//---- buffers
double SMI_Buffer[];
double Signal_Buffer[];
double SM_Buffer[];
double EMA_SM[];
double EMA2_SM[];
double EMA_HQ[];
double EMA2_HQ[];
double HQ_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Signal_Buffer);
   SetIndexLabel(0,"Signal SMI");
   //
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SMI_Buffer);
   SetIndexLabel(1,"SMI");
   //
   SetIndexEmptyValue(2,0.0);
   SetIndexBuffer(2,SM_Buffer);
   SetIndexStyle(2,DRAW_NONE);
   //
   SetIndexEmptyValue(3,0.0);
   SetIndexBuffer(3,EMA_SM);
   SetIndexStyle(3,DRAW_NONE);
   //
   SetIndexEmptyValue(4,0.0);
   SetIndexBuffer(4,EMA2_SM);
   SetIndexStyle(4,DRAW_NONE);
   //
   SetIndexEmptyValue(5,0.0);
   SetIndexBuffer(5,EMA_HQ);
   SetIndexStyle(5,DRAW_NONE);
   //
   SetIndexEmptyValue(6,0.0);
   SetIndexBuffer(6,EMA2_HQ);
   SetIndexStyle(6,DRAW_NONE);
   //
   SetIndexEmptyValue(7,0.0);
   SetIndexBuffer(7,HQ_Buffer);
   SetIndexStyle(7,DRAW_NONE);
   IndicatorShortName("SMI_Correct("+Period_Q+","+Period_R+","+Period_S+","+Signal+")");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int i;
//----
   limit=ShowBars;
   if (limit>=Bars - 1) limit=Bars - 1;
   for(i=limit;i>=0;i--)
     {                                                                                                                         // found at http://www.fmlabs.com/reference/default.htm?url=SMI.htm
      //                      highesthigh - lowestlow
      SM_Buffer[i]=Close[i]-((High[iHighest(Symbol(),0,MODE_HIGH,Period_Q,i)]+Low[iLowest(Symbol(),0,MODE_LOW,Period_Q,i)])/2); // SM_Buffer = Close - -------------------------
      //                                 2
      HQ_Buffer[i]=High[iHighest(Symbol(),0,MODE_HIGH,Period_Q,i)]-Low[iLowest(Symbol(),0,MODE_LOW,Period_Q,i)];                // HQ_Buffer = highesthigh - lowestlow
     }
   for(i=limit-Period_R;i>=0;i--)
     {
      EMA_SM[i]=iMAOnArray(SM_Buffer,0,Period_R,0,MODE_EMA,i);                                                                  // EMA_SM = EMA(SM_Buffer)
      EMA_HQ[i]=iMAOnArray(HQ_Buffer,0,Period_R,0,MODE_EMA,i);                                                                  // EMA_HQ = EMA(HQ_Buffer)
     }
   for(i=limit-Period_R-Period_S;i>=0;i--)
     {
      EMA2_SM[i]=iMAOnArray(EMA_SM,0,Period_S,0,MODE_EMA,i);                                                                    // EMA2_SM = EMA(EMA(SM_Buffer))
      EMA2_HQ[i]=iMAOnArray(EMA_HQ,0,Period_S,0,MODE_EMA,i);                                                                    // EMA2_HQ = EMA(EMA(HQ_Buffer))
     }
   for(i=limit-Period_R-Period_S-Signal;i>=0;i--)
     {                                                                                                                         //                  EMA2_SM
      SMI_Buffer[i]=100*(EMA2_SM[i]/(EMA2_HQ[i]/2));                                                                            // SMI = 100 x ( ------------- )
     }                                                                                                                         //                EMA2_HQ / 2
   for(i=limit-Period_R-Period_S;i>=0;i--)
     {
      Signal_Buffer[i]=iMAOnArray(SMI_Buffer,0,Signal,0,MODE_EMA,i);                                                            // Signal_Buffer = EMA(SMI_Buffer)
     }
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+