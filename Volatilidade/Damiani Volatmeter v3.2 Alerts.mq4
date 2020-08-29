//+------------------------------------------------------------------+
//|                               Damiani Volatmeter v3.2 Alerts.mq4 |
//|      this is the alerts version of   Damiani_volatmeter.mq4 v3.2 |
//|                     Copyright © 2006,2007 Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//|                                                                  |
//|   14.12.2013: alerts/buffer for iCustom by http://ForexBaron.net |
//+------------------------------------------------------------------+
/*
  TO USE THIS INDICATOR WITH iCustom:
  
   buffer 3 values: EMPTY_VALUE=no signal / 1.0 = TRADE OK / 2.0 = DO NOT TRADE (low volatility)
   example for an iCustom-call:
   double volatmeter = iCustom(Symbol(),0,"Damiani Volatmeter v3.2 Alerts","",Vis_atr,Vis_std,Sed_atr,Sed_std,Threshold_level,true,lag_s_K,max_bars,"",false,false,false,false,"","",3,CandleShift);
   if (volatmeter==1.0) Print("TRADE OK");
    else Print("DO NOT TRADE"); //or: if (volatmeter==2.0||volatmeter==EMPTY_VALUE) Print("DO NOT TRADE");
*/

#property copyright "Copyright © 2006,2007 Luis Guilherme Damiani, alerts by ForexBaron.net"
#property link      "http://www.damianifx.com.br"

#property indicator_separate_window
#property indicator_buffers 4//
#property indicator_color1 Silver
#property indicator_color2 FireBrick
#property indicator_color3 Lime
#property indicator_minimum 0

//---- input parameters
extern string dh="default:13,20,40,100,1.4,true,0.5,2000";
extern int       Vis_atr=13;//13;
extern int       Vis_std=20;//20;
extern int       Sed_atr=40;//40;
extern int       Sed_std=100;//100;
extern double    Threshold_level=1.4;//1.4;
//
extern bool      lag_supressor=true;//true;
extern double    lag_s_K=0.5;//0.5;
//
extern int max_bars=2000;//2000;

//alert stuff, fxdaytrader (http://forexBaron.net)
extern string ahi="******* ALERT SETTINGS:";
extern bool   PopupAlerts            = true;
extern bool   EmailAlerts            = false;
extern bool   PushNotificationAlerts = false;
extern bool   SoundAlerts            = false;
extern string SoundFileTradeAllowed  = "alert.wav";
extern string SoundFileDoNotTrade    = "alert2.wav";
int lastAlert=3;
//end alert stuff

//---- buffers
double thresholdBuffer[];
double vol_m[];
double vol_t[];
//double ind_c[];

double SignalBuffer[];//this buffer can be read by an expert advisor, fxdaytrader

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,thresholdBuffer);
   SetIndexLabel(0,"SignalLine");
   
   SetIndexStyle(1,DRAW_LINE,DRAW_LINE,4);
   SetIndexBuffer(1,vol_m);
   SetIndexLabel(1,"VOL_m");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,vol_t);
   SetIndexLabel(2,"Volatmeter");
   
   SetIndexBuffer(3,SignalBuffer);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   
   //ArrayResize(ind_c,Bars);
  // ArrayInitialize(ind_c,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   double vol=0;
   
   int    not_changed_bars=IndicatorCounted();
   if(not_changed_bars<0)return(-1);
   if(not_changed_bars>0)not_changed_bars--;
   //Comment("ATR ratio= "+short_atr+" / "+long_atr);
   int changed_bars=Bars-not_changed_bars;
   int loop_size;
   int max_per=MathMax(Sed_atr,Sed_std);
   if (changed_bars>max_per+5)loop_size=changed_bars-max_per;
   else 
      loop_size=changed_bars;
  /* Comment(DoubleToStr(ind_c[0],Digits)+"/ "+ DoubleToStr(ind_c[1],Digits)+"/ "+ DoubleToStr(ind_c[2],Digits)+"/ "+ DoubleToStr(ind_c[3],Digits)
   +"/ "+ DoubleToStr(ind_c[4],Digits)+"/ "+ DoubleToStr(ind_c[5],Digits)+"/ "+ DoubleToStr(ind_c[6],Digits)+"/ "+ DoubleToStr(ind_c[7],Digits)
   +"/ "+ DoubleToStr(ind_c[8],Digits)+"/ "+ DoubleToStr(ind_c[9],Digits)+"/ "+ DoubleToStr(ind_c[10],Digits)+"/ "+ DoubleToStr(ind_c[11],Digits)+"\n"
   +DoubleToStr(ind_c[12],Digits)+"/ "+ DoubleToStr(ind_c[13],Digits)+"/ "+ DoubleToStr(ind_c[14],Digits)+"/ "+ DoubleToStr(ind_c[15],Digits)
   +"/ "+ DoubleToStr(ind_c[16],Digits)+"/ "+ DoubleToStr(ind_c[17],Digits)+"/ "+ DoubleToStr(ind_c[18],Digits)+"/ "+ DoubleToStr(ind_c[19],Digits)
   +"/ "+ DoubleToStr(ind_c[20],Digits)+"/ "+ DoubleToStr(ind_c[21],Digits)+"/ "+ DoubleToStr(ind_c[22],Digits)+"/ "+ DoubleToStr(ind_c[23],Digits)
   );*/
   
   for(int i=loop_size;i>=0;i--)
   {
      
      double sa=iATR(NULL,0,Vis_atr,i);
      double s1=vol_t[i+1];//ind_c[i+1];
      double s3=vol_t[i+3];//ind_c[i+3];
      double atr=NormalizeDouble(sa,Digits);
      if(lag_supressor)
         vol= sa/iATR(NULL,0,Sed_atr,i)+lag_s_K*(s1-s3);   
      else
         vol= sa/iATR(NULL,0,Sed_atr,i);   
      //vol_m[i]=vol;
      
      double anti_thres=iStdDev(NULL,0,Vis_std,0,MODE_LWMA,PRICE_TYPICAL,i);
      double std=NormalizeDouble(anti_thres,Digits);
      anti_thres=anti_thres/   
                 iStdDev(NULL,0,Sed_std,0,MODE_LWMA,PRICE_TYPICAL,i);
                        
      double t=Threshold_level;
      t=t-anti_thres;
      
      if(i==0)
      {       
         if (vol>t){
             if (lastAlert!=2) doAlerts("TRADE ALLOWED AGAIN - VOLATILITY OK!",SoundFileTradeAllowed); lastAlert=2;//alert stuff
             SignalBuffer[0]=1.0;//set buffer
             IndicatorShortName("Damiani: TRADE "
             +" A("+ DoubleToStr(Vis_atr,0) +"/"+ DoubleToStr(Sed_atr,0) +")= "+DoubleToStr(vol,2)+ ", "
             +DoubleToStr(Threshold_level,1)+" - S("+ DoubleToStr(Vis_std,0)+"/"+ DoubleToStr(Sed_std,0)  +")= "+DoubleToStr(t,2)+" ");}
         else {
             if (lastAlert!=1) doAlerts("DO NOT TRADE - LOW VOLATILITY!",SoundFileTradeAllowed); lastAlert=1;//alert stuff
             SignalBuffer[0]=2.0;//set buffer
             IndicatorShortName("Damiani: DO NOT trade "
             +"A("+ DoubleToStr(Vis_atr,0) +"/"+ DoubleToStr(Sed_atr,0) +")= "+DoubleToStr(vol,2)+ ", "
             +DoubleToStr(Threshold_level,1)+" - S("+ DoubleToStr(Vis_std,0)+"/"+ DoubleToStr(Sed_std,0)  +")= "+DoubleToStr(t,2)+" ");}   
      }
      
         if (vol>t){vol_t[i]=vol;vol_m[i]=-1;}
         else {vol_t[i]=vol;vol_m[i]=0.03;}   
      
      // for(int j=0;j<24;j++)ind_c[j]= vol_t[j];
      //ind_c[i]=vol;
      thresholdBuffer[i]=t;   
   }
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

//alert stuff, fxdaytrader (http://forexBaron.net)
void doAlerts(string msg,string SoundFile) {
 static int LastAlertTime=0;
 if (LastAlertTime!=iTime(NULL,0,0)) { 
  LastAlertTime=iTime(NULL,0,0);
  msg="Damiani Volatmeter Alert on "+Symbol()+", period "+TFtoStr(Period())+": "+msg;
  string emailsubject="MT4 alert on acc. "+AccountNumber()+", "+WindowExpertName()+" - Alert on "+Symbol()+", period "+TFtoStr(Period());
  if (PopupAlerts) Alert(msg);
  if (EmailAlerts) SendMail(emailsubject,msg);
  if (PushNotificationAlerts) SendNotification(msg);
  if (SoundAlerts) PlaySound(SoundFile);
 }//if (LastAlertTime!=itime(NULL,0,0) {
}//void doAlerts(string msg,string SoundFile) {

string TFtoStr(int period) {
 switch(period) {
  case 1     : return("M1");  break;
  case 5     : return("M5");  break;
  case 15    : return("M15"); break;
  case 30    : return("M30"); break;
  case 60    : return("H1");  break;
  case 240   : return("H4");  break;
  case 1440  : return("D1");  break;
  case 10080 : return("W1");  break;
  case 43200 : return("MN1"); break;
  default    : return(DoubleToStr(period,0));
 }
 return("UNKNOWN");
}//string TFtoStr(int period) {
//end alert stuff by fxdaytrader