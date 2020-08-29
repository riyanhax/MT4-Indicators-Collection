//+------------------------------------------------------------------+
//|                                                     CycleBar.mq4 |
//|                                                    FX-PROGRAMMER |
//|                                  FROM TRADESTATION               |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Lime  //UpColor
#property indicator_color2 Red    //DwnColor
//#property indicator_color3 LightGray //BarColor

#property indicator_minimum -0.5
#property indicator_maximum 1.5

extern int     PriceActionFilter = 100;
extern int     Length = 2;  //Percent change in CyclePrice to set up a new swing high/low
extern int     CycleStrength = 0;//Change (number of ticks) required to set up a new swing high/low.
extern bool    UseCycleFilter = False;
extern int     UseFilterSMAorRSI = 1;
extern int     FilterStrengthSMA = 12;
extern int     FilterStrengthRSI = 21;

double UpColor[];
double DwnColor[];
//double BarColor[];
double ZL1[];
double CyclePrice[];
//double Sum[];
//double SmoothedAverage[];

double DJ = 0.2;//Length / 10; NOTE !!!! hard code since the result of the devision from unknown reason is 0
int SwitchA = 0;
int IRHBAR = 0; // LAST SWING HIGH BAR
int IRLBAR = 0; // LAST SWING LOW BAR
bool LOWSEEK = FALSE;    //LOOKING FOR A LOW OR A HIGH?
double IRH = 0.0;          //LAST SWING HIGH VALUE
double IRL = 99999.0;      //LAST SWING LOW VALUE
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(4); 

   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,UpColor);
   
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(1,DwnColor);
   
 //  SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
 //  SetIndexBuffer(2,BarColor);
 
   SetIndexBuffer(2,ZL1); 
   SetIndexBuffer(3,CyclePrice);
   
//   SetIndexBuffer(3,Sum);
//   SetIndexBuffer(3,SmoothedAverage);
   
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
//   SetIndexEmptyValue(4,0.0);
//   SetIndexEmptyValue(5,0.0);
  return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
  // if(counted_bars>0) counted_bars--;
  // int position=Bars-1;
   int limit=Bars-counted_bars;
   if (limit<0) 
      limit=0;

   for (int pos = limit; pos >=0; pos--)
   { 
      CyclePrice[pos] = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, pos);
     // CyclePrice[pos] = SmoothedAverage(PriceActionFilter, pos); 
     
      if (UseFilterSMAorRSI == 1)
            ZL1[pos] = ZeroLag(CyclePrice[pos],FilterStrengthSMA, pos);
      if (UseFilterSMAorRSI == 2)
            ZL1[pos] = ZeroLag( iRSI(NULL, 0, 14, CyclePrice[pos], FilterStrengthRSI ), FilterStrengthRSI, pos);

      if (ZL1[pos] > ZL1[pos+1]) 
          SwitchA  = 1;
      if (ZL1[pos] < ZL1[pos+1]) 
          SwitchA  = 2;
          
      if (pos < Bars) //???? CURRENTBAR >0
      {
         if ((LOWSEEK == FALSE) && (IRHBAR != 0)) 
         { 
            if ( ( (CycleStrength == 0) && (Low[pos] < (IRH * ( 1 -  0.002))) )||  //Note: Hard code 0.002
                 ( (CycleStrength != 0) && (Low[pos] < (IRH -  CycleStrength*Point)) ))
            { 
               IRL = Low[pos];
               IRLBAR = 0;
               LOWSEEK = TRUE;
               if (pos + IRHBAR + 1 <= Bars)
               {
                  if  (UseCycleFilter == False)
                  {
                     DwnColor[pos+IRHBAR] = 1;//PLOT1[IRHBAR](1,"SellBar",DwnColor);
                  }
                  if ((UseCycleFilter == True) && (SwitchA == 2))   
                  {
                     DwnColor[IRHBAR] = 1;//PLOT1[IRHBAR](1,"SellBar",DwnColor);
                  }
               }
            }
         }    

         if ( (LOWSEEK == TRUE) && (IRLBAR != 0))
         {
            if ( ((CycleStrength == 0) && (High[pos] > (IRL * ( 1 +  0.002))) ) ||  //Note: Hard code 0.002
               ( ((CycleStrength != 0) && (High[pos] > (IRL + CycleStrength* Point)) ) ))
            {   
               IRH = High[pos];
               IRHBAR = 0;
               LOWSEEK = FALSE;
               if (pos + IRLBAR +1 <= Bars) 
               {
                  if (UseCycleFilter == False) 
                  {
                      UpColor[pos+IRLBAR] = 1;//PLOT2[IRLBAR](1,"BuyBar",UpColor);
                  }
                  if ((UseCycleFilter == True) && (SwitchA == 1))       
                  {
                     UpColor[IRLBAR]= 1;//PLOT2[IRLBAR](1,"BuyBar",UpColor);
                  }
              }   
            }
         }
         
         //***********Small Bars ************
         if ( (LOWSEEK == FALSE) && (IRH <= High[pos]) ) 
         {
            IRH = High[pos];
            //BarColor[pos+IRHBAR] = 0;//PLOT1[IRHBAR](0,"SellBar",BarColor);
            IRHBAR = 0;
            if (UseCycleFilter == False)
            {
               DwnColor[pos] = 1; //PLOT1(1,"SellBar",DwnColor); ????
            }
            if ((UseCycleFilter == True) && (SwitchA == 2)) 
            {
               DwnColor[pos] = 1; //PLOT1(1,"SellBar",DwnColor);  ????
            }  
         }
         // *************
         if ((LOWSEEK == TRUE) && (IRL >= Low[pos]) )
         {
            IRL = Low[pos];
            //   BarColor[pos+IRHBAR] = 0;//PLOT1[IRHBAR](0,"SellBar",BarColor);
            IRLBAR = 0;
            if (UseCycleFilter == False)
            {
               UpColor[pos] = 1;//PLOT2(1,"BuyBar",UpColor);
            }
            if ((UseCycleFilter == True) && (SwitchA == 1)) 
            {
               UpColor[pos] = 1; //PLOT2(1,"BuyBar",UpColor);
            }
         }   
         //*************
         IRHBAR = IRHBAR + 1;
         IRLBAR = IRLBAR + 1;                 
      }
      DwnColor[pos] = 0;
      UpColor[pos] = 0;
   }
   return(0);
}

double ZeroLag(double price, int length, int pos)
{   
   if (length < 3)
   {
      return(price);
   }
   double aa = MathExp(-1.414*3.14159 / length);
   double bb = 2*aa*MathCos(1.414*180 / length);
   double CB = bb;
   double CC = -aa*aa;
   double CA = 1 - CB - CC;
   double CD = CA*price + CB*ZL1[pos+1] + CC*ZL1[pos+2];
   return(CD);
}

/*
double Summation(int length, int startPosition)
{
   double Sum = 0;
   for (int counter = startPosition; counter < startPosition + length; counter++)
   {
       if (counter >= Bars)
         break;	     
	    Sum = Sum + Close[counter];
	}

   return (Sum);
}


double SmoothedAverage(int length, int startPosition)
{
   if (length > 0)
   {
	  if (startPosition  == (startPosition + length - 1))
	  {
		  Sum[startPosition] = Summation(length, startPosition);
		  SmoothedAverage[startPosition] = Sum[startPosition] / length;
		  return (SmoothedAverage[startPosition]);
	  }
	  else
	  { 
		    SmoothedAverage[startPosition] = (Sum[startPosition+1] - SmoothedAverage[startPosition+1] + Close[startPosition]) / length;
		    startPosition++;
		    Sum[startPosition] = Summation(length, startPosition);
	  }
   }
}*/
//+------------------------------------------------------------------+