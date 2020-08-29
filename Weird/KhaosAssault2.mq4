//+------------------------------------------------------------------+
//|                                                 KhaosAssault.mq4 |
//|                                                         SGalaise |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Sgalaise"

#property indicator_separate_window
#property indicator_buffers 3
#property  indicator_color1  Black
#property  indicator_color2  LawnGreen
#property  indicator_color3  Red

//---- input parameters
extern int       FastMovingMAType=3;
extern int       FastMovingMAPeriod=5;
extern int       SlowMovingMAType=1;
extern int       SlowMovingMAPeriod=120;

//---- buffers
double CAOBuffer0[];
double CAOBuffer1[];
double CAOBuffer2[];

string SlowMA = "";
string FastMA = "";

double prev,current;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //IndicatorBuffers(3);
  
   switch(FastMovingMAType)
   {
      case 0: FastMA = "SMA"; break;
      case 1: FastMA = "EMA"; break;
      case 2: FastMA = "SMMA"; break;
      case 3: FastMA = "LWMA"; break;
   }
   
   switch(SlowMovingMAType)
   {
      case 0: SlowMA = "SMA"; break;
      case 1: SlowMA = "EMA"; break;
      case 2: SlowMA = "SMMA"; break;
      case 3: SlowMA = "LWMA"; break;
   }
//   IndicatorBuffers(3);
   
//---- indicators
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,3,LawnGreen);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,Red);
   IndicatorDigits(Digits+1);
   SetIndexDrawBegin(0,SlowMovingMAPeriod);
   SetIndexDrawBegin(1,SlowMovingMAPeriod);
   SetIndexDrawBegin(2,SlowMovingMAPeriod);
      
   SetIndexBuffer(0,CAOBuffer0);
   SetIndexBuffer(1,CAOBuffer1);
   SetIndexBuffer(2,CAOBuffer2);

//----
   IndicatorShortName("KhaosAssault ("+FastMA+":"+FastMovingMAPeriod+", "+SlowMA+":"+SlowMovingMAPeriod+")");
   int findsymbol = StringFind(Symbol(),"JPY",0);
   //Alert(findsymbol);
   if(findsymbol<0)
   {
      SetLevelStyle(1,1,SteelBlue);
      SetLevelValue(1,0.0089);
      SetLevelValue(2,0.0055);
      SetLevelValue(3,0.0034);
      SetLevelValue(4,0.0021);
      SetLevelValue(5,0.0013);
      SetLevelValue(6,-0.0013);
      SetLevelValue(7,-0.0021);
      SetLevelValue(8,-0.0034);
      SetLevelValue(9,-0.0055);
      SetLevelValue(10,-0.0089);
   }
   else
   {
      SetLevelStyle(1,1,SteelBlue);
      SetLevelValue(1,0.89);
      SetLevelValue(2,0.55);
      SetLevelValue(3,0.34);
      SetLevelValue(4,0.21);
      SetLevelValue(5,0.13);
      SetLevelValue(6,-0.13);
      SetLevelValue(7,-0.21);
      SetLevelValue(8,-0.34);
      SetLevelValue(9,-0.55);
      SetLevelValue(10,-0.89);
   }  
         
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {  
   int    limit;
   int    counted_bars=IndicatorCounted();
   
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd
   for(int i=0; i<limit; i++)
      CAOBuffer0[i]=iMA(NULL,0,FastMovingMAPeriod,0,FastMovingMAType,PRICE_CLOSE,i)-iMA(NULL,0,SlowMovingMAPeriod,0,SlowMovingMAType,PRICE_CLOSE,i);
      
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=CAOBuffer0[i];
      prev=CAOBuffer0[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         CAOBuffer2[i]=current;
         CAOBuffer1[i]=0.0;
        }
      else
        {
         CAOBuffer1[i]=current;
         CAOBuffer2[i]=0.0;
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+