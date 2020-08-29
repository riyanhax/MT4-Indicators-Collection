//+------------------------------------------------------------------+
//|                                                 tcf smoothed.mq4 |
//|                                                           mladen |
//|                                                                  |
//| Trend Continuation Factor originaly developed by M.H. Pee        |
//| TASC : 20:3 (March 2002) article                                 |
//| "Just How Long Will A Trend Go On? Trend Continuation Factor"    |
//+------------------------------------------------------------------+

#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 DarkOrange

//
//
//
//
//

extern string TimeFrame   = "Current time frame";
extern int    Length      = 35;
extern int    Price       = PRICE_CLOSE;
extern int    T3Period    = 8;
extern double T3Hot       = 0.7;
extern bool   T3Original  = false;
extern bool   alertsOn         = true;           // Turn alerts on?
extern bool   alertsOnCurrent  = false;          // Alerts on currnt (still opened) bar?
extern bool   alertsMessage    = true;           // Alerts should show pop-up message
extern bool   alertsSound      = true;           // Alerts should play a sound?
extern bool   alertsEmail      = false;          // Alerts should send email?
extern bool   alertsNotify     = false;          // Alerts should send push notification?

//
//
//
//
//

bool   calculatingTcf = false;
bool   returningBars  = false;

int    timeFrame;
string IndicatorFileName;
double TcfUp[];
double TcfDo[],trend[];
double values[][16];
double alpha;
double c1;
double c2;
double c3;
double c4;

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
   IndicatorBuffers(3);
   SetIndexBuffer(0,TcfUp);
   SetIndexBuffer(1,TcfDo);
   SetIndexBuffer(2,trend);
      if (TimeFrame=="calculateTcf")
         {
            calculatingTcf = true;
         
            //
            //
            //
            //
            //
               
            double a  = T3Hot;
                   c1 = -a*a*a;
                   c2 =  3*(a*a+a*a*a);
                   c3 = -3*(2*a*a+a+a*a*a);
                   c4 = 1+3*a+a*a*a+3*a*a;

                  T3Period = MathMax(1,T3Period);
                  if (T3Original)
                       alpha = 2.0/(1.0 + T3Period);
                  else alpha = 2.0/(2.0 + (T3Period-1.0)/2.0);
            return(0);
         }            
      if (TimeFrame=="returnBars")
         {
            returningBars = true;
            return(0);
         }            

   //
   //
   //    
   //
   //
   
   timeFrame = stringToTimeFrame(TimeFrame);
   IndicatorFileName = WindowExpertName();
   IndicatorShortName("Tcf smoothed "+TimeFrameToString(timeFrame)+" ("+Length+","+T3Period+","+DoubleToStr(T3Hot,Digits)+")");
   
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

#define plus_ch   0
#define minus_ch  1
#define plus_cf   2
#define minus_cf  3
#define start_sup 4
#define start_sdo 10

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (returningBars)  { TcfUp[0] = limit;    return(0); }
         if (calculatingTcf) { CalculateTcf(limit); return(0); }

   //
   //
   //
   //
   //
   
      if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,IndicatorFileName,"returnBars",0,0)*timeFrame/Period()));

      //
      //
      //
      //
      //
   
   	for(i = limit; i >= 0; i--)
      {
         int      shift1 = iBarShift(NULL,timeFrame,Time[i]);
         datetime time1  = iTime    (NULL,timeFrame,shift1);
   
            TcfUp[i] = iCustom(NULL,timeFrame,IndicatorFileName,"calculateTcf",Length,Price,T3Period,T3Hot,T3Original,0,shift1);
            TcfDo[i] = iCustom(NULL,timeFrame,IndicatorFileName,"calculateTcf",Length,Price,T3Period,T3Hot,T3Original,1,shift1);

            if(timeFrame <= Period() || shift1==iBarShift(NULL,timeFrame,Time[i-1])) continue;

            //
            //
	         //
            //
            //
		 
            for(int n = 1; i+n < Bars && Time[i+n] >= time1; n++) continue;	
            double factor = 1.0 / n;
            for(int k = 1; k < n; k++)
            {
    	          TcfUp[i+k] = k*factor*TcfUp[i+n] + (1.0-k*factor)*TcfUp[i];
    	          TcfDo[i+k] = k*factor*TcfDo[i+n] + (1.0-k*factor)*TcfDo[i];
            }    	          
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

void CalculateTcf(int limit)
{
   if (ArrayRange(values,0) != Bars) ArrayResize(values,Bars);
   int i,r;
   for(i=limit, r=Bars-limit-1; i>=0; i--,r++)
   {
      values[r][plus_ch]  = 0;
      values[r][minus_ch] = 0;
      values[r][plus_cf]  = 0;
      values[r][minus_cf] = 0;
         double plusTcf   = 0;
         double minusTcf  = 0;
         double roc       = iMA(NULL,0,1,0,MODE_SMA,Price,i)-iMA(NULL,0,1,0,MODE_SMA,Price,i+1);

         //
         //
         //
         //
         //
         
            if (roc>0)
               {
                  values[r][plus_ch] = roc;
                  values[r][plus_cf] = roc;
                     if (r>1) values[r][plus_cf] += values[r-1][plus_cf];
               }                  
            if (roc<0)
               {
                  values[r][minus_ch] = -roc;
                  values[r][minus_cf] = -roc;
                     if (r>1) values[r][minus_cf] += values[r-1][minus_cf];
               }
            for (int l=0; l<Length; l++)
               {
                  plusTcf  += values[r-l][plus_ch]-values[r-l][minus_cf];
                  minusTcf += values[r-l][minus_ch]-values[r-l][plus_cf];
               }
         
         //
         //
         //
         //
         //
         
         if (T3Period>1)
               { TcfUp[i] = iT3(plusTcf ,r,start_sup); TcfDo[i] = iT3(minusTcf,r,start_sdo);  }               
         else  { TcfUp[i] = plusTcf;                   TcfDo[i] = minusTcf;                   }               
         trend[i] = (TcfUp[i]>TcfDo[i]) ? 1 : (TcfUp[i]<TcfDo[i]) ? -1 : trend[i+1];
   }      
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      static datetime time1 = 0;
      static string   mess1 = "";
      if (trend[i]!=trend[i+1])
      {
         if (trend[i]== 1) doAlert(time1,mess1,0,"up");
         if (trend[i]==-1) doAlert(time1,mess1,0,"down");
      }   
   }      
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," tcf state changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," tcf"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double iT3(double price,int i,int s)
{
   if (i < 1)
      {
         values[i][s+0] = price;
         values[i][s+1] = price;
         values[i][s+2] = price;
         values[i][s+3] = price;
         values[i][s+4] = price;
         values[i][s+5] = price;
      }
   else
      {
         values[i][s+0] = values[i-1][s+0]+alpha*(price         -values[i-1][s+0]);
         values[i][s+1] = values[i-1][s+1]+alpha*(values[i][s+0]-values[i-1][s+1]);
         values[i][s+2] = values[i-1][s+2]+alpha*(values[i][s+1]-values[i-1][s+2]);
         values[i][s+3] = values[i-1][s+3]+alpha*(values[i][s+2]-values[i-1][s+3]);
         values[i][s+4] = values[i-1][s+4]+alpha*(values[i][s+3]-values[i-1][s+4]);
         values[i][s+5] = values[i-1][s+5]+alpha*(values[i][s+4]-values[i-1][s+5]);
      }
   return(c1*values[i][s+5] + c2*values[i][s+4] + c3*values[i][s+3] + c4*values[i][s+2]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringUpperCase(tfs);
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf<Period()) tf=Period();
  return(tf);
}
string TimeFrameToString(int tf)
{
   string tfs="";
   
   if (tf!=Period())
      switch(tf) {
         case PERIOD_M1:  tfs="M1"  ; break;
         case PERIOD_M5:  tfs="M5"  ; break;
         case PERIOD_M15: tfs="M15" ; break;
         case PERIOD_M30: tfs="M30" ; break;
         case PERIOD_H1:  tfs="H1"  ; break;
         case PERIOD_H4:  tfs="H4"  ; break;
         case PERIOD_D1:  tfs="D1"  ; break;
         case PERIOD_W1:  tfs="W1"  ; break;
         case PERIOD_MN1: tfs="MN1";
      }
   return(tfs);
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      tchar;
   
   while(lenght >= 0)
      {
         tchar = StringGetChar(s, lenght);
         
         //
         //
         //
         //
         //
         
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                  s = StringSetChar(s, lenght, tchar - 32);
         else 
              if(tchar > -33 && tchar < 0)
                  s = StringSetChar(s, lenght, tchar + 224);
         lenght--;
   }
   
   //
   //
   //
   //
   //
   
   return(s);
}