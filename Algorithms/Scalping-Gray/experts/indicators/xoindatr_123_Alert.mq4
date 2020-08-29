//+------------------------------------------------------------------+
//|                                                 xoindatr_123.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Blue
#property indicator_color2  Red

extern int Per=14;
extern int count_bars=0; //0 - all bars

extern int     AlertCandle         = 0;                                                                                                         //
extern bool    ShowChartAlerts     = true;                                                                                                     //
extern string  AlertEmailSubject   = "";                                                                                                        //
                                                                                                                                                //
datetime       LastAlertTime       = -999999;                                                                                                   //
                                                                                                                                                //
string         AlertTextCrossUp    = "Color UP";                          
string         AlertTextCrossDown  = "Color DOWN";                          
                                                                                                            

double ExtBuffer1[];
double ExtBuffer2[];
double ExtBuffer3[];
double ExtBuffer4[];
double KirPER[];

double valuel, valueh;
double Kir, Hi, Lo, KirUp, KirDn, cur, kr, no, kk, kn;

int nb;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if (Bars<(count_bars+Per) || count_bars==0) nb=Bars-Per;
   else nb=count_bars;
   IndicatorBuffers(5);
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexDrawBegin(0,Bars-nb);
   SetIndexBuffer(0,ExtBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexDrawBegin(1,Bars-nb);
   SetIndexBuffer(1,ExtBuffer2);
   SetIndexBuffer(2,KirPER);
   SetIndexBuffer(3,ExtBuffer3);
   SetIndexBuffer(4,ExtBuffer4);
   IndicatorDigits(Digits);
   IndicatorShortName("Xoindatr("+Per+")");
   SetIndexLabel(0,"Xoindatr");
   SetIndexLabel(1,"Xoindatr");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//----
   if(counted_bars<0) return(-1);
//----
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//----
   for(int i=0; i<limit; i++)
     {
      KirPER[i]=iATR(NULL,0,Per,i);
     }
//----
   for(i=0; i<Bars; i++)
     {
      ExtBuffer3[i]=0;
      ExtBuffer4[i]=0;
     } 
   for(i=nb-1; i>=0; i--)
     {
      if (Kir<1) 
       {
        Hi=Close[i];
        Lo=Close[i];
        Kir=1;
       }
      cur=Close[i];
      if(cur>(Hi+KirPER[i])) 
       {
        kk=MathCeil((cur-(Hi+KirPER[i]))/(KirPER[i]));
        Kir=Kir+1;
        Hi=cur;
        Lo=cur-KirPER[i];
        KirUp=1;
        KirDn=0;
        kr=kr+kk;
        no=0;
       }
      if(cur<(Lo-KirPER[i]))
       {
        kn=MathCeil(((Lo-KirPER[i])-cur)/(KirPER[i]));
        Lo=cur;
        Hi=cur+KirPER[i];
        KirUp=0;
        KirDn=1;
        Kir=Kir+1;
        no=no+kn;
        kr=0;
       }
      valuel=0-no;
      valueh=kr;
      ExtBuffer3[i]=valueh;
      ExtBuffer4[i]=valuel;
     }
   for(i=0; i<limit; i++)
     {
      ExtBuffer1[i]=ExtBuffer3[i];
      ExtBuffer2[i]=ExtBuffer4[i];
      ExtBuffer1[0]=0;
      ExtBuffer2[0]=0; 
     }   
//----

     ProcessAlerts();      
   return(0);
  }
//+------------------------------------------------------------------+

   int ProcessAlerts()   {                                                                                                                        
//+------------------------------------------------------------------+                                                                          
  if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   {                                                                                       
                                                                                                                                                
                                                      
    if (ExtBuffer3[AlertCandle] > 0 && ExtBuffer3[AlertCandle+2] == 0 )  {                  
      string AlertText = Symbol() + "," + TFToStr(Period()) + ": " + AlertTextCrossUp;                                                         
      if (ShowChartAlerts)          Alert(AlertText);                                                                                           
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);                                                                      
    }                                                                                                                                          
                                                                                                                                                
                                                   
    if (ExtBuffer4[AlertCandle] < 0 && ExtBuffer4[AlertCandle+2] == 0)  {                   
      AlertText = Symbol() + "," + TFToStr(Period()) + ": " + AlertTextCrossDown;                                                              
      if (ShowChartAlerts)          Alert(AlertText);                                                                                          
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);                                                                      
    }                                                                                                                                           //
                                                                                                                                                //
    LastAlertTime = Time[0];                                                                                                                    //
  }                                                                                                                                             //
  return(0);                                                                                                                                    //
}                                                                                                                                               //
                                                                                                                                                //
//+------------------------------------------------------------------+                                                                          //
string TFToStr(int tf)   {                                                                                                                      //
//+------------------------------------------------------------------+                                                                          //
  if (tf == 0)        tf = Period();                                                                                                            //
  if (tf >= 43200)    return("MN");                                                                                                             //
  if (tf >= 10080)    return("W1");                                                                                                             //
  if (tf >=  1440)    return("D1");                                                                                                             //
  if (tf >=   240)    return("H4");                                                                                                             //
  if (tf >=    60)    return("H1");                                                                                                             //
  if (tf >=    30)    return("M30");                                                                                                            //
  if (tf >=    15)    return("M15");                                                                                                            //
  if (tf >=     5)    return("M5");                                                                                                             //
  if (tf >=     1)    return("M1");                                                                                                             //
  return("");                                                                                                                                   //
}                                                                                                                                               //
// ============================================================================================================================================ //

