//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrOrange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property strict

enum enTimeFrames
{
   tf_cu  = 0,              // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mb1 = PERIOD_MN1      // Monthly
};

extern enTimeFrames TimeFrame       = tf_cu;        // Time frame
extern int          Kijun           = 26;           // Kijun period
extern bool         alertsOn        = true;         // Turn alerts on?
extern bool         alertsOnCurrent = false;        // Alerts on still opened bar?
extern bool         alertsMessage   = true;         // Alerts should show popup message?
extern bool         alertsSound     = false;        // Alerts should play a sound?
extern bool         alertsEmail     = false;        // Alerts should send email?
extern bool         alertsNotify    = false;        // Alerts should send notification?
extern string       soundFile       = "alert2.wav"; // Alert sound file type
extern bool         Interpolate     = false;         // Interpolate in mtf mode

double ks[];
double ksDa[];
double ksDb[];
double slope[];
string indicatorFileName;
bool   returnBars;

int init()
{
  IndicatorBuffers(4);
  SetIndexBuffer(0,ks);
  SetIndexBuffer(1,ksDa);
  SetIndexBuffer(2,ksDb);
  SetIndexBuffer(3,slope);
   
  indicatorFileName = WindowExpertName();
  returnBars        = TimeFrame==-99; 
  TimeFrame         = MathMax(TimeFrame,_Period);
   
  IndicatorShortName(timeFrameToString(TimeFrame)+" Kijun-Sen price cross"); 

  return(0);
}

int deinit() { return(0);}

int start()
{
  int i,counted_bars=IndicatorCounted();
  int limit;
  if(counted_bars < 0) return(-1);
  if(counted_bars > 0) counted_bars--;
  limit = fmin(Bars-counted_bars,Bars-1);
  if (returnBars) 
  { 
    ks[0] = fmin(limit+1,Bars-1); return(0); 
  }
  
  if (TimeFrame==Period())
  { 
    if (slope[limit]==-1) CleanPoint(limit,ksDa,ksDb);
    
    for (i=limit; i>=0; i--)
    {
      if (i>=Bars-Kijun) continue;
      double khi = High[i];
      double klo = Low[i];
      for (int k = 1; k<Kijun; k++)
      {
        if(khi<High[i+k]) khi = High[i+k];
        if(klo>Low[i+k])  klo =  Low[i+k];
      }
      if ((khi+klo) > 0.0) ks[i] = (khi+klo)*0.5; 
      else ks[i] = 0;
      ksDa[i]  = EMPTY_VALUE;
      ksDb[i]  = EMPTY_VALUE;
      slope[i] = (i<Bars-1) ? (ks[i]>ks[i+1]) ? 1 : (ks[i]<ks[i+1]) ? -1 : slope[i+1] : 0;            
      if (slope[i] == -1)  PlotPoint(i,ksDa,ksDb,ks);
    }
      
    if (alertsOn)
    {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (slope[whichBar] != slope[whichBar+1])
      if (slope[whichBar] == 1) doAlert("sloping up");
      else  doAlert("sloping down");       
    }
    return(0);
  }
 
  limit = (int)fmax(limit,fmin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-98,0,0)*TimeFrame/Period()));
  for (i=limit; i>=0; i--)
  {
    int y = iBarShift(NULL,TimeFrame,Time[i]);
    ks[i]    = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,Kijun,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,soundFile,0,y);
    slope[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,Kijun,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,soundFile,3,y);
    ksDa[i]  = EMPTY_VALUE;
    ksDb[i]  = EMPTY_VALUE;
          
    if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;

    int n,x; datetime time = iTime(NULL,TimeFrame,y);
    for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
    for(x = 1; i+n < Bars && i+x < Bars && x < n; x++) ks[i+x] = ks[i] + (ks[i+n] - ks[i])* x/n;
  }
  for (i=limit;i>=0;i--) if (slope[i] == -1)  PlotPoint(i,ksDa,ksDb,ks); 
 
  return(0);
}

void CleanPoint(int i,double& first[],double& second[])
{
  if (i>=Bars-3) return;
  if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE)) second[i+1] = EMPTY_VALUE;
  else if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE)) first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
  if (i>=Bars-2) return;
  if (first[i+1] == EMPTY_VALUE)
  if (first[i+2] == EMPTY_VALUE) { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
  else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
  else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
  for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
  if (tf==iTfTable[i]) return(sTfTable[i]); return("");
}

void doAlert(string doWhat)
{
  static string   previousAlert="nothing";
  static datetime previousTime;
  string message;
   
  if (previousAlert != doWhat || previousTime != Time[0]) 
  {
    previousAlert  = doWhat;
    previousTime   = Time[0];
       
    message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(_Period)+" Kijun-Sen ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Kijun-Sen "),message);
          if (alertsSound)   PlaySound(soundFile);
   }
}

     
    