//+------------------------------------------------------------------+
//|                                                 MACD colored.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers  7
#property indicator_color1   Green
#property indicator_color2   Green
#property indicator_color3   Red
#property indicator_color4   Red
#property indicator_color5   Gray
#property indicator_color6   Gold
#property indicator_color7   DimGray
#property indicator_width1   1
#property indicator_width2   2
#property indicator_width3   1
#property indicator_width4   2
#property indicator_width5   2
#property indicator_width6   1

extern string _            = "MACD settings";
extern int    FastEMA      = 12;
extern int    SlowEMA      = 26;
extern int    SignalEMA    = 9;
extern int    PriceType    = PRICE_CLOSE;
extern bool   ShowHisto    = true;
extern bool   ShowOSMA     = false;

//
//
//
//
//

extern int  MACDType  = 0;
extern int  RSIPeriod = 14;
extern int  MOMPeriod = 14;
extern int  CCIPeriod = 10;

//
//
//
//
//

extern string TimeFrame     = "Current time frame";
extern string __            = "alerts";
extern bool   alertsOn      = false;
extern bool   alertsMessage = true;
extern bool   alertsSound   = false;
extern bool   alertsEmail   = false;

extern string  note_MACD_Types_     = "0'regular'MACD 1ZeroLag MACD 2MACDofRSI  3MACDofMomentum 4MACDofCCI";

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
double buffer7[];
double buffer8[];
string IndicatorName;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,buffer1);
   SetIndexBuffer(1,buffer2);
   SetIndexBuffer(2,buffer3);
   SetIndexBuffer(3,buffer4);
   SetIndexBuffer(4,buffer5);
   SetIndexBuffer(5,buffer6);
   SetIndexBuffer(6,buffer7);
   SetIndexBuffer(7,buffer8);
   if (ShowOSMA)
   {
         ShowHisto = true;
         SetIndexStyle(6,DRAW_LINE);
   }         
   else  SetIndexStyle(6,DRAW_NONE);
   if (ShowHisto)
   {
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexStyle(3,DRAW_HISTOGRAM);
   }
   else
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }      
   
   //
   //
   //
   //
   //
   
   string ShortName;
   if  (MACDType==1)
         ShortName = "ZeroLag MACD (";
   else  ShortName = "MACD (";
         ShortName = ShortName+FastEMA+","+SlowEMA+","+SignalEMA+")";
         switch (MACDType)
         {
            case 2: ShortName = ShortName+" of RSI("     +RSIPeriod+")"; break;
            case 3: ShortName = ShortName+" of momentum("+MOMPeriod+")"; break;
            case 4: ShortName = ShortName+" of CCI("     +CCIPeriod+")"; break;
         }
         IndicatorShortName(ShortName);

   //
   //
   //
   //
   //

   timeFrame     = stringToTimeFrame(TimeFrame);
   IndicatorName = WindowExpertName();
   return(0);
}
int deinit()
{
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   double signalAlpha = 2.0/(1.0+SignalEMA);
   int  counted_bars  = IndicatorCounted();
   int  i,limit; 
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
      limit = Bars - counted_bars;

   //
   //
   //
   //
   //

   if (_ == "DoingZeroLag")  { CalculateZeroLag(limit); return(0); }
   
   //
   //
   //
   //
   //
                  
   if (_ == "calculating")
   {
      for(i = limit; i >= 0 ; i--)
      {
         switch (MACDType)
         {
            case 2:  buffer8[i] = iRSI(NULL,0,RSIPeriod,PriceType,i);      break;
            case 3:  buffer8[i] = iMomentum(NULL,0,MOMPeriod,PriceType,i); break;
            case 4:  buffer8[i] = iCCI(NULL,0,CCIPeriod,PriceType,i);      break;
            default: buffer8[i] = iMA(NULL,0,1,0,MODE_SMA,PriceType,i);    break;
         }               
      }
      for(i = limit; i >= 0 ; i--)
      {
         if (MACDType == 1)
         {
            buffer5[i] = iCustom(NULL,0,IndicatorName,"DoingZeroLag",FastEMA,SlowEMA,SignalEMA,PriceType,0,i);
            buffer6[i] = iCustom(NULL,0,IndicatorName,"DoingZeroLag",FastEMA,SlowEMA,SignalEMA,PriceType,1,i);
         }               
         else
         {
            buffer5[i] = iMAOnArray(buffer8,0,FastEMA,0,MODE_EMA,i)-
                         iMAOnArray(buffer8,0,SlowEMA,0,MODE_EMA,i);
            buffer6[i] = buffer6[i+1]+ signalAlpha*(buffer5[i]-buffer6[i+1]);
         }            

         //
         //
         //
         //
         //
                          
         buffer1[i]= EMPTY_VALUE;
         buffer2[i]= EMPTY_VALUE;
         buffer3[i]= EMPTY_VALUE;
         buffer4[i]= EMPTY_VALUE;
         if (!ShowOSMA)
         {
            if (buffer5[i]>0) 
               {
                  if (buffer5[i]>buffer5[i+1]) 
                        buffer2[i]=buffer5[i];
                  else  buffer1[i]=buffer5[i];
               }            
            else    
               {         
                  if (buffer5[i]<buffer5[i+1]) 
                        buffer4[i]=buffer5[i];
                  else  buffer3[i]=buffer5[i];
              }
         }
         else
         {
            buffer7[i] = buffer5[i]-buffer6[i];
            if (buffer7[i]>0) 
               {
                  if (buffer7[i]>buffer7[i+1]) 
                        buffer2[i]=buffer7[i];
                  else  buffer1[i]=buffer7[i];
               }            
            else    
               {         
                  if (buffer7[i]<buffer7[i+1]) 
                        buffer4[i]=buffer7[i];
                  else  buffer3[i]=buffer7[i];
              }
         }
      }
      return(0);
   }      

   //
   //
   //
   //
   //
   
   limit = MathMax(limit,timeFrame/Period());
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         buffer1[i] = iCustom(NULL,timeFrame,IndicatorName,"calculating",FastEMA,SlowEMA,SignalEMA,PriceType,ShowHisto,ShowOSMA,MACDType,RSIPeriod,MOMPeriod,CCIPeriod,0,y);
         buffer2[i] = iCustom(NULL,timeFrame,IndicatorName,"calculating",FastEMA,SlowEMA,SignalEMA,PriceType,ShowHisto,ShowOSMA,MACDType,RSIPeriod,MOMPeriod,CCIPeriod,1,y);
         buffer3[i] = iCustom(NULL,timeFrame,IndicatorName,"calculating",FastEMA,SlowEMA,SignalEMA,PriceType,ShowHisto,ShowOSMA,MACDType,RSIPeriod,MOMPeriod,CCIPeriod,2,y);
         buffer4[i] = iCustom(NULL,timeFrame,IndicatorName,"calculating",FastEMA,SlowEMA,SignalEMA,PriceType,ShowHisto,ShowOSMA,MACDType,RSIPeriod,MOMPeriod,CCIPeriod,3,y);
         buffer5[i] = iCustom(NULL,timeFrame,IndicatorName,"calculating",FastEMA,SlowEMA,SignalEMA,PriceType,ShowHisto,ShowOSMA,MACDType,RSIPeriod,MOMPeriod,CCIPeriod,4,y);
         buffer6[i] = iCustom(NULL,timeFrame,IndicatorName,"calculating",FastEMA,SlowEMA,SignalEMA,PriceType,ShowHisto,ShowOSMA,MACDType,RSIPeriod,MOMPeriod,CCIPeriod,5,y);
         buffer7[i] = iCustom(NULL,timeFrame,IndicatorName,"calculating",FastEMA,SlowEMA,SignalEMA,PriceType,ShowHisto,ShowOSMA,MACDType,RSIPeriod,MOMPeriod,CCIPeriod,6,y);
   }
   
   //
   //
   //
   //
   //

   if (alertsOn)
   {
      if (buffer6[0]>buffer5[0] && buffer6[1] < buffer5[1]) doAlert("signal line crossed macd line up"); 
      if (buffer6[0]<buffer5[0] && buffer6[1] > buffer5[1]) doAlert("signal line crossed macd line down"); 
   }   
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CalculateZeroLag(int limit)
{
   int    i;
   double maf,mas;
   
   //
   //
   //
   //
   //
   
   for(i=limit;i>=0;i--)
   {
      buffer3[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PriceType,i);
      buffer4[i]=iMA(NULL,0,SlowEMA,0,MODE_EMA,PriceType,i);
   }
   for(i=limit;i>=0;i--)
   {
      maf=buffer3[i]+buffer3[i]-iMAOnArray(buffer3,0,FastEMA,0,MODE_EMA,i);
      mas=buffer4[i]+buffer4[i]-iMAOnArray(buffer4,0,SlowEMA,0,MODE_EMA,i);
          buffer1[i]=maf-mas;
   }
   
   //
   //
   //
   //
   //
   
   for(i=limit;i>=0;i--) buffer5[i]=                      iMAOnArray(buffer1,0,SignalEMA,0,MODE_EMA,i);
   for(i=limit;i>=0;i--) buffer2[i]=buffer5[i]+buffer5[i]-iMAOnArray(buffer5,0,SignalEMA,0,MODE_EMA,i);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void doAlert(string forWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != forWhat || previousTime != Time[0]) {
       previousAlert  = forWhat;
       previousTime   = Time[0];
       message        = StringConcatenate(Symbol()," ",forWhat," at ",TimeToStr(TimeLocal(),TIME_SECONDS));
           if (alertsMessage) Alert(message);
           if (alertsSound)   PlaySound("alert2.wav");
           if (alertsEmail)   SendMail(StringConcatenate(Symbol()," MACD crossing"),message);
   }           
}

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   for(int l = StringLen(tfs)-1; l >= 0; l--)
   {
      int tchar = StringGetChar(tfs,l);
          if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
               tfs = StringSetChar(tfs, l, tchar - 32);
          else 
              if(tchar > -33 && tchar < 0)
                  tfs = StringSetChar(tfs, l, tchar + 224);
   }

   //
   //
   //
   //
   //
   
   int tf=0;
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf<Period() && tf!=0)      tf=Period();
   return(tf);
} 