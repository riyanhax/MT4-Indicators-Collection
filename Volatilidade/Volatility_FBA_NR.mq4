/*
����� �� ���������������� �����:

iCustom(NULL,0,"_Volatility_FBA_NR",Source,SourcePeriod,FrontPeriod,BackPeriod,Sens, 0,i); // �������������
iCustom(NULL,0,"_Volatility_FBA_NR",Source,SourcePeriod,FrontPeriod,BackPeriod,Sens, 1,i); // ����������
*/
#property indicator_separate_window 
#property indicator_buffers 2
#property indicator_color1 Green // VLT
#property indicator_color2 Red // ����������
#property indicator_minimum 0

// ������� ���������
   // VLT
extern int Source=1; // ��������: 0 - �����, 1 - ATR, 2 - ��.��������
extern int SourcePeriod=22; // ������ ���������
   // ����������
extern double FrontPeriod=1; // ������ ����������� ������; �.�. <1
extern double BackPeriod=444; // ������ ����������� ���������; �.�. <1
   // �����
extern int Sens=0; // ����� ���������������� � ��. ��� � ����� (��� ������)

 int History=0; // ���-�� ����������; 0 - ��� ����

// ���.������
double   VLT[], // �������������
         EMA[]; // ����������

// ����� ����������
bool first=1; // ���� ������� �������
double per0,per1; // �����-�� EMA
int FBA=0; // 1 - ����������� ������, -1 - ����������� ���������, 0 - ������� MA - ������ ���!
double sens; // ����� ���������������� � �����

int init()
  {
   first=1;
   
   // �������� ���
      // ����������� ������������� ��� EMA
   int fdg,bdg; 
   if(FrontPeriod<1) fdg=2; if(BackPeriod<1) bdg=2;
   string _fr=DoubleToStr(FrontPeriod,fdg);
   string _bk=DoubleToStr(BackPeriod,bdg);
      // ����������������
   if(Sens>0) string ShortName=Sens+" "; 
      // ��������
   string _src;
   switch(Source) {
      case 0: _src="Volume"; break; // �����
      case 1: _src="ATR"; break; // ATR
      case 2: _src="StDev"; // ��.��������
     }
   _src=_src+"(";
   ShortName=ShortName+_src+SourcePeriod+")";
      // ����� � ���������
   if(FrontPeriod!=1 || BackPeriod!=1) {
      if(FrontPeriod==BackPeriod) ShortName=ShortName+" ("+_fr+")";
      else {
         if(FrontPeriod!=1) ShortName=ShortName+" Front("+_fr+")";
         if(BackPeriod!=1)  ShortName=ShortName+" Back(" +_bk+")";
        }
     }
   IndicatorShortName(ShortName); 

   //
   if(Source>0) sens=Sens*Point; // ����� ���������������� � �����
   else sens=Sens; // � �����

   if(FrontPeriod>1) FrontPeriod=2.0/(1+FrontPeriod); // �����. ��������������� EMA
   if(BackPeriod>1) BackPeriod=2.0/(1+BackPeriod); // �����. ���������� EMA
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

   // ���. ������   
   // VLT
   SetIndexBuffer(0,VLT);
   SetIndexStyle(0,DRAW_LINE,0);
   SetIndexLabel(0,_src+SourcePeriod+")");
   // ����������
   SetIndexBuffer(1,EMA);
   SetIndexStyle(1,DRAW_LINE,0);
   SetIndexLabel(1,"EMA("+_fr+","+_bk+")");

   // ����� ����������������
   SetLevelValue(0,sens);

   return(0);
  }


int reinit() // �-� �������������� �������������
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
   int limit=Bars-ic-1; // ���-�� ����������
   if(History!=0 && limit>History) limit=History-1; // ���-�� ���������� �� �������

   for(int i=limit; i>=0; i--) { // ���� ��������� �� ���� �����
      bool reset=i==limit && ic==0; // ����� �� ������ �������� ����� ���������

      if(reset) {static double MA0prev=0,MA1prev=0; static int BarsPrev=0;}
      
      // VLT
      switch(Source) {
         case 0: 
            double ma=VLT[i+1]*SourcePeriod-Volume[i+SourcePeriod];
            VLT[i]=(ma+Volume[i])/SourcePeriod;
            break;
         case 1: VLT[i]=iATR(NULL,0,SourcePeriod, i); break; // ATR
         case 2: VLT[i]=iStdDev(NULL,0,SourcePeriod,0,0,0, i);  // ��.��������
        }
      double vlt=VLT[i];

      // ��������������� �����������
      double MA0=EMA_FBA(vlt,MA0prev,per0,0,i);
      
      // ���������� ����������� (����������)
      double MA1=EMA_FBA(MA0,MA1prev,per1,FBA,i); 

      // ���� ������
      EMA[i]=MathMax(MA1,sens);
      
      // �������������
      if(first || BarsPrev!=Bars) {BarsPrev=Bars; MA0prev=MA0; MA1prev=MA1;}

     }   

   first=0; // ����� ����� ������� �������
   return(0);
  }

// EMA � ���������� ����������� ����������� ��� ������ � ���������
double EMA_FBA(double C, double MA1, double period, int FBA, int i) {
   if(period==1) return(C);
   // �����. EMA 
   if(period>1) period=2.0/(1+period); 
   // EMA
   double ma=period*C+(1-period)*MA1; 
   // ���������� ������ � ���������
   switch(FBA) {
      case  0: // ������� MA
         if(FBA==0) return(ma); 
      case  1: // ����������� ������
         if(C>MA1) return(ma); else return(C); 
      case -1: // ����������� ���������
         if(C<MA1) return(ma); else return(C); 
     }
  }

