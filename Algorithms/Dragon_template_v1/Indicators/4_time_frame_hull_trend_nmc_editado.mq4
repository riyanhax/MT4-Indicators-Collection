//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.cm"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  LimeGreen
#property indicator_color4  PaleVioletRed
#property indicator_color5  LimeGreen
#property indicator_color6  PaleVioletRed
#property indicator_color7  LimeGreen
#property indicator_color8  PaleVioletRed
#property indicator_minimum 0
#property indicator_maximum 5

//
//
//
//
//

extern string TimeFrame1            = "Current time frame";
extern string TimeFrame2            = "H1";
extern string TimeFrame3            = "next1";
extern string TimeFrame4            = "next2";
extern int    HullPeriod            = 14;
extern int    HullPrice             =  0; 
extern string UniqueID              = "4 Time hull trend";
extern int    LinesWidth            =  0;
extern color  LabelsColor           = DarkGray;
extern int    LabelsHorizontalShift = 5;
extern double LabelsVerticalShift   = 1.5;
extern bool   alertsOn              = false;
extern int    alertsLevel           = 3;
extern bool   alertsMessage         = true;
extern bool   alertsSound           = false;
extern bool   alertsEmail           = false;

//
//
//
//
//

double hulltre1u[];
double hulltre1d[];
double hulltre2u[];
double hulltre2d[];
double hulltre3u[];
double hulltre3d[];
double hulltre4u[];
double hulltre4d[];

int    timeFrames[4];
bool   returnBars;
bool   calculateValue;
string indicatorFileName;

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
   SetIndexBuffer(0,hulltre1u);
   SetIndexBuffer(1,hulltre1d);
   SetIndexBuffer(2,hulltre2u);
   SetIndexBuffer(3,hulltre2d);
   SetIndexBuffer(4,hulltre3u);
   SetIndexBuffer(5,hulltre3d);
   SetIndexBuffer(6,hulltre4u);
   SetIndexBuffer(7,hulltre4d);
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame1=="returnBars");     if (returnBars)     return(0);
      calculateValue    = (TimeFrame1=="calculateValue"); if (calculateValue) return(0);
      
      //
      //
      //
      //
      //
      
      for (int i=0; i<8; i++) 
      {
         SetIndexStyle(i,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(i,110); 
      }
      timeFrames[0] = stringToTimeFrame(TimeFrame1);
      timeFrames[1] = stringToTimeFrame(TimeFrame2);
      timeFrames[2] = stringToTimeFrame(TimeFrame3);
      timeFrames[3] = stringToTimeFrame(TimeFrame4);
      alertsLevel = MathMin(MathMax(alertsLevel,3),4);
      IndicatorShortName(UniqueID);
   return(0);
}
int deinit()
{
   for (int t=0; t<4; t++) ObjectDelete(UniqueID+t);
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

double trend[][2];
#define _up 0
#define _dn 1
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { hulltre1u[0] = limit+1; return(0); }
         if (calculateValue) { calculateHull(limit); return(0); }

         if (timeFrames[0] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[0],indicatorFileName,"returnBars",0,0)*timeFrames[0]/Period()));
         if (timeFrames[1] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[1],indicatorFileName,"returnBars",0,0)*timeFrames[1]/Period()));
         if (timeFrames[2] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[2],indicatorFileName,"returnBars",0,0)*timeFrames[2]/Period()));
         if (timeFrames[3] != Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[3],indicatorFileName,"returnBars",0,0)*timeFrames[3]/Period()));
         if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);

         //
         //
         //
         //
         //
         
         bool initialized = false;
         if (!initialized)
         {
            initialized = true;
            int window = WindowFind(UniqueID);
            for (int t=0; t<4; t++)
            {
               string label = timeFrameToString(timeFrames[t]);
               ObjectCreate(UniqueID+t,OBJ_TEXT,window,0,0);
                  ObjectSet(UniqueID+t,OBJPROP_COLOR,LabelsColor);
                  ObjectSet(UniqueID+t,OBJPROP_PRICE1,t+LabelsVerticalShift);
                  ObjectSetText(UniqueID+t,label,8,"Arial");
            }               
         }
         for (t=0; t<4; t++) ObjectSet(UniqueID+t,OBJPROP_TIME1,Time[0]+Period()*LabelsHorizontalShift*60);

   //
   //
   //
   //
   //
    
   for(i = limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      trend[r][_up] = 0;
      trend[r][_dn] = 0;
      for (int k=0; k<4; k++)
      {
         int y = iBarShift(NULL,timeFrames[k],Time[i]);
            double state = iCustom(NULL,timeFrames[k],indicatorFileName,"calculateValue","","","",HullPeriod,HullPrice,0,y);
            bool isUp = (state>0);
            switch (k)
            {
               case 0 : if (isUp) { hulltre1u[i] = k+1; hulltre1d[i] = EMPTY_VALUE;}  else { hulltre1d[i] = k+1; hulltre1u[i] = EMPTY_VALUE; } break;
               case 1 : if (isUp) { hulltre2u[i] = k+1; hulltre2d[i] = EMPTY_VALUE;}  else { hulltre2d[i] = k+1; hulltre2u[i] = EMPTY_VALUE; } break;
               case 2 : if (isUp) { hulltre3u[i] = k+1; hulltre3d[i] = EMPTY_VALUE;}  else { hulltre3d[i] = k+1; hulltre3u[i] = EMPTY_VALUE; } break;
               case 3 : if (isUp) { hulltre4u[i] = k+1; hulltre4d[i] = EMPTY_VALUE;}  else { hulltre4d[i] = k+1; hulltre4u[i] = EMPTY_VALUE; } break;
            }
            if (isUp)
                  trend[r][_up] += 1;
            else  trend[r][_dn] += 1;
      }
   }
   manageAlerts();
   return(0);
}


//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void calculateHull(int limit)
{
   for (int i=limit; i>=0; i--)
   {
         hulltre4u[i] = iHull(iMA(NULL,0,1,0,MODE_SMA,HullPrice,i),HullPeriod,i);
         hulltre1u[i] = hulltre1u[i+1];
            if (hulltre4u[i]>hulltre4u[i+1]) hulltre1u[i] =  1;
            if (hulltre4u[i]<hulltre4u[i+1]) hulltre1u[i] = -1;
   }
}

//
//
//
//
//

double workHull[][2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars); r=Bars-r-1;

   //
   //
   //
   //
   //

      int HmaPeriod  = MathMax(period,2);
      int HalfPeriod = MathFloor(HmaPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = Bars-1;
      if (trend[whichBar][_up] >= alertsLevel || trend[whichBar][_dn] >= alertsLevel)
      {
         if (trend[whichBar][_up] >= alertsLevel) doAlert("up"  ,trend[whichBar][_up]);
         if (trend[whichBar][_dn] >= alertsLevel) doAlert("down",trend[whichBar][_dn]);
      }
   }
}

//
//
//
//
//

void doAlert(string doWhat, int howMany)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" "+howMany+" time frames of hull trend are aligned "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" 4 time frame hull trend",message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
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

//
//
//
//
//

int toInt(double value) { return(value); }
int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   int max = ArraySize(iTfTable)-1, add=0;
   int nxt = (StringFind(tfs,"NEXT1")>-1); if (nxt>0) { tfs = ""+Period(); add=1; }
       nxt = (StringFind(tfs,"NEXT2")>-1); if (nxt>0) { tfs = ""+Period(); add=2; }
       nxt = (StringFind(tfs,"NEXT3")>-1); if (nxt>0) { tfs = ""+Period(); add=3; }

      //
      //
      //
      //
      //
         
      for (int i=max; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[toInt(MathMin(max,i+add))],Period()));
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