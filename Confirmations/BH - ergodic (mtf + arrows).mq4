//------------------------------------------------------------------
#property link      "www.forex-station.com"
#property copyright "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrPaleVioletRed
#property indicator_width1  2
#property indicator_style2  STYLE_DOT
#property strict

//
//
//
//
//
extern ENUM_TIMEFRAMES   TimeFrame             = PERIOD_CURRENT;    // Time frame to use
input int                r                     = 2;                 // First ema period
input int                s                     = 10;                // Second ema period
input int                u                     = 5;                 // Third ema period
input int                trigger               = 3;                 // Signal ema period
input ENUM_APPLIED_PRICE Price                 = PRICE_CLOSE;       // Price to use
input bool               arrowsVisible         = false;             // Arrows visible true/false?
input bool               arrowsOnNewest        = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string             arrowsIdentifier      = "erg Arrows1";     // Unique ID for arrows
input double             arrowsUpperGap        = 0.1;               // Upper arrow gap
input double             arrowsLowerGap        = 0.1;               // Lower arrow gap
input color              arrowsUpColor         = clrBlue;           // Up arrow color
input color              arrowsDnColor         = clrCrimson;        // Down arrow color
input int                arrowsUpCode          = 116;               // Up arrow code
input int                arrowsDnCode          = 116;               // Down arrow code
input int                arrowsUpSize          = 2;                 // Up arrow size
input int                arrowsDnSize          = 2;                 // Down arrow size
input bool               Interpolate           = true;              // Interpolate true/false?

double tsi[],sig[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,r,s,u,trigger,Price,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,_buff,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,tsi,INDICATOR_DATA); SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(1,sig,INDICATOR_DATA); SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(2,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,count,INDICATOR_CALCULATIONS);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   
   IndicatorShortName(timeFrameToString(TimeFrame)+" BH ergodic ("+ (string)r +","+ (string)s +","+ (string)u +") Trigger"+ (string)trigger +")");
return(INIT_SUCCEEDED);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

   int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[],
                   const long &tick_volume[],
                   const long &volume[],
                   const int &spread[])
{
  
   int i,counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
            int limit=fmin(rates_total-counted_bars,rates_total-2); count[0] = limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(3,0)*TimeFrame/Period()));
               for (i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     tsi[i] = _mtfCall(0,y);
                     sig[i] = _mtfCall(1,y); 
                  
                     //
                     //
                     //
                     //
                     //
                  
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<rates_total && Time[i+n] >= btime; n++) continue;	
                         for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++)
                         {
                           _interpolate(tsi);
                           _interpolate(sig);
                         }
              }          
   return(rates_total);
   } 
              
   //
   //
   //
   //
   //

   for(i=limit; i>= 0; i--)
   {
      double priceDiff=0;
      if (i<rates_total-1) priceDiff = iMA(NULL,0,1,0,MODE_EMA,Price,i)-iMA(NULL,0,1,0,MODE_EMA,Price,i+1);
      double avg = iEma(iEma(iEma(     priceDiff ,r,i,rates_total,0),s,i,rates_total,1),u,i,rates_total,2);
      double ava = iEma(iEma(iEma(fabs(priceDiff),r,i,rates_total,3),s,i,rates_total,4),u,i,rates_total,5);
      tsi[i] = (ava != 0) ? 100.0*avg/ava : 0;
      sig[i] = iEma(tsi[i],trigger,i,rates_total,6);
      trend[i] = (i<rates_total-1) ? (tsi[i]>sig[i]) ? 1 : (tsi[i]<sig[i]) ? -1 : trend[i+1] : 0; 
      
      //
      //
      //
      //
      //
      
      if (arrowsVisible)
      {
         string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
         if (i<(rates_total-1) && trend[i] != trend[i+1])
         {
            if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
            if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
         }
      }  
   }
return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workEma[][7];
double iEma(double price, double period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= bars) ArrayResize(workEma,bars); i = bars-i-1;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workEma[i][instanceNo] = workEma[i-1][instanceNo]+alpha*(price-workEma[i-1][instanceNo]);
   return(workEma[i][instanceNo]);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
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

