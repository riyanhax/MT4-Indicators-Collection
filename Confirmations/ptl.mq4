//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  PaleVioletRed
#property indicator_color2  LimeGreen
#property indicator_color3  PaleVioletRed
#property indicator_color4  LimeGreen
#property indicator_color5  PaleVioletRed
#property indicator_color6  LimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  3
#property indicator_width6  3

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    SlowLength      = 7;
extern double SlowPipDisplace = 0;
extern int    FastLength      = 3;
extern double FastPipDisplace = 0;

double line1[];
double line2[];
double hist1[];
double hist2[];
double arrou[];
double arrod[];
double trend[];
double trena[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

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
   IndicatorBuffers(8);
      SetIndexBuffer(0,line1);
      SetIndexBuffer(1,line2);
      SetIndexBuffer(2,hist1); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3,hist2); SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(4,arrod); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,159);
      SetIndexBuffer(5,arrou); SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,159);
      SetIndexBuffer(6,trend);
      SetIndexBuffer(7,trena);
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
   IndicatorShortName(timeFrameToString(timeFrame)+" ptl");
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { line1[0] = MathMin(limit+1,Bars-1); return(0); }
         double pipMultiplier = 1; if (Digits==3 || Digits==5) pipMultiplier =10;

   //
   //
   //
   //
   //
      
   if (calculateValue || timeFrame == Period())
   {
      for (int i = limit; i >= 0; i--)
      {   
         double thigh1 = High[iHighest(NULL, 0, MODE_HIGH, SlowLength,i)] + SlowPipDisplace*Point*pipMultiplier;
         double tlow1  = Low[iLowest(NULL, 0, MODE_LOW, SlowLength,i)]    - SlowPipDisplace*Point*pipMultiplier;
         double thigh2 = High[iHighest(NULL, 0, MODE_HIGH, FastLength,i)] + FastPipDisplace*Point*pipMultiplier;
         double tlow2  = Low[iLowest(NULL, 0, MODE_LOW, FastLength,i)]    - FastPipDisplace*Point*pipMultiplier;
            if (Close[i]>line1[i+1])
                  line1[i] = tlow1;
            else  line1[i] = thigh1;             
            if (Close[i]>line2[i+1])
                  line2[i] = tlow2;
            else  line2[i] = thigh2;             
            
            //
            //
            //
            //
            //
            
            hist1[i] = EMPTY_VALUE;
            hist2[i] = EMPTY_VALUE;
            arrou[i] = EMPTY_VALUE;
            arrod[i] = EMPTY_VALUE;
            trena[i] = trena[i+1];
            trend[i] = 0;
               if (Close[i]<line1[i] && Close[i]<line2[i]) trend[i] =  1;
               if (Close[i]>line1[i] && Close[i]>line2[i]) trend[i] = -1;
               if (line1[i]>line2[i] || trend[i] ==  1)    trena[i] =  1;
               if (line1[i]<line2[i] || trend[i] == -1)    trena[i] = -1;
               if (trend[i]== 1) { hist1[i] = High[i]; hist2[i] = Low[i]; }
               if (trend[i]==-1) { hist2[i] = High[i]; hist1[i] = Low[i]; }
               if (trena[i]!=trena[i+1])
                  if (trena[i] == 1) 
                        arrod[i] = MathMax(line1[i],line2[i]);
                  else  arrou[i] = MathMin(line1[i],line2[i]);                        
      }
      return(0);
   }      

   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         line1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,0,y);
         line2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,1,y);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,6,y);
         trena[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SlowLength,SlowPipDisplace,FastLength,FastPipDisplace,7,y);
         hist1[i] = EMPTY_VALUE;
         hist2[i] = EMPTY_VALUE;
         arrou[i] = EMPTY_VALUE;
         arrod[i] = EMPTY_VALUE;
               if (trend[i]== 1) { hist1[i] = High[i]; hist2[i] = Low[i]; }
               if (trend[i]==-1) { hist2[i] = High[i]; hist1[i] = Low[i]; }
               if (trena[i]!=trena[i+1])
                  if (trena[i] == 1) 
                        arrod[i] = MathMax(line1[i],line2[i]);
                  else  arrou[i] = MathMin(line1[i],line2[i]);                        
   }
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