//+------------------------------------------------------------------+
//|                      lukas1 arrows & curves.mq4       v.14       |
//|       ���������:                                                 | 
//|       1. ������ �������� (������) �����������, �� �����������    |
//|          � �������� Kmin, Kmax, RISK                             |
//|       2. ���������� ���������� ��� ������� ���������             |
//|          ������ ������ �����, ��� ��������� �������� �������.    |
//|       3. ��������� �������� �������.                             |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2007, lukas1"
#property link      "http://www.alpari-idc.ru/"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Green
//---- input parameters
extern int SSP       = 6;     //������ ��������� ��������� ����������
extern int CountBars = 2250;  //��������� ������ 
extern int SkyCh     = 13;    //���������������� � ������ ������ 
//������ ���� � ��������� 0-50. 0 - ��� �������. ������ 50 - �����������������
int    i;
double high, low, smin, smax;
double val1[];      // ����� ��� ���
double val2[];      // ����� ��� ����
double Sky_BufferH[];
double Sky_BufferL[];
bool   uptrend, old;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);        // ������� ��� ���
   SetIndexBuffer(0, val1);      // ������ ������ ��� ���
   SetIndexDrawBegin(0, 2*SSP);
   //
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);        // ������� ��� ����
   SetIndexBuffer(1, val2);      // ������ ������ ��� ����
   SetIndexDrawBegin(1, 2*SSP);
   //
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Sky_BufferH);
   SetIndexLabel(2, "High");
   SetIndexDrawBegin(2, 2*SSP);
   //
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, Sky_BufferL);
   SetIndexLabel(3, "Low");
   SetIndexDrawBegin(3, 2*SSP);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculation of SilverTrend lines                                 | 
//+------------------------------------------------------------------+
int start()
  {   
   int counted_bars = IndicatorCounted();
//---- ��������� ����������� ��� ����� ����������
   if(counted_bars > 0) counted_bars--;
//----
   if(Bars <= SSP + 1)        return(0);
//---- initial zero
   uptrend       =false;
   old           =false;
   GlobalVariableSet("goSELL", 0); // ������ ������������� � �������� goSELL=0
   GlobalVariableSet("goBUY", 0);  // ������ ������������� � �������� goBUY =0
//----
   for(i = CountBars - SSP; i >= 0; i--) // ������ �������� shift �� 1 �� ������;
     { 
       high = High[iHighest(Symbol(),0,MODE_HIGH,SSP,i)]; 
       low = Low[iLowest(Symbol(),0,MODE_LOW,SSP,i)]; 
       smax = high - (high - low)*SkyCh / 100; // smax ���� high � ������ �����.SkyCh
       smin = low + (high - low)*SkyCh / 100;  // smin ���� low � ������ �����.SkyCh
	    val1[i] = 0;  
       val2[i] = 0;
       if(Close[i] < smin && i!=0 )	// ��������� �������� ������� (i!=0)
       {
       uptrend = false;
       }
	    if(Close[i] > smax && i!=0 )	// ��������� �������� ������� (i!=0)	
	    {
	    uptrend = true;       
       }       
       if(uptrend != old && uptrend == false)
         {
           val2[i] = high; // ���� ������� ��������� �� ������ val1
           if(i == 0)                GlobalVariableSet("goBUY",1);
         }
       if(uptrend != old && uptrend == true ) 
         {
           val1[i] = low; // ���� ������� ��������� �� ������ val2
           if(i == 0)                GlobalVariableSet("goSELL",1);
         }
       old=uptrend;
       Sky_BufferH[i]=high - (high - low)*SkyCh / 100;
       Sky_BufferL[i]=low +  (high - low)*SkyCh / 100;
     }
   return(0);
  }
//+------------------------------------------------------------------+