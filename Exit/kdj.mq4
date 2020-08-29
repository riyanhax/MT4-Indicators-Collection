//+------------------------------------------------------------------+
//|                                                          KDJ.mq4 |
//|                                     Copyright? 2009, Walter Choy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright? 2009, Walter Choy"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_level1 0
#property indicator_level2 20
#property indicator_level3 80
#property indicator_level4 100

//---- input parameters
extern int       nPeriod=9;
extern double    factor_1=0.6666666;
extern double    factor_2=0.3333333;
//---- buffers
double percentK[];
double percentD[];
double percentJ[];
double RSV[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,percentK);
   SetIndexLabel(0, "%K");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,percentD);
   SetIndexLabel(1, "%D");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,percentJ);
   SetIndexLabel(2, "%J");
   SetIndexBuffer(3,RSV);
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
//----
   int i, k, num;
   double Ln, Hn, Cn;
//----
   i = Bars - counted_bars - 1;
   num = Bars - nPeriod;
   
   while(i>=0)
     {
         Cn = iClose(NULL,0,i); Ln = iClose(NULL,0,i); Hn = iClose(NULL,0,i);
         for(k=0; k<nPeriod; k++){
            if (Ln > iLow(NULL,0,i+k)) Ln = iLow(NULL,0,i+k);
            if (Hn < iHigh(NULL,0,i+k)) Hn = iHigh(NULL,0,i+k);
         }

         if (Hn-Ln != 0) RSV[i] = (Cn-Ln)/(Hn-Ln)*100; else RSV[i] = 50;

         if (i >= num) {
            percentK[i] = factor_1 * 50 + factor_2 * RSV[i];
            percentD[i] = factor_1 * 50 + factor_2 * percentK[i];
         } else {
            percentK[i] = factor_1 * percentK[i+1] + factor_2 * RSV[i];
            percentD[i] = factor_1 * percentD[i+1] + factor_2 * percentK[i];
         }
         percentJ[i] = 3 * percentD[i] - 2 * percentK[i];
       i--;
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+