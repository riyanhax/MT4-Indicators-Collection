//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 LimeGreen
#property indicator_color2 PaleVioletRed
#property indicator_color3 PaleVioletRed
#property indicator_color4 LimeGreen
#property indicator_color5 PaleVioletRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT

//
//
//
//
//

extern int    HalfLength = 12;
extern int    Price      = PRICE_CLOSE;
extern double ATRMultiplier   = 2.0;
extern int    ATRPeriod       = 100;
extern bool   alertsOn        = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

double buffer1[];
double buffer2a[];
double buffer2b[];
double bandUp[];
double bandDn[];
double slope[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int init()
{
   HalfLength=MathMax(HalfLength,1);
   IndicatorBuffers(6);
   SetIndexBuffer(0,buffer1);  SetIndexDrawBegin(0,HalfLength);
   SetIndexBuffer(1,buffer2a); SetIndexDrawBegin(1,HalfLength);
   SetIndexBuffer(2,buffer2b); SetIndexDrawBegin(2,HalfLength);
   SetIndexBuffer(3,bandUp);   SetIndexDrawBegin(3,HalfLength);
   SetIndexBuffer(4,bandDn);   SetIndexDrawBegin(4,HalfLength);
   SetIndexBuffer(5,slope);
   return(0);
}
int deinit() { return(0); }




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
   int counted_bars=IndicatorCounted();
   int i,j,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars+HalfLength,Bars-1);

   //
   //
   //
   //
   //
   
   if (slope[limit]==-1) CleanPoint(limit,buffer2a,buffer2b);
   for (i=limit;i>=0;i--)
   {
      double sum  = (HalfLength+1)*iMA(NULL,0,1,0,MODE_SMA,Price,i);
      double sumw = (HalfLength+1);
      for(j=1, k=HalfLength; j<=HalfLength; j++, k--)
      {
         sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i+j);
         sumw += k;
         if (j<=i)
         {
            sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i-j);
            sumw += k;
         }
      }
      double range = iATR(NULL,0,ATRPeriod,i+10)*ATRMultiplier;
      buffer1[i]  = sum/sumw;  
      bandUp[i]   = buffer1[i]+range;
      bandDn[i]   = buffer1[i]-range;
      buffer2a[i] = EMPTY_VALUE;
      buffer2b[i] = EMPTY_VALUE;
      slope[i]    = slope[i+1];
         if (buffer1[i]>buffer1[i+1]) slope[i] =  1;
         if (buffer1[i]<buffer1[i+1]) slope[i] = -1;
         if (slope[i]==-1) PlotPoint(i,buffer2a,buffer2b,buffer1);
   }
   manageAlerts();
   return(0);
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
      if (slope[0] == 1) doAlert("up");
      if (slope[0] ==-1) doAlert("down");
   }
}

//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   string message;
   
   if (previousAlert != doWhat ) {
       previousAlert  = doWhat;

       //
       //
       //
       //
       //

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" TMA slope is currently "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TMA centered & bands "),message);
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