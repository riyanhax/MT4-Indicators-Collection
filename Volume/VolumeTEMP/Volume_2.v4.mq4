//+------------------------------------------------------------------+
//|                                                  Volume_2.v3.mq4 |
//|                                                  Victor Nicolaev |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Victor Nicolaev"
#property link      "vinin@mail.ru"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 White
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
//---- input parameters

extern int TM= 240; // Расчетный тайм-фрейм
extern int mode=0; //расчетный период: 0 -  неделя, 1 - месяц, 2 - квартал. 3 - год.
extern int MAxPeriodMode=5; //Максимальное число отображаемых расчетных периодов, 0 - все 

//---- buffers
double ExtMapBufferOpen[];
double ExtMapBufferHigh[];
double ExtMapBufferLow[];
double ExtMapBufferClose[];

int K;
int TMf;
double AverageVolume=-1;
datetime StartTime=0, EndTime;
bool start;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   K=1;
   TMf=TM;
   CheckTM(TM,TMf,K);
   start=false;
   StartTime=0;
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexDrawBegin(0,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(3,0);
   SetIndexBuffer(0,ExtMapBufferHigh);
   SetIndexBuffer(1,ExtMapBufferLow);   
   SetIndexBuffer(2,ExtMapBufferOpen);
   SetIndexBuffer(3,ExtMapBufferClose);
    
   IndicatorShortName("Volume("+TM+")");
   SetIndexLabel(0,"Open");
   SetIndexLabel(1,"High");
   SetIndexLabel(2,"Low");
   SetIndexLabel(3,"Close");
//---- initialization done
   return(0); }//int init() 
//+------------------------------------------------------------------+
int start() {
   int limit;
   int counted_bars=IndicatorCounted();
   int i;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   int tmpTime;

   // Расчет первого периода для отрисовки
   if (!start) {
      if(MAxPeriodMode>0) {
         tmpTime=Time[0]+60;
         for (i=0;i<=MAxPeriodMode;i++) {
            CalculateTime(mode, tmpTime, StartTime, EndTime);
            tmpTime=StartTime-60;
         }
         tmpTime=StartTime+1;
         AverageVolume=CalculateVolume(mode, TM, K);
         CalculateTime(mode, tmpTime, StartTime, EndTime);
      }
      start=true;
   }

   for (i = limit;i>=0;i--){
      if (StartTime==0) {
         CalculateTime(mode, Time[i], StartTime, EndTime);
         continue;
      }
      if (Time[i]>EndTime) {
         RefreshBar(i+1);
         AverageVolume=CalculateVolume(mode, TM, K);
         CalculateTime(mode, Time[i], StartTime, EndTime);
      }
      if (AverageVolume>0) RefreshBar(i);
   }
   return(0); }// int start()
   //+------------------------------------------------------------------+

//Отрисовка периода
void RefreshBar(int pos){
   int i;
   int start=iBarShift(NULL,0,StartTime);
   if (Time[start]<StartTime)start--;

   double Vol=0,sVol=0;
   int k=0,is=start;
   for (i=start;i>=pos;i--) {
      if ((MathAbs(sVol-AverageVolume*(k+1))<Volume[i]/2.0)||(sVol-AverageVolume*(k+1)>0)) {
         NevBar(is,i);
         is=i-1;
         k++;
      }
      sVol+=Volume[i];
   }
   if (is>pos) NevBar(is,pos);
}

//Отрисовка бара
void NevBar(int start, int end){
   int i;
   double tmpHigh=High[start],tmpLow=Low[start],tmpOpen=Open[start],tmpClose=Close[end];   
   for (i=start;i>=end;i--) {
      tmpHigh=MathMax(tmpHigh,High[i]);
      tmpLow=MathMin(tmpLow,Low[i]);
   }
   for (i=start;i>=end;i--) {
      ExtMapBufferOpen[i]=tmpOpen;
      ExtMapBufferClose[i]=tmpClose;
      if (tmpOpen>tmpClose) {
         ExtMapBufferHigh[i]=tmpHigh;
         ExtMapBufferLow[i]=tmpLow;
      }
      else {
         ExtMapBufferHigh[i]=tmpLow;
         ExtMapBufferLow[i]=tmpHigh;
      }
   }   
}

void CheckTM(int TMb, int &TMf, int &K) {
   int TMr[]={PERIOD_MN1, PERIOD_W1, PERIOD_D1, PERIOD_H4, PERIOD_H1, PERIOD_M30, PERIOD_M15, PERIOD_M5, PERIOD_M1};
   int i;
   for (i=0;i<9;i++) {
      if (TMb%TMr[i]==0) {
         TMf=TMr[i];
         K=TMb/TMr[i];
         break;
      }
   }
}


double CalculateVolume(int mode, int TM, int K){ 
   double sVol=0.0;
   int    i, sBar=0; 
   int start=iBarShift(NULL,TM,StartTime);
   int end=iBarShift(NULL,TM,EndTime);
   if (iTime(NULL,TM,start)<StartTime) start++;
   if (iTime(NULL,TM,end)<EndTime) end++;
   for (i=start;i>end;i--) {
      sVol+=iVolume(NULL,TM,i);
      sBar++;
   }
   if (sBar>0) sVol/=(start-end)*(K*1.0);
   return(sVol);}

void CalculateTime(int mode, int _Time, int &StartTime, int &EndTime){
   string ss;
   datetime st;
   int start,end;
   int MonthTmp, YearTmp;
   switch (mode) {
      case 0:  {
         int WeekTmp=TimeDayOfWeek(_Time);
         ss=TimeToStr(_Time-WeekTmp*24*60*60,TIME_DATE);
         StartTime=StrToTime(ss);
         ss=TimeToStr(_Time+(8-WeekTmp)*24*60*60,TIME_DATE);
         EndTime=StrToTime(ss);
         EndTime--;
         break;
      }
      case 1: {
         MonthTmp=TimeMonth(_Time);
         YearTmp=TimeYear(_Time);
         ss=TimeYear(_Time)+"."+TimeMonth(_Time)+".01 00:00";
         StartTime=StrToTime(ss);
         if (MonthTmp==12) ss=TimeYear(_Time+365*24*60*60)+".01.01 00:00";
         else ss=TimeYear(_Time)+"."+(TimeMonth(_Time+31*24*60*60))+".01 00:00";
         EndTime=StrToTime(ss);
         EndTime--;
         break;
      }
      case 2: {
         MonthTmp=((TimeMonth(_Time)-1)/3);
         YearTmp=TimeYear(_Time);
         ss=TimeYear(_Time)+"."+(MonthTmp*3+1)+".01 00:00";
         StartTime=StrToTime(ss);
         if (MonthTmp==3) ss=(TimeYear(_Time)+1)+".00.01 00:00";
         else ss=TimeYear(_Time)+"."+((MonthTmp+1)*3+1)+".01 00:00";
         EndTime=StrToTime(ss);
         EndTime--;
         break;
      }
      case 3: {
         YearTmp=TimeYear(_Time);
         ss=TimeYear(_Time)+".01.01 00:00";
         StartTime=StrToTime(ss);
         ss=(TimeYear(_Time)+1)+".01.01 00:00";
         EndTime=StrToTime(ss);
         EndTime--;
         break;
      }
   }
}


