/*
вызов из пользовательских кодов:

iCustom(NULL,0,"_Volatility_FBA_NR",Source,SourcePeriod,FrontPeriod,BackPeriod,Sens, 0,i); // волатильность
iCustom(NULL,0,"_Volatility_FBA_NR",Source,SourcePeriod,FrontPeriod,BackPeriod,Sens, 1,i); // сигнальная
*/
#property indicator_separate_window 
#property indicator_buffers 2
#property indicator_color1 Green // VLT
#property indicator_color2 Red // сигнальная
#property indicator_minimum 0

// входные параметры
   // VLT
extern int Source=1; // источник: 0 - объем, 1 - ATR, 2 - ст.девиация
extern int SourcePeriod=22; // период источника
   // сигнальная
extern double FrontPeriod=1; // период сглаживания фронта; м.б. <1
extern double BackPeriod=444; // период сглаживания затухания; м.б. <1
   // порог
extern int Sens=0; // порог чувствительности в пп. или в тиках (для объема)

 int History=0; // кол-во пересчетов; 0 - все бары

// инд.буферы
double   VLT[], // волатильность
         EMA[]; // сигнальная

// общие переменные
bool first=1; // флаг первого запуска
double per0,per1; // коэфф-ты EMA
int FBA=0; // 1 - сглаживание фронта, -1 - сглаживание затухания, 0 - обычная MA - гладим все!
double sens; // порог чувствительности в ценах

int init()
  {
   first=1;
   
   // короткое имя
      // разрядности коэффициентов для EMA
   int fdg,bdg; 
   if(FrontPeriod<1) fdg=2; if(BackPeriod<1) bdg=2;
   string _fr=DoubleToStr(FrontPeriod,fdg);
   string _bk=DoubleToStr(BackPeriod,bdg);
      // чувствительность
   if(Sens>0) string ShortName=Sens+" "; 
      // источник
   string _src;
   switch(Source) {
      case 0: _src="Volume"; break; // объем
      case 1: _src="ATR"; break; // ATR
      case 2: _src="StDev"; // ст.девиация
     }
   _src=_src+"(";
   ShortName=ShortName+_src+SourcePeriod+")";
      // фронт и затухание
   if(FrontPeriod!=1 || BackPeriod!=1) {
      if(FrontPeriod==BackPeriod) ShortName=ShortName+" ("+_fr+")";
      else {
         if(FrontPeriod!=1) ShortName=ShortName+" Front("+_fr+")";
         if(BackPeriod!=1)  ShortName=ShortName+" Back(" +_bk+")";
        }
     }
   IndicatorShortName(ShortName); 

   //
   if(Source>0) sens=Sens*Point; // порог чувствительности в ценах
   else sens=Sens; // в тиках

   if(FrontPeriod>1) FrontPeriod=2.0/(1+FrontPeriod); // коэфф. предварительной EMA
   if(BackPeriod>1) BackPeriod=2.0/(1+BackPeriod); // коэфф. раздельной EMA
   while(true) {
      if(FrontPeriod==BackPeriod) {
         per0=FrontPeriod; per1=1; break;
        }
      if(FrontPeriod>BackPeriod) {
         FBA=-1; per0=FrontPeriod; per1=BackPeriod;
        }
      else {
         FBA= 1; per0=BackPeriod; per1=FrontPeriod;
        }
      break;
     }

   // инд. буферы   
   // VLT
   SetIndexBuffer(0,VLT);
   SetIndexStyle(0,DRAW_LINE,0);
   SetIndexLabel(0,_src+SourcePeriod+")");
   // сигнальная
   SetIndexBuffer(1,EMA);
   SetIndexStyle(1,DRAW_LINE,0);
   SetIndexLabel(1,"EMA("+_fr+","+_bk+")");

   // порог чувствительности
   SetLevelValue(0,sens);

   return(0);
  }


int reinit() // ф-я дополнительной инициализации
  {
   ArrayInitialize(VLT,0.0);
   ArrayInitialize(EMA,0.0);
   first=1;

   return(0);
  }

int start()
  {
   int ic=IndicatorCounted();
   if(!first && Bars-ic-1>1) ic=reinit(); 
   int limit=Bars-ic-1; // кол-во пересчетов
   if(History!=0 && limit>History) limit=History-1; // кол-во пересчетов по истории

   for(int i=limit; i>=0; i--) { // цикл пересчета по ВСЕМ барам
      bool reset=i==limit && ic==0; // сброс на первой итерации цикла пересчета

      if(reset) {static double MA0prev=0,MA1prev=0; static int BarsPrev=0;}
      
      // VLT
      switch(Source) {
         case 0: 
            double ma=VLT[i+1]*SourcePeriod-Volume[i+SourcePeriod];
            VLT[i]=(ma+Volume[i])/SourcePeriod;
            break;
         case 1: VLT[i]=iATR(NULL,0,SourcePeriod, i); break; // ATR
         case 2: VLT[i]=iStdDev(NULL,0,SourcePeriod,0,0,0, i);  // ст.девиация
        }
      double vlt=VLT[i];

      // предварительное сглаживание
      double MA0=EMA_FBA(vlt,MA0prev,per0,0,i);
      
      // раздельное сглаживание (сигнальная)
      double MA1=EMA_FBA(MA0,MA1prev,per1,FBA,i); 

      // учет порога
      EMA[i]=MathMax(MA1,sens);
      
      // синхронизация
      if(first || BarsPrev!=Bars) {BarsPrev=Bars; MA0prev=MA0; MA1prev=MA1;}

     }   

   first=0; // сброс флага первого запуска
   return(0);
  }

// EMA с различными параметрами сглаживания для фронта и затухания
double EMA_FBA(double C, double MA1, double period, int FBA, int i) {
   if(period==1) return(C);
   // коэфф. EMA 
   if(period>1) period=2.0/(1+period); 
   // EMA
   double ma=period*C+(1-period)*MA1; 
   // разделение фронта и затухания
   switch(FBA) {
      case  0: // обычная MA
         if(FBA==0) return(ma); 
      case  1: // сглаживание фронта
         if(C>MA1) return(ma); else return(C); 
      case -1: // сглаживание затухания
         if(C<MA1) return(ma); else return(C); 
     }
  }

