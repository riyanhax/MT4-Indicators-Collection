//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrRed
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrLimeGreen
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame     = PERIOD_CURRENT;   // Time frame to use
extern int             HighLowPeriod = 10;               // High low period
extern int             ClosePeriod   =  0;               // Close period
extern double          Hot           = 0.7;              // T3 Hot
extern bool            OriginalT3    = false;            // T3 Original
extern bool            Interpolate   = true;             // Interpolate in multi time frame mode?

double hla[],hlda[],hldb[],Hlv[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,HighLowPeriod,ClosePeriod,Hot,OriginalT3,_buff,_ind)

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
   IndicatorBuffers(5);
   SetIndexBuffer(0,hla);
   SetIndexBuffer(1,hlda);
   SetIndexBuffer(2,hldb);
   SetIndexBuffer(3,Hlv);
   SetIndexBuffer(4,count);
      HighLowPeriod = fmax(HighLowPeriod,1);
      if (ClosePeriod == 0)
          ClosePeriod = HighLowPeriod;
          ClosePeriod = fmax(ClosePeriod,1);
          
     indicatorFileName = WindowExpertName();
     TimeFrame         = fmax(TimeFrame,_Period); 
      
   IndicatorShortName(timeFrameToString(TimeFrame)+" Gann T3 high-low activator");     
   return(0);
}
int deinit() { return(0); }       
          
//
//
//
//
//

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(4,0)*TimeFrame/_Period));
               if (Hlv[limit]==1) CleanPoint(limit,hlda,hldb);
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     hla[i]  = _mtfCall(0,y);
                     hlda[i] = EMPTY_VALUE;
                     hldb[i] = EMPTY_VALUE;
                     Hlv[i]  = _mtfCall(3,y);
                    
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(hla);                                             
                  }
                  for (i=limit;i>=0;i--) if (Hlv[i] == 1) PlotPoint(i,hlda,hldb,hla);
     return(0);
     }
     
     //
     //
     //
     //
     //
     
     if (Hlv[limit]==1) CleanPoint(limit,hlda,hldb);
     for (i=limit; i>=0; i--)
     {
       if (i<Bars-1)
       {
          double cl = iT3(Close[i] ,ClosePeriod,  Hot,OriginalT3,i,0);
          double hi = iT3(High[i+1],HighLowPeriod,Hot,OriginalT3,i,1);
          double lo = iT3(Low[i+1] ,HighLowPeriod,Hot,OriginalT3,i,2);
        
          hlda[i] = EMPTY_VALUE;
          hldb[i] = EMPTY_VALUE;
          Hlv[i] = (i<Bars-1) ? (cl > hi)  ? 1 : (cl < lo) ? -1 : Hlv[i+1] : 0;
          if (Hlv[i] ==-1) { hla[i] = hi;}
          if (Hlv[i] == 1) { hla[i] = lo;  PlotPoint(i,hlda,hldb,hla); } 
       }     
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

#define t3Instances 3
double workT3[][t3Instances*6];
double workT3Coeffs[][6];
#define _tperiod 0
#define _c1      1
#define _c2      2
#define _c3      3
#define _c4      4
#define _alpha   5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int tinstanceNo=0)
{
   if (ArrayRange(workT3,0) != Bars)                 ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (tinstanceNo+1)) ArrayResize(workT3Coeffs,tinstanceNo+1);

   if (workT3Coeffs[tinstanceNo][_tperiod] != period)
   {
     workT3Coeffs[tinstanceNo][_tperiod] = period;
        double a = hot;
            workT3Coeffs[tinstanceNo][_c1] = -a*a*a;
            workT3Coeffs[tinstanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[tinstanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[tinstanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[tinstanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[tinstanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int instanceNo = tinstanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+instanceNo] = price;
         workT3[r][1+instanceNo] = price;
         workT3[r][2+instanceNo] = price;
         workT3[r][3+instanceNo] = price;
         workT3[r][4+instanceNo] = price;
         workT3[r][5+instanceNo] = price;
      }
   else
      {
         workT3[r][0+instanceNo] = workT3[r-1][0+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(price                  -workT3[r-1][0+instanceNo]);
         workT3[r][1+instanceNo] = workT3[r-1][1+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][0+instanceNo]-workT3[r-1][1+instanceNo]);
         workT3[r][2+instanceNo] = workT3[r-1][2+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][1+instanceNo]-workT3[r-1][2+instanceNo]);
         workT3[r][3+instanceNo] = workT3[r-1][3+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][2+instanceNo]-workT3[r-1][3+instanceNo]);
         workT3[r][4+instanceNo] = workT3[r-1][4+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][3+instanceNo]-workT3[r-1][4+instanceNo]);
         workT3[r][5+instanceNo] = workT3[r-1][5+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][4+instanceNo]-workT3[r-1][5+instanceNo]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[tinstanceNo][_c1]*workT3[r][5+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c2]*workT3[r][4+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c3]*workT3[r][3+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c4]*workT3[r][2+instanceNo]);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
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