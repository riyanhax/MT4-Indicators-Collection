//+------------------------------------------------------------------+
//|                                           Ticks Volume Indicator |
//|                                   Copyright © William Blau & Tor |
//|                                    Coded/Verified by Profitrader |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Profitrader."
#property link      "profitrader@inbox.ru"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters
extern int r=12;
extern int s=12;
extern int u=5;
extern bool alerts=false;  // alert предполагаемых сделок
extern bool play=false;    // звуковое оповещение
extern bool strelka=true;  // рисовать стрелки ?
extern bool searchHight=true; // искать переломы графика
extern bool NaOtkrytieSvechi=true;  // только на открытии свечи
extern bool AllHights=false; // все переломы или только выпадающие за уровни в настройках  levelUP и levelDOWN
extern int barp=0; // на какой свече смотрим 0 или 1

extern int levelUP=4; // дл€ золота *10
extern int levelDOWN=-4; // дл€ золота *10
//---- buffers
double TVI[];
double UpTicks[];
double DownTicks[];
double EMA_UpTicks[];
double EMA_DownTicks[];
double DEMA_UpTicks[];
double DEMA_DownTicks[];
double TVI_calculate[];
int   tick=0;
datetime lastobject;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   lastobject=Time[0];
   IndicatorShortName("TVI("+r+","+s+","+u+")");
   IndicatorBuffers(8);
   SetIndexBuffer(0,TVI);
   SetIndexBuffer(1,UpTicks);
   SetIndexBuffer(2,DownTicks);
   SetIndexBuffer(3,EMA_UpTicks);
   SetIndexBuffer(4,EMA_DownTicks);
   SetIndexBuffer(5,DEMA_UpTicks);
   SetIndexBuffer(6,DEMA_DownTicks);
   SetIndexBuffer(7,TVI_calculate);
   SetLevelValue(1,levelDOWN);
   SetLevelValue(2,levelUP);
/*   SetLevelValue(3,levelDOWN-1);
   SetLevelValue(4,levelUP+1);
   SetLevelValue(5,levelDOWN-2);
   SetLevelValue(6,levelUP+2);
   SetLevelValue(7,levelDOWN-3);
   SetLevelValue(8,levelUP+3);
   SetLevelValue(9,levelDOWN-4);
   SetLevelValue(10,levelUP+4);*/
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,"TVI");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Ticks Volume Indicator                                           |
//+------------------------------------------------------------------+
int start()
  {
   tick++; static datetime nt=0;
   int i,counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//----
   for(i=0; i<limit; i++)
     {
      UpTicks[i]=(Volume[i]+(Close[i]-Open[i])/Point)/2;
      DownTicks[i]=Volume[i]-UpTicks[i];
     }
   for(i=limit-1; i>=0; i--)
     {
      EMA_UpTicks[i]=iMAOnArray(UpTicks,0,r,0,MODE_EMA,i);
      EMA_DownTicks[i]=iMAOnArray(DownTicks,0,r,0,MODE_EMA,i);
     }
   for(i=limit-1; i>=0; i--)
     {
      DEMA_UpTicks[i]=iMAOnArray(EMA_UpTicks,0,s,0,MODE_EMA,i);
      DEMA_DownTicks[i]=iMAOnArray(EMA_DownTicks,0,s,0,MODE_EMA,i);
     }
   for(i=0; i<limit; i++)
     {
      TVI_calculate[i]=100.0*(DEMA_UpTicks[i]-DEMA_DownTicks[i])/(DEMA_UpTicks[i]+DEMA_DownTicks[i]);
     }
   for(i=limit-1; i>=0; i--)
      TVI[i]=iMAOnArray(TVI_calculate,0,u,0,MODE_EMA,i);

   if(!searchHight && TVI[0+barp]<TVI[1+barp] && TVI[0+barp]>levelUP)
     {
      if(alerts) Alert("можно пробовать ѕ–ќƒј“№ "+Symbol()+"  indicator TVI");
      if(play) PlaySound("expert.wav");
      if(strelka)
        {
         if(Time[0]==nt){ return(0); }
         nt=Time[0];

         if((Time[0]-lastobject)>=Period()*60*1){ StrelkaVniz();  lastobject=Time[0]; }
        }
     }
   if(!searchHight && TVI[0+barp]>TVI[1+barp] && TVI[0+barp]<levelDOWN)
     {
      if(alerts) Alert("можно пробовать  ”ѕ»“№ "+Symbol()+"  indicator TVI");
      if(play) PlaySound("expert.wav");
      if(strelka)
        {
         if(Time[0]==nt){ return(0); }
         nt=Time[0];

         if((Time[0]-lastobject)>=Period()*60*1){ StrelkaVverh();  lastobject=Time[0]; }
        }
     }
   if(AllHights && searchHight && TVI[0+barp]>TVI[1+barp] && TVI[2+barp]>=TVI[1+barp])
     {// && TVI[0]<0 && TVI[1]<0 && TVI[2]<0
      if(alerts) Alert("можно пробовать  ”ѕ»“№ "+Symbol()+"  indicator TVI");
      if(play) PlaySound("expert.wav");
      if(strelka)
        {
         if(NaOtkrytieSvechi){ if(Time[0]==nt){ return(0); }  }
         nt=Time[0];

         if((Time[0]-lastobject)>=Period()*60*1){ StrelkaVverh(); lastobject=Time[0]; }
        }
     }
   if(AllHights && searchHight && TVI[0+barp]<TVI[1+barp] && TVI[2+barp]<=TVI[1+barp])
     { //&& TVI[0]>0 && TVI[1]>0 && TVI[2]>0
      if(alerts) Alert("можно пробовать ѕ–ќƒј“№ "+Symbol()+"  indicator TVI");
      if(play) PlaySound("expert.wav");
      if(strelka)
        {
         if(NaOtkrytieSvechi){ if(Time[0]==nt){ return(0); }  }
         nt=Time[0];

         if((Time[0]-lastobject)>=Period()*60*1){ StrelkaVniz(); lastobject=Time[0]; }
        }
     }
   if(!AllHights && searchHight && TVI[0+barp]>TVI[1+barp] && TVI[2+barp]>=TVI[1+barp] && TVI[0+barp]<levelDOWN)
     {// && TVI[0]<0 && TVI[1]<0 && TVI[2]<0
      if(alerts) Alert("можно пробовать  ”ѕ»“№ "+Symbol()+"  indicator TVI");
      if(play) PlaySound("expert.wav");
      if(strelka)
        {
         if(NaOtkrytieSvechi){ if(Time[0]==nt){ return(0); }  }
         nt=Time[0];

         if((Time[0]-lastobject)>=Period()*60*1){ StrelkaVverh(); lastobject=Time[0]; }
        }
     }
   if(!AllHights && searchHight && TVI[0+barp]<TVI[1+barp] && TVI[2+barp]<=TVI[1+barp] && TVI[0+barp]>levelUP)
     { //&& TVI[0]>0 && TVI[1]>0 && TVI[2]>0
      if(alerts) Alert("можно пробовать ѕ–ќƒј“№ "+Symbol()+"  indicator TVI");
      if(play) PlaySound("expert.wav");
      if(strelka)
        {
         if(NaOtkrytieSvechi){ if(Time[0]==nt){ return(0); }  }
         nt=Time[0];

         if((Time[0]-lastobject)>=Period()*60*1){ StrelkaVniz(); lastobject=Time[0]; }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrelkaVverh()
  {
   ObjectCreate("TVIup"+tick,OBJ_ARROW,0,Time[0],Ask);
   ObjectSet("TVIup"+tick,OBJPROP_COLOR,Blue);
   ObjectSet("TVIup"+tick,OBJPROP_ARROWCODE,SYMBOL_ARROWUP);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrelkaVniz()
  {
   ObjectCreate("TVIdown"+tick,OBJ_ARROW,0,Time[0],Bid);
   ObjectSet("TVIdown"+tick,OBJPROP_COLOR,Red);
   ObjectSet("TVIdown"+tick,OBJPROP_ARROWCODE,SYMBOL_ARROWDOWN);
  }
//+------------------------------------------------------------------+
