//+------------------------------------------------------------------+
//|                                                         FTNP.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrGreen
#property indicator_color2  clrRed

extern ENUM_TIMEFRAMES    TimeFrame   = PERIOD_CURRENT; // Time frame
extern int                Length      = 10;
extern ENUM_APPLIED_PRICE Price       = PRICE_CLOSE;    // Applied price
extern bool               Interpolate = true;           // Interpolate in multi time frame mode

double Fisher[], Trigger[],Pr[],V1[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Length,Price,_buff,_ind)

int init()
{
 
   IndicatorDigits(Digits);
   IndicatorBuffers(5);
   SetIndexBuffer(0,Fisher); 
   SetIndexBuffer(1,Trigger);
   SetIndexBuffer(2,Pr);
   SetIndexBuffer(3,V1);
   SetIndexBuffer(4,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
   IndicatorShortName(timeFrameToString(TimeFrame)+" Fisher Transform of Normalized Prices");
 return(0);
}
int deinit(){ return(0);}

int start()
{
    int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(4,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     Fisher[i]  = _mtfCall(0,y);
                     Trigger[i] = _mtfCall(1,y);
                  
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
                              _interpolate(Fisher);
                              _interpolate(Trigger);
                           }                           
               }
               
   return(0);
   }
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 double MinPr, MaxPr;
 pos=limit;
 while(pos>=0)
 {
  MinPr=Pr[ArrayMinimum(Pr, Length, pos)];
  MaxPr=Pr[ArrayMaximum(Pr, Length, pos)];
  if (MaxPr!=MinPr)
  {
   V1[pos]=0.667*((Pr[pos]-MinPr)/(MaxPr-MinPr)-0.5+V1[pos+1]);
   V1[pos]=MathMin(V1[pos], 0.999);
   V1[pos]=MathMax(V1[pos], -0.999);
   Fisher[pos]=0.5*(MathLog((1.+V1[pos])/(1.-V1[pos]))+Fisher[pos+1]);
   Trigger[pos]=Fisher[pos+1];
  } 

  pos--;
 }
   
 return(0);
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


