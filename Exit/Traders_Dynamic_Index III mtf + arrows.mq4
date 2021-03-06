//+------------------------------------------------------------------+
//|                                    Traders Dynamic Index.mq4     |
//|                                    Copyright © 2006, Dean Malone |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//|                     Traders Dynamic Index                        |
//|                                                                  |
//|  This hybrid indicator is developed to assist traders in their   |
//|  ability to decipher and monitor market conditions related to    |
//|  trend direction, market strength, and market volatility.        |
//|                                                                  | 
//|  Even though comprehensive, the T.D.I. is easy to read and use.  |
//|                                                                  |
//|  Green line = RSI Price line                                     |
//|  Red line = Trade Signal line                                    |
//|  Blue lines = Volatility Band                                    | 
//|  Yellow line = Market Base Line                                  |  
//|                                                                  |
//|  Trend Direction - Immediate and Overall                         |
//|   Immediate = Green over Red...price action is moving up.        |
//|               Red over Green...price action is moving down.      |
//|                                                                  |   
//|   Overall = Yellow line trends up and down generally between the |
//|             lines 32 & 68. Watch for Yellow line to bounces off  |
//|             these lines for market reversal. Trade long when     |
//|             price is above the Yellow line, and trade short when |
//|             price is below.                                      |        
//|                                                                  |
//|  Market Strength & Volatility - Immediate and Overall            |
//|   Immediate = Green Line - Strong = Steep slope up or down.      | 
//|                            Weak = Moderate to Flat slope.        |
//|                                                                  |               
//|   Overall = Blue Lines - When expanding, market is strong and    |
//|             trending. When constricting, market is weak and      |
//|             in a range. When the Blue lines are extremely tight  |                                                       
//|             in a narrow range, expect an economic announcement   | 
//|             or other market condition to spike the market.       |
//|                                                                  |               
//|                                                                  |
//|  Entry conditions                                                |
//|   Scalping  - Long = Green over Red, Short = Red over Green      |
//|   Active - Long = Green over Red & Yellow lines                  |
//|            Short = Red over Green & Yellow lines                 |    
//|   Moderate - Long = Green over Red, Yellow, & 50 lines           |
//|              Short= Red over Green, Green below Yellow & 50 line |
//|                                                                  |
//|  Exit conditions*                                                |   
//|   Long = Green crosses below Red                                 |
//|   Short = Green crosses above Red                                |
//|   * If Green crosses either Blue lines, consider exiting when    |
//|     when the Green line crosses back over the Blue line.         |
//|                                                                  |
//|                                                                  |
//|  IMPORTANT: The default settings are well tested and proven.     |
//|             But, you can change the settings to fit your         |
//|             trading style.                                       |
//|                                                                  |
//|                                                                  |
//|  Price & Line Type settings:                           |                
//|   RSI Price settings                                             |               
//|   0 = Close price     [DEFAULT]                                  |               
//|   1 = Open price.                                                |               
//|   2 = High price.                                                |               
//|   3 = Low price.                                                 |               
//|   4 = Median price, (high+low)/2.                                |               
//|   5 = Typical price, (high+low+close)/3.                         |               
//|   6 = Weighted close price, (high+low+close+close)/4.            |               
//|                                                                  |               
//|   RSI Price Line & Signal Line Type settings                                   |               
//|   0 = Simple moving average       [DEFAULT]                      |               
//|   1 = Exponential moving average                                 |               
//|   2 = Smoothed moving average                                    |               
//|   3 = Linear weighted moving average                             |               
//|                                                                  |
//|   Good trading,                                                  |   
//|                                                                  |
//|   Dean                                                           |                              
//+------------------------------------------------------------------+



#property indicator_buffers 7
#property indicator_color1 Black
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrDarkGray
#property indicator_color4 clrDodgerBlue
#property indicator_color5 C'105,155,197'
#property indicator_color6 C'45,176,45'
#property indicator_color7 clrOrangeRed
#property indicator_separate_window

extern ENUM_TIMEFRAMES    TimeFrame          = PERIOD_CURRENT;    // Time frame to use
extern int                RSI_Period         = 10;         //8-25
extern ENUM_APPLIED_PRICE RSI_Price          = 5;           //0-6
extern int                Volatility_Band    = 34;    //20-40
extern int                RSI_Price_Line     = 3;      
extern ENUM_MA_METHOD     RSI_Price_Type     = MODE_EMA;      //0-3
extern int                Trade_Signal_Line  = 7;   
extern ENUM_MA_METHOD     Trade_Signal_Type  = MODE_SMA;
extern int                Trade_Signal_Line2 = 20;   
extern ENUM_MA_METHOD     Trade_Signal_Type2 = MODE_SMMA;   //0-3
input bool                arrowsVisible      = false;             // Arrows visible true/false?
input bool                arrowsOnNewest     = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string              arrowsIdentifier   = "tdi Arrows1";     // Unique ID for arrows
input double              arrowsUpperGap     = 1.0;               // Upper arrow gap
input double              arrowsLowerGap     = 1.0;               // Lower arrow gap
input color               arrowsUpColor      = clrBlue;           // Up arrow color
input color               arrowsDnColor      = clrCrimson;        // Down arrow color
input int                 arrowsUpCode       = 221;               // Up arrow code
input int                 arrowsDnCode       = 222;               // Down arrow code
input int                 arrowsUpSize       = 2;                 // Up arrow size
input int                 arrowsDnSize       = 2;                 // Down arrow size
input bool                Interpolate        = true;              // Interpolate in mtf mode?

double RSIBuf[],UpZone[],MdZone[],DnZone[],MaBuf[],MbBuf[],McBuf[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Type,Trade_Signal_Line2,Trade_Signal_Type2,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,_buff,_ind)

int init()
  {
   //IndicatorShortName("Traders Dynamic Index");
   IndicatorBuffers(9);
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,UpZone);
   SetIndexBuffer(2,MbBuf);
   SetIndexBuffer(3,DnZone);
   SetIndexBuffer(4,MaBuf);
   SetIndexBuffer(5,MdZone);// GREEN
   SetIndexBuffer(6,McBuf); //RED
   SetIndexBuffer(7,trend);
   SetIndexBuffer(8,count);
   
   SetIndexStyle(0,DRAW_NONE); 
   SetIndexStyle(1,DRAW_LINE); 
   SetIndexStyle(2,DRAW_LINE,2);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE,0,2);
   SetIndexStyle(5,DRAW_LINE,0,2);
   SetIndexStyle(6,DRAW_LINE,0,2);
   
   SetIndexLabel(0,NULL); 
   SetIndexLabel(1,"VB High"); 
   SetIndexLabel(2,"Market Base Line"); 
   SetIndexLabel(3,"VB Low"); 
   SetIndexLabel(4,"Line 2");
   SetIndexLabel(5,"RSI Price Line");
   SetIndexLabel(6,"Trade Signal Line");
 
   SetLevelValue(0,50);
   //SetLevelValue(1,68);
   //SetLevelValue(2,32);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
   
   IndicatorShortName(timeFrameToString(TimeFrame)+" TDI");
return(0);
}
void OnDeinit(const int reason)
{ 
    string lookFor       = arrowsIdentifier+":";
    int    lookForLength = StringLen(lookFor);
    for (int i=ObjectsTotal()-1; i>=0; i--)
    {
       string objectName = ObjectName(i);
       if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
    }
}

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(11,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     UpZone[i] = _mtfCall(1,y);
                     MbBuf[i]  = _mtfCall(2,y);
                     DnZone[i] = _mtfCall(3,y);
                     MaBuf[i]  = _mtfCall(4,y);
                     MdZone[i] = _mtfCall(5,y);
                     McBuf[i]  = _mtfCall(6,y);
                  
                     //
                     //
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           {
                              _interpolate(UpZone);
                              _interpolate(MbBuf);
                              _interpolate(DnZone);
                              _interpolate(MaBuf);
                              _interpolate(MdZone);
                              _interpolate(McBuf);
                           }                           
               }
   return(0);
   }
   
   //
   //
   //
   //
   //
   
   double MA,RSI[];
   ArrayResize(RSI,Volatility_Band);
   for(i=limit; i>=0; i--)
   {
      RSIBuf[i] = (iRSI(NULL,0,RSI_Period,RSI_Price,i)); 
      MA = 0;
      for(int x=i; x<i+Volatility_Band; x++) {
         RSI[x-i] = RSIBuf[x];
         MA += RSIBuf[x]/Volatility_Band;
      }
      UpZone[i] = (MA + (1.6185 * StDev(RSI,Volatility_Band)));
      DnZone[i] = (MA - (1.6185 * StDev(RSI,Volatility_Band)));  
      MdZone[i] = ((UpZone[i] + DnZone[i])/2);
      }
   for (i=limit;i>=0;i--)  
   {
       MaBuf[i] = (iMAOnArray(RSIBuf,0,RSI_Price_Line,0,RSI_Price_Type,i));
       MbBuf[i] = (iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,i));
       McBuf[i] = (iMAOnArray(RSIBuf,0,Trade_Signal_Line2,0,Trade_Signal_Type2,i)); 
       if (i<Bars-1)  trend[i] = (MdZone[i]<McBuf[i]) ? 1 : (MdZone[i]>McBuf[i]) ? -1 : trend[i+1];  
       
      //
      //
      //
      //
      //
      
      if (arrowsVisible)
      {
         string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
         if (i<(Bars-1) && trend[i] != trend[i+1])
         {
            if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
            if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
         }
      }     
   } 
//----
   return(0);
  }
  
double StDev(double& Data[], int Per)
{return(MathSqrt(Variance(Data,Per)));
}
double Variance(double& Data[], int Per)
{double sum, ssum;
  for (int i=0; i<Per; i++)
  {sum += Data[i];
   ssum += MathPow(Data[i],2);
  }
  return((ssum*Per - sum*sum)/(Per*(Per-1)));
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime atime = Time[i]; if (arrowsOnNewest) atime += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,atime,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

