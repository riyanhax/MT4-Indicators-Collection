//+------------------------------------------------------------------+
//|                                                       adxvma.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "www.forex-station.com"


#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  DimGray  
#property indicator_color2  DeepSkyBlue 
#property indicator_color3  DeepSkyBlue 
#property indicator_color4  OrangeRed
#property indicator_color5  OrangeRed 
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2

//
//
//
//
//

extern string TimeFrame      = "Current time frame";
extern double AdxVmaPeriod   = 10;
extern int    AdxVmaPrice    = PRICE_MEDIAN;
extern bool   TrendMode      = false;
extern bool   MultiColorMode = true;
extern bool   Interpolate    = true;

//
//
//
//
//

double adxvma[];
double adxvmua[];
double adxvmub[];
double adxvmda[];
double adxvmdb[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,adxvma);
   SetIndexBuffer(1,adxvmua);
   SetIndexBuffer(2,adxvmub);
   SetIndexBuffer(3,adxvmda);
   SetIndexBuffer(4,adxvmdb);
   SetIndexBuffer(5,trend);

   //
   //
   //
   //
   //

      AdxVmaPeriod      = MathMax(AdxVmaPeriod,1);
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="CalculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);

   //
   //
   //
   //
   //
   
   IndicatorShortName(timeFrameToString(timeFrame)+" AdxVma ("+DoubleToStr(AdxVmaPeriod,2)+")");
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

double  work[][6];
#define prc 0
#define pdm 1
#define mdm 2
#define pdi 3
#define mdi 4
#define out 5

//
//
//
//
//

int start()
{
   int counted_bars = IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { adxvma[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {
      if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
      if (!calculateValue && MultiColorMode && trend[limit]== 1) CleanPoint(limit,adxvmua,adxvmub);
      if (!calculateValue && MultiColorMode && trend[limit]==-1) CleanPoint(limit,adxvmda,adxvmdb);
      
      //
      //
      //
      //
      //
      
      for(i = limit, r=Bars-i-1; i >= 0; i--,r++)
      {
         work[r][prc] = NormalizeDouble(iMA(NULL,0,1,0,MODE_SMA,AdxVmaPrice,i),4);

         //
         //
         //
         //
         //
            
         double diff = work[r][prc]-work[r-1][prc];
         double tpdm = 0;
         double tmdm = 0;
               if (diff>0)
                     tpdm =  diff;
               else  tmdm = -diff;          
         work[r][pdm] = ((AdxVmaPeriod-1.0)*work[r-1][pdm]+tpdm)/AdxVmaPeriod;
         work[r][mdm] = ((AdxVmaPeriod-1.0)*work[r-1][mdm]+tmdm)/AdxVmaPeriod;

         //
         //
         //
         //
         //

         double trueRange = work[r][pdm]+work[r][mdm];
         double tpdi      = 0;
         double tmdi      = 0;
               if (trueRange>0)
               {
                  tpdi = work[r][pdm]/trueRange;
                  tmdi = work[r][mdm]/trueRange;
               }            
         work[r][pdi] = ((AdxVmaPeriod-1.0)*work[r-1][pdi]+tpdi)/AdxVmaPeriod;
         work[r][mdi] = ((AdxVmaPeriod-1.0)*work[r-1][mdi]+tmdi)/AdxVmaPeriod;
   
         //
         //
         //
         //
         //
                  
         double tout  = 0; if ((work[r][pdi]+work[r][mdi])>0) tout = MathAbs(work[r][pdi]-work[r][mdi])/(work[r][pdi]+work[r][mdi]);
         work[r][out] = ((AdxVmaPeriod-1.0)*work[r-1][out]+tout)/AdxVmaPeriod;

         //
         //
         //
         //
         //
                 
         double thi = MathMax(work[r][out],work[r-1][out]);
         double tlo = MathMin(work[r][out],work[r-1][out]);
            for (int j = 2; j<AdxVmaPeriod; j++)
            {
               thi = MathMax(work[r-j][out],thi);
               tlo = MathMin(work[r-j][out],tlo);
            }            
         double vi = 0; if ((thi-tlo)>0) vi = (work[r][out]-tlo)/(thi-tlo);

      //
      //
      //
      //
      //
         
         adxvma[i]  = ((AdxVmaPeriod-vi)*adxvma[i+1]+vi*work[r][prc])/AdxVmaPeriod;
         adxvmua[i] = EMPTY_VALUE;
         adxvmub[i] = EMPTY_VALUE;
         adxvmda[i] = EMPTY_VALUE;
         adxvmdb[i] = EMPTY_VALUE;

            if (TrendMode)
                  trend[i] = trend[i+1];
            else  trend[i] = 0;
            if (adxvma[i]>adxvma[i+1]) trend[i] =  1;
            if (adxvma[i]<adxvma[i+1]) trend[i] = -1;
            if (!calculateValue && MultiColorMode && trend[i]== 1) PlotPoint(i,adxvmua,adxvmub,adxvma);
            if (!calculateValue && MultiColorMode && trend[i]==-1) PlotPoint(i,adxvmda,adxvmdb,adxvma);
      }
      return(0);
   }
   
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (MultiColorMode && trend[limit]== 1) CleanPoint(limit,adxvmua,adxvmub);
   if (MultiColorMode && trend[limit]==-1) CleanPoint(limit,adxvmda,adxvmdb);
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         adxvma[i]  = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",AdxVmaPeriod,AdxVmaPrice,TrendMode,0,y);
         trend[i]   = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",AdxVmaPeriod,AdxVmaPrice,TrendMode,5,y);
         adxvmua[i] = EMPTY_VALUE;
         adxvmub[i] = EMPTY_VALUE;
         adxvmda[i] = EMPTY_VALUE;
         adxvmdb[i] = EMPTY_VALUE;

         //
         //
         //
         //
         //
      
            if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
            if (!Interpolate) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
               adxvma[i+k] = adxvma[i] + (adxvma[i+n]-adxvma[i])*k/n;
   }
   for (i=limit;i>=0;i--)
   {
      if (MultiColorMode && trend[i]== 1) PlotPoint(i,adxvmua,adxvmub,adxvma);
      if (MultiColorMode && trend[i]==-1) PlotPoint(i,adxvmda,adxvmdb,adxvma);
   }
   
   //
   //
   //
   //
   //
      
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

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
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

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}