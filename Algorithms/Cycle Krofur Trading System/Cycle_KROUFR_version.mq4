//+------------------------------------------------------------------+
//|                                        Cycle_KROUFR_version.mq4  |
//+------------------------------------------------------------------+
#property  copyright "Copyright � 2008 | Grayman77, zIG, akadex"
#property  link      "ForexResearch"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
#property indicator_buffers 1
#property indicator_color1 DarkOrchid

//---- input parameters
extern int FastMA=12;
extern int SlowMA=24;
extern int Crosses=50;
extern bool Comments=true; 

//---- buffers
double MA[];
double MCD[];
double MAfast[],MAslow[];
double Cross[];
double max_min[];
double PointDeviation[];
double PeriodTimeAVG[];

//---- var
double smconst,ST,max,min;
int ShiftFirstCross;  // �������� ������� ����������� c ������ �������
int ShiftCrossesCross;  // �������� (Crosses+1)-�� ����������� c ������ ������� (������ - ����������)
int k;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//   string short_name;
//---- indicator line
   IndicatorBuffers(8);
   SetIndexBuffer(0, MA);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,DarkOrchid);
   SetIndexBuffer(1, MCD);
 	SetIndexBuffer(2, MAfast);
	SetIndexBuffer(3, MAslow);
	SetIndexBuffer(4, Cross);
	SetIndexBuffer(5, max_min);
	SetIndexBuffer(6, PointDeviation);
	SetIndexBuffer(7, PeriodTimeAVG);
   
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);
   
   ShiftFirstCross=0;
	ShiftCrossesCross=0;
	k=0;
	max=0.;
   min=1000000.;
   
   return(0);
  }
int deinit()
  {
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//| Schaff Trend Cycle                                               |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int i,j,limit,NumberCross,BarsCross;
   double prev,MinMACD,MaxMACD,delta,Sum_max_min;
   
   if(Bars<=SlowMA) return(-1);
   
   //---- ��������� ����������� ��� ����� ����������
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(limit>Bars-SlowMA-1) limit=Bars-SlowMA-1;
   
//+------------------------------------------------------------------+
//| Time AVG                                                         |
//+------------------------------------------------------------------+
   for(i=limit;i>0;i--)
     {
     Cross[i]=0.;
     // ��������� �������� ������� � ��������� � ������
     MAfast[i]=iMA(NULL,Period(),FastMA,0,MODE_SMA,PRICE_CLOSE,i);
     MAslow[i]=iMA(NULL,Period(),SlowMA,0,MODE_SMA,PRICE_CLOSE,i);
     // ����� ����������� �������
     if(MAfast[i]>=MAslow[i] && MAfast[i+1]<MAslow[i+1]) // ������� ���������� ��������� ����� �����
       {
       // ���� ��� ������ ��������� ����������� - ��������� ��� ��������
       if(ShiftFirstCross==0) ShiftFirstCross=i;
       // ���� ��� �� ������� Crosses+1 �����������
       if(ShiftCrossesCross==0)
         {
         k++;
         // ���� ������� - ���������
         if(k==Crosses+1) ShiftCrossesCross=i;
         }
       // ��������� ���� ����������� � ������
       Cross[i]=1.;
       // ��������� �������� max-min � ������
       max_min[i]=max-min;
       // �������� �������� max � min
       max=0.;
       min=1000000.;
       }
     if(MAfast[i]<=MAslow[i] && MAfast[i+1]>MAslow[i+1]) // ������� ���������� ��������� ������ ����
       {
       // ���� ��� ������ ��������� ����������� - ��������� ��� ��������
       if(ShiftFirstCross==0) ShiftFirstCross=i;
       // ���� ��� �� ������� Crosses+1 �����������
       if(ShiftCrossesCross==0)
         {
         k++;
         // ���� ������� - ���������
         if(k==Crosses+1) ShiftCrossesCross=i;
         }
       // ��������� ���� ����������� � ������
       Cross[i]=-1.;
       // ��������� �������� max-min � ������
       max_min[i]=max-min;
       // �������� �������� max � min
       max=0.;
       min=1000000.;
       }
     // �������� ������������ ���� (�� High) ����� ������������� � ����������� �� Low
     if(max<High[i]) max=High[i];
     if(min>Low[i]) min=Low[i];
     }
   
   
   // ������� ����������
   if(limit>ShiftCrossesCross) limit=ShiftCrossesCross;
   for(i=limit;i>0;i--)
     {
     // ����� ������ ����������� (������ ������)
     j=i;
     while(Cross[j]==0.) j++;
     // ����� ��������� Crosses �����������
     NumberCross=0;
     BarsCross=0;
     Sum_max_min=0.;
     while(NumberCross<Crosses)
       {
       // ���� ������� ��������� �����������
       if(Cross[j]!=0.)
         {
         NumberCross++;  // ��������� �� 1 ������� �����������
         Sum_max_min=Sum_max_min+max_min[j];
         }
       j++;
       BarsCross++;
       }
     
     // �������� �������� Time AVG
     PeriodTimeAVG[i]=BarsCross/Crosses;   // ������� ���-�� ����� ����� �������������
     PointDeviation[i]=NormalizeDouble(Sum_max_min/Crosses/2./Point,0); // ��. ����������
     }

//+------------------------------------------------------------------+
//| Cycle                                                            |
//+------------------------------------------------------------------+
   for(i=limit;i>=0;i--)
     {
     // ��������� MACD
     MCD[i]=iMA(NULL,0,FastMA,0, MODE_EMA, PRICE_TYPICAL, i)-
            iMA(NULL,0,SlowMA,0, MODE_EMA, PRICE_TYPICAL, i);
     
     // ����� ����. � ���. �������� MACD �� ������� TimeAVG
     MinMACD=MCD[i];
     MaxMACD=MCD[i];
     for(j=i+1;j<i+PeriodTimeAVG[i+1];j++)
       {
       if(MCD[j]<MinMACD) MinMACD=MCD[j];
       if(MCD[j]>MaxMACD) MaxMACD=MCD[j];
       }
     
     // ��������� ��������� �� MACD
     delta=MaxMACD-MinMACD;
     if(delta==0.)  // �������� ��� ���������� ������� �� 0
      ST=50.;
      else   // ���� �� 0 - �����
       {
       ST=(MCD[i]-MinMACD)/delta*100;
       }
      // ��������� �����
     prev=MA[i+1];
     MA[i]=(2./(1.+PeriodTimeAVG[i+1]/2.))*(ST-prev)+prev;
     
     //������� �����������
     if (!IsTesting() && Comments)
     Comment(" ������� ����������: "+DoubleToStr(PointDeviation[1],0)+
     " �������\n ������� ���������� �����: "+DoubleToStr(PeriodTimeAVG[1],0)+
     "\n �����������: "+Crosses); 
       }
  
  return(0);
  }
//+------------------------------------------------------------------+