//------------------------------------------------------------------
#property copyright   "copyright© mladen"
#property link        "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrDimGray
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrOrange
#property indicator_color4  clrOrange
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property strict

extern ENUM_TIMEFRAMES   TimeFrame             = PERIOD_CURRENT;    // Time frame to use
input int                CalcPeriod            = 10;                // Calculation period
input int                AverPeriod            = 50;                // Average period
input ENUM_MA_METHOD     CalcMethod            = MODE_EMA;          // Average method
input ENUM_APPLIED_PRICE Price                 = PRICE_CLOSE;       // Price to use
input bool               arrowsVisible         = false;             // Arrows visible true/false?
input bool               arrowsOnNewest        = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string             arrowsIdentifier      = "mhl Arrows1";     // Unique ID for arrows
input double             arrowsUpperGap        = 0.1;               // Upper arrow gap
input double             arrowsLowerGap        = 0.1;               // Lower arrow gap
input color              arrowsUpColor         = clrBlue;           // Up arrow color
input color              arrowsDnColor         = clrCrimson;        // Down arrow color
input int                arrowsUpCode          = 116;               // Up arrow code
input int                arrowsDnCode          = 116;               // Down arrow code
input int                arrowsUpSize          = 2;                 // Up arrow size
input int                arrowsDnSize          = 2;                 // Down arrow size
input bool               Interpolate           = true;              // Interpolate true/false?

double ma[],mada[],madb[],avg[],slope[],prices[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CalcPeriod,AverPeriod,CalcMethod,Price,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,_buff,_ind)

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
   IndicatorBuffers(7);
   SetIndexBuffer(0,avg, INDICATOR_DATA); SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(1,ma,  INDICATOR_DATA); SetIndexStyle(1, DRAW_LINE); 
   SetIndexBuffer(2,mada,INDICATOR_DATA); SetIndexStyle(2, DRAW_LINE);  
   SetIndexBuffer(3,madb,INDICATOR_DATA); SetIndexStyle(3, DRAW_LINE); 
   SetIndexBuffer(4,slope); 
   SetIndexBuffer(5,prices); 
   SetIndexBuffer(6,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
         
   IndicatorShortName(timeFrameToString(TimeFrame)+" MHL average ("+(string)CalcPeriod+","+(string)AverPeriod+"");
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
   int i,limit=fmin(rates_total-prev_calculated+1,rates_total-1); count[0] = limit;
      if (TimeFrame!=_Period)
      {
         limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(6,0)*TimeFrame/_Period));
         if (slope[limit]==-1) CleanPoint(limit,mada,madb);
         for (i=limit; i>=0; i--)
         {
             int y = iBarShift(NULL,TimeFrame,time[i]);
                avg[i]   = _mtfCall(0,y);
                ma[i]    = _mtfCall(1,y); 
                mada[i]  = madb[i] = EMPTY_VALUE;
                slope[i] = _mtfCall(4,y); 
                 
                  
                //
                //
                //
                //
                //
                  
                if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                  #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                  int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<rates_total && time[i+n] >= btime; n++) continue;	
                     for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++)
                     {
                         _interpolate(avg);
                         _interpolate(ma);
                      }
              }
              for (i=limit; i>=0; i--) if (slope[i]==-1) PlotPoint(i,mada,madb,ma);         
   return(rates_total);
   }  
           
   //
   //
   //
   //
   //
   
   if (slope[limit]==-1) CleanPoint(limit,mada,madb);
   for (i=limit; i>=0; i--) prices[i] = (high[ArrayMaximum(high,CalcPeriod,i)]+low[ArrayMinimum(low,CalcPeriod,i)])/2.0;
   for (i=limit; i>=0; i--)
   {
      ma[i]   = iMAOnArray(prices,0,AverPeriod,0,CalcMethod,i);
      avg[i]  = iMA(NULL,0,AverPeriod,0,CalcMethod,Price,i);
      ma[i]   = avg[i]-ma[i]; avg[i] = 0;
      mada[i] = madb[i] = EMPTY_VALUE;
      if (i<rates_total-1) slope[i] = slope[i+1];
            if (ma[i]<avg[i]) slope[i] = -1;
            if (ma[i]>avg[i]) slope[i] =  1;
            if (slope[i]==-1) PlotPoint(i,mada,madb,ma);
            
            //
            //
            //
            //
            //
      
            if (arrowsVisible)
            {
              string lookFor = arrowsIdentifier+":"+(string)time[i]; ObjectDelete(lookFor);            
              if (i<(rates_total-1) && slope[i] != slope[i+1])
              {
                 if (slope[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
                 if (slope[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
              }
            }  
   }            
return(rates_total);
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
   if (i>Bars-2) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>Bars-3) return;
   if (first[i+1] == EMPTY_VALUE)
         if (first[i+2] == EMPTY_VALUE) 
               { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
         else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else        { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
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

