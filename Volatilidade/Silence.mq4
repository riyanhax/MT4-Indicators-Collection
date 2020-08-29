//+---------------------------------------------------------------------+
//|                                                      Silence.mq4    |
//|                                         Copyright � Trofimov 2009   |
//+---------------------------------------------------------------------+
//| ������                                                              |
//|                                                                     |
//| ��������: ���������� �� ������� ��������� ������� �����             |
//| ����� - ������� ������������� (�������� ��������� ����)             |
//| ������� - ������� ������������� (�������� ��������)                 |
//| ��������� ����� ����������� ��������� ������� �����������, 2009     |
//+---------------------------------------------------------------------+


#property copyright "Copyright � Trofimov Evgeniy Vitalyevich, 2009"
#property link      "http://TrofimovVBA.narod.ru/"

//---- �������� ����������
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 MidnightBlue
#property indicator_width1 1
#property indicator_color2 Maroon
#property indicator_width2 1
#property indicator_maximum 100
#property indicator_minimum 0
#property indicator_level1 50

//---- �������� ���������
extern int MyPeriod=12;
extern int BuffSize=96;
bool ReDraw=true; //-���� �������, �� �������������� ������� ��� ��� ������ ����� ����
// ���� ��������, �� ������� ��� �������� ������������� ��������, ����������� �� ���������� (�������) �����
double Buff_line1[]; // - ������������� 
double Buff_line2[]; // - �������������
double Aggress[], Volatility[];
//+------------------------------------------------------------------+
//|                ������� ������������� ����������                  |
//+------------------------------------------------------------------+
int init()
  {
//---- x �������������� ������, ������������ ��� �������
   IndicatorBuffers(2);
   IndicatorDigits(2); 
//---- ��������� ��������� (��������� ���������� ����)
   SetIndexDrawBegin(0,BuffSize+MyPeriod);
   SetIndexDrawBegin(1,BuffSize+MyPeriod);
//---- x �������������� ������ ����������
   SetIndexBuffer(0,Buff_line1);
   SetIndexBuffer(1,Buff_line2);
//---- ��� ���������� � ��������� ��� �����
   IndicatorShortName("Silence("+MyPeriod+","+BuffSize+") = ");
   SetIndexLabel(0,"Aggressiveness");
   SetIndexLabel(1,"Volatility");
   ArrayResize(Aggress,BuffSize);
   ArrayResize(Volatility,BuffSize);
   return(0);
  }
//+------------------------------------------------------------------+
//|                ������� ����������                                |
//+------------------------------------------------------------------+
int start() {
   static datetime LastTime;
   int limit, RD;
   double MAX,MIN;
   double upPrice,downPrice;
   if(ReDraw) RD=1;
   // ����������� ����
   int counted_bars=IndicatorCounted();
//---- ������� ��������� ������
   if(counted_bars<0) return(-1);
//---- ����� ���� �� ��������� � ������� ������ �������� �� �����
   limit=Bars-counted_bars-1+RD;
   
//---- out of range fix
   if(counted_bars==0) limit-=RD+MyPeriod;
   
//---- �������� ����������
   double B;
//---- �������� ����
   for(int t=limit-RD; t>-RD; t--) {
      
      //���������� ������������� ���� t
      B=0;
      for(int x=t+MyPeriod-1; x>=t; x--) { 
         if(Close[x]>Open[x]) {
            //����� �����
            B=B+(Close[x]-Close[x+1]);
         }else{
            //������ �����
            B=B+(Close[x+1]-Close[x]);
         }
      }//Next x
      
      //���������� ������������� ���� t
      upPrice=High[iHighest(Symbol(),0,MODE_HIGH,MyPeriod,t)];//�������� �� N ����� 
      downPrice=Low[iLowest(Symbol(),0,MODE_LOW,MyPeriod,t)]; //������� �� N ����� 
      
      //���� ����������� ����� ���, �� ������������ ������� �������
      if(LastTime!=Time[t+1]){
         for(x=BuffSize-1; x>0; x--) {
            Aggress[x]=Aggress[x-1];
            Volatility[x]=Volatility[x-1];
         }//Next x
         LastTime=Time[t+1];
      }
      //����� ������� �������
      
      //����������� �������������
      Aggress[0]=B/Point/MyPeriod;
      MAX=Aggress[ArrayMaximum(Aggress)];
      MIN=Aggress[ArrayMinimum(Aggress)];
      Buff_line1[t]=������������(MAX,MIN,100,0,Aggress[0]);
      if(!ReDraw && t==1) Buff_line1[0]=Buff_line1[1];
      //����� ����������� �������������
      
      //����������� �������������
      Volatility[0]=(upPrice-downPrice)/Point/MyPeriod;
      MAX=Volatility[ArrayMaximum(Volatility)];
      MIN=Volatility[ArrayMinimum(Volatility)];
      Buff_line2[t]=������������(MAX,MIN,100,0,Volatility[0]);
      if(!ReDraw && t==1) Buff_line2[0]=Buff_line2[1];
      //����� ����������� �������������
      
   }//Next t
   return(0);
}
//+------------------------------------------------------------------+
double ������������(double a,double b,double c,double d,double X) {
//a; X; b - ������� �������� �����, c; d; - ������� �� ������� �����������.
    if(b - a == 0)
        return(10000000); //�������������
    else
        return(d - (b - X) * (d - c) / (b - a));
}//������������
//+------------------------------------------------------------------+

