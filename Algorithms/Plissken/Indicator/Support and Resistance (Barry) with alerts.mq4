//+------------------------------------------------------------------+
//|                                          Support and Resistance  |
//|                                 Copyright © 2004  Barry Stander  |
//|                          http://myweb.absa.co.za/stander/4meta/  |
//+------------------------------------------------------------------+
#property copyright "Click here: Barry Stander // mod. ForexBaron.net"
#property link      "http://myweb.absa.co.za/stander/4meta/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

int     AlertCandle         = 1;
extern bool    ShowChartAlerts     = true;                                              
extern string  AlertEmailSubject   = "";   
extern bool    SendPushNotification = false;
extern bool    SoundAlerts          = false;
extern string  SoundFileUp          = "alert.wav";
extern string  SoundFileDown        = "alert2.wav";
extern int     BarCount            = 1000;               
extern int     SignalAtBlueDot = 3;
extern int     SignalAtRedDot = 3;
extern bool    ShowDotsOnScreen = true;

datetime       OldTime;
datetime       LastAlertTime       = -999999;                                            
string         AlertTextCrossUp    = "Barry Blue Support";                          
string         AlertTextCrossDown  = "Barry Red Resistance";                        


//---- buffers
double v1[];
double v2[];
double val1;
double val2;
int i;
int counter1;
int counter2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
  {
//---- drawing settings
   SetIndexArrow(0, 119);
   SetIndexArrow(1, 119);
//----  
   SetIndexStyle(0, DRAW_ARROW, STYLE_DOT, 1);
   SetIndexDrawBegin(0, i-1);
   SetIndexBuffer(0, v1);
   SetIndexLabel(0,"Resistance");
//----    
   SetIndexStyle(1,DRAW_ARROW,STYLE_DOT,1);
   SetIndexDrawBegin(1,i-1);
   SetIndexBuffer(1, v2);
   SetIndexLabel(1,"Support");
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  { 
   //i = Bars;
   i = BarCount;   
   while(i >= 0)
     {   
       val1 = iFractals(NULL, 0, MODE_UPPER, i);
       //----
       if(val1 > 0)
       { 
           v1[i] = High[i];
           counter1 = 1;
       }
       else
       {
           v1[i] = v1[i+1];
           counter1++;
       }
       val2 = iFractals(NULL, 0, MODE_LOWER, i);
       //----
       if(val2 > 0)
       { 
           v2[i] = Low[i];
           counter2 = 1;
       }
       else
       {
           v2[i] = v2[i+1];
           counter2++;
       }
       i--;
     }
    if(ShowDotsOnScreen == true)
    {
     Comment("Current Number of Blue Dots :   ",counter2,
             "\nCurrent Number of Red Dots :   ",counter1);   
    }
   ProcessAlerts();
   return(0);
  }
//+------------------------------------------------------------------+
int ProcessAlerts()   
{

  if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   
  {                
    if (counter2 == SignalAtBlueDot)  
    {                                                           
      string AlertText = Symbol() + "," + TFToStr(Period()) + ": " + AlertTextCrossUp;                                                          
      if (ShowChartAlerts)          Alert(AlertText);                                                                                           
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if (SendPushNotification)     SendNotification(AlertText);
      if (SoundAlerts)               PlaySound(SoundFileUp);                                                                      
    }                                                                                                                                           
                                                                                                                                                
    if (counter1 == SignalAtRedDot)  
    {                                                       
      AlertText = Symbol() + "," + TFToStr(Period()) + ": " + AlertTextCrossDown;                                                               
      if (ShowChartAlerts)          Alert(AlertText);                                                                                           
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);
      if (SendPushNotification)     SendNotification(AlertText);
      if (SoundAlerts)               PlaySound(SoundFileDown);                                                                      
    }                                                                                                                                           
                                                                                                                                                
    LastAlertTime = Time[0];                                                                                                                    
  }                                                                                                                                             
  return(0);                                                                                                                                    
}        


string TFToStr(int tf)  
{
  if (tf == 0)        tf = Period();                                                                                                            
  if (tf >= 43200)    return("MN");                                                                                                             
  if (tf >= 10080)    return("W1");                                                                                                             
  if (tf >=  1440)    return("D1");                                                                                                             
  if (tf >=   240)    return("H4");                                                                                                             
  if (tf >=    60)    return("H1");                                                                                                             
  if (tf >=    30)    return("M30");                                                                                                            
  if (tf >=    15)    return("M15");                                                                                                            
  if (tf >=     5)    return("M5");                                                                                                             
  if (tf >=     1)    return("M1");                                                                                                             
  return("");                                                                                                                                   
}  