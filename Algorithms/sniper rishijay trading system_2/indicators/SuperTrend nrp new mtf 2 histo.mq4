//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1

extern int                period       = 10;
extern ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE;
extern double             multiplier   = 3.0;
extern ENUM_TIMEFRAMES    TimeFrame    = 0; //default chart TF :: Use 5, 15, 30, 60, etc...

//
//
//
//
//

double Trend[];
double TrendDoA[];
double TrendDoB[];
double Direction[];
double Up[];
double Dn[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(6);
      SetIndexBuffer(0, TrendDoA); SetIndexStyle(0,DRAW_HISTOGRAM);SetIndexLabel(0,"SuperTrend");
      SetIndexBuffer(1, TrendDoB); SetIndexStyle(1,DRAW_HISTOGRAM);SetIndexLabel(1,"SuperTrend");
      SetIndexBuffer(2, Trend);  
      SetIndexBuffer(3, Direction);
      SetIndexBuffer(4, Up);
      SetIndexBuffer(5, Dn);
         period    = MathMax(1,period);
         TimeFrame = MathMax(TimeFrame,+_Period);
   IndicatorShortName("SuperTrend");
   return(0);
}
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(MathMax(Bars-counted_bars,3*TimeFrame/_Period),Bars-1);

   //
   //
   //
   //
   //
      
   for(int i = limit; i >= 0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         double atr    = iATR(NULL,TimeFrame,period,y);
         double cprice = iMA(NULL,TimeFrame,1,0,MODE_SMA,appliedPrice,y);
         double mprice = (iHigh(NULL,TimeFrame,y)+iLow(NULL,TimeFrame,y))/2;
                Up[i]  = mprice+multiplier*atr;
                Dn[i]  = mprice-multiplier*atr;
         
         //
         //
         //
         //
         //
         
         Direction[i] = Direction[i+1];
            if (cprice > Up[i+1]) Direction[i] =  1;
            if (cprice < Dn[i+1]) Direction[i] = -1;
         TrendDoA[i] = EMPTY_VALUE;
         TrendDoB[i] = EMPTY_VALUE;
            if (Direction[i] > 0) { Dn[i] = MathMax(Dn[i],Dn[i+1]); Trend[i] = Dn[i]; }
            else                  { Up[i] = MathMin(Up[i],Up[i+1]); Trend[i] = Up[i]; }
            if (Direction[i] == 1)  TrendDoA[i] = 1; 
            if (Direction[i] ==-1)  TrendDoB[i] = 1; 
   }
   return(0);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}