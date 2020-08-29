
//+------------------------------------------------------------------+
//|                                             SAP - Supertrend.mq4 |
//|                                                                  |
//| This system (SAP System Basic I) is still under development,     |
//| there will be SAP Basic II, SAP Basic III and SAP Advance.       |
//| All systems are for sale but you can pay as much as              |
//| you feel like it or download it for free.                        |
//| If you find "SAP System Basic I" is useful for your trading,     |
//| care to donate to one of my accounts below.                      |
//| So that I can continue to develop this system.                   |                      
//|                                                                  |
//| 1. Liberty Reserve                                               |
//|    account U4821741 - Adhi Nugroho                               |
//| 2. C-Gold                                                        |
//|    account 38058 - Adhi Nugroho                                  | 
//|                                                                  |
//| 3. Standard Chartered Bank Indonesia - SCB Semarang              |
//|    acc : 02105169524 - Adhi Nugroho                              |
//|    local : bisa lewat atm / internet banking , any bank          |
//|    international :                                               |
//|    swift - SCBLIDJX ; iban - AE950440002602105169524             |
//|------------------------------------------------------------------|    
//| Kalau system SAP bermanfaat, silahkan membayar selayaknya        |
//| ke salah satu rekening di atas atau menggunakannya secara gratis.|
//|                                                                  |            
//| Terima kasih . May the pips be with you .                        |
//| email : odessa.xyz.2005@gmail.com                                |
//|                                                                  |
//| (Special thank you to the original creator of this indicator)    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Magenta
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1


extern string TimeFrame      = "Current time frame";
extern int    CciPeriod      = 34;
extern bool   OldCalculation = true;
extern bool   Interpolate    = true;

double STrend[];
double STrendDoA[];
double STrendDoB[];
double Trend[];


int    timeFrame;
string IndicatorFileName;
bool   ReturningBars;
bool   CalculatingStr;
double UpDownShift;



int init()
{
   IndicatorBuffers(4);
      SetIndexBuffer(0, STrend);    SetIndexLabel(0,"SuperTrend");
      SetIndexBuffer(1, STrendDoA); SetIndexLabel(1,"SuperTrend");
      SetIndexBuffer(2, STrendDoB); SetIndexLabel(2,"SuperTrend");
      SetIndexBuffer(3, Trend);

      
         
         IndicatorFileName = WindowExpertName();
         CalculatingStr    = (TimeFrame=="CalculateStr"); if (CalculatingStr) return(0);
         ReturningBars     = (TimeFrame=="returnBars");   if (ReturningBars)  return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
         
        
         
         if (OldCalculation)
         {
            switch(Period())
            {
               case 1:     UpDownShift = 3;   break;
               case 5:     UpDownShift = 5;   break;
               case 15:    UpDownShift = 7;   break;
               case 30:    UpDownShift = 9;   break;
               case 60:    UpDownShift = 20;  break;
               case 240:   UpDownShift = 35;  break;
               case 1440:  UpDownShift = 40;  break;
               case 10080: UpDownShift = 100; break;
               case 43200: UpDownShift = 120; break;
            }
            UpDownShift *= Point;
            if (Digits==3 || Digits==5)
               UpDownShift *= 10.0;
         }            
         
   
   
   
   IndicatorShortName("SAP - Supertrend "+timeFrameToString(timeFrame));    
}
int deinit()
{
   SAPSystem();
   return(0);
}


//+------------------------------------------------------------------+
//|                                             SAP - Supertrend.mq4 |
//|                                                                  |
//| This system (SAP System Basic I) is still under development,     |
//| there will be SAP Basic II, SAP Basic III and SAP Advance.       |
//| All systems are for sale but you can pay as much as              |
//| you feel like it or download it for free.                        |
//| If you find "SAP System Basic I" is useful for your trading,     |
//| care to donate to one of my accounts below.                      |
//| So that I can continue to develop this system.                   |                      
//|                                                                  |
//| 1. Liberty Reserve                                               |
//|    account U4821741 - Adhi Nugroho                               |
//| 2. C-Gold                                                        |
//|    account 38058 - Adhi Nugroho                                  | 
//| 3. Standard Chartered Bank Indonesia - SCB Semarang              |
//|    acc : 02105169524 - Adhi Nugroho                              |
//|    international :                                               |
//|    swift - SCBLIDJX ; iban - AE950440002602105169524             |
//|------------------------------------------------------------------|    
//| Kalau system SAP bermanfaat, silahkan membayar selayaknya        |
//| ke salah satu rekening di atas atau menggunakannya secara gratis.|
//|                                                                  |            
//| Terima kasih . May the pips be with you .                        |
//| email : odessa.xyz.2005@gmail.com                                |
//|                                                                  |
//| (Special thank you to the original creator of this indicator)    |
//+------------------------------------------------------------------+



int start()
{
   int counted_bars = IndicatorCounted();
   int limit,i;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (ReturningBars) { STrend[0] = limit+1; return(0); }

 

   if (CalculatingStr || timeFrame==Period())
   {      
      if (!CalculatingStr && Trend[limit]==-1) CleanPoint(limit,STrendDoA,STrendDoB);
      for(i=limit; i>=0; i--)
      {
         double cciTrend = iCCI(NULL, 0, CciPeriod, PRICE_TYPICAL, i);
         
      
         
         STrendDoA[i] = EMPTY_VALUE;
         STrendDoB[i] = EMPTY_VALUE;
         Trend[i]     = Trend[i+1];
            if (cciTrend > 0)    Trend[i]    =  1;
            if (cciTrend < 0)    Trend[i]    = -1;
            if (!OldCalculation) UpDownShift =  iATR(NULL,0,5,i);
            if (Trend[i] ==  1) STrend[i] = MathMax(Low[i]  - UpDownShift,STrend[i+1]);
            if (Trend[i] == -1) STrend[i] = MathMin(High[i] + UpDownShift,STrend[i+1]); 
            
       
            
            if (!CalculatingStr && Trend[i] == -1) PlotPoint(i,STrendDoA,STrendDoB,STrend);
      }
      return(0);
   }

   
   if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,IndicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (Trend[limit] == -1) CleanPoint(limit,STrendDoA,STrendDoB);

   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Trend[i]     = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateStr",CciPeriod,OldCalculation,3,y);
         STrend[i]    = iCustom(NULL,timeFrame,IndicatorFileName,"CalculateStr",CciPeriod,OldCalculation,0,y);
         STrendDoA[i] = EMPTY_VALUE;
         STrendDoB[i] = EMPTY_VALUE;
      
         if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

    

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            double factor = 1.0 / n;
            for(int k = 1; k < n; k++) STrend[i+k] = k*factor*STrend[i+n] + (1.0-k*factor)*STrend[i];
   }
   for (i=limit;i>=0;i--) if (Trend[i] == -1) PlotPoint(i,STrendDoA,STrendDoB,STrend);
   

   
   return(0);
}


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
      {
      if (first[i+2] == EMPTY_VALUE) {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
         }
      else {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
         }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}



string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};


int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}



string StringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int char = StringGetChar(s, length);
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                     s = StringSetChar(s, length, char - 32);
         else if(char > -33 && char < 0)
                     s = StringSetChar(s, length, char + 224);
   }
   return(s);
}
void SAPSystem() {
   ObjectCreate("SAP System Basic I", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SAP System Basic I", "SAP System", 12, "Arial", White);
   ObjectSet("SAP System Basic I", OBJPROP_CORNER, 2);
   ObjectSet("SAP System Basic I", OBJPROP_XDISTANCE, 5);
   ObjectSet("SAP System Basic I", OBJPROP_YDISTANCE, 10);
   }
//+------------------------------------------------------------------+
//|                                             SAP - Supertrend.mq4 |
//|                                                                  |
//| This system (SAP System Basic I) is still under development,     |
//| there will be SAP Basic II, SAP Basic III and SAP Advance.       |
//| All systems are for sale but you can pay as much as              |
//| you feel like it or download it for free.                        |
//| If you find "SAP System Basic I" is useful for your trading,     |
//| care to donate to one of my accounts below.                      |
//| So that I can continue to develop this system.                   |                      
//|                                                                  |
//| 1. Liberty Reserve                                               |
//|    account U4821741 - Adhi Nugroho                               |
//| 2. C-Gold                                                        |
//|    account 38058 - Adhi Nugroho                                  | 
//| 3. Standard Chartered Bank Indonesia - SCB Semarang              |
//|    acc : 02105169524 - Adhi Nugroho                              |
//|    local : bisa lewat atm / internet banking , any bank          |
//|    international :                                               |
//|    swift - SCBLIDJX ; iban - AE950440002602105169524             |
//|------------------------------------------------------------------|    
//| Kalau system SAP bermanfaat, silahkan membayar selayaknya        |
//| ke salah satu rekening di atas atau menggunakannya secara gratis.|
//|                                                                  |            
//| Terima kasih . May the pips be with you .                        |
//| email : odessa.xyz.2005@gmail.com                                |
//|                                                                  |
//| (Special thank you to the original creator of this indicator)    |
//+------------------------------------------------------------------+