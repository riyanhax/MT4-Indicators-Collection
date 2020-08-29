#property copyright "Copyright 2014, Murad Ismayilov"
#property link      "http://www.mql4.com/ru/users/wmlab"
//+------------------------------------------------------------------+
#property indicator_separate_window
//+------------------------------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 1
//+------------------------------------------------------------------+
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
 
double BufLowVol[];  // ������ ������ �������������
double BufHighVol[]; // ������ ������� �������������
double Buf10[]; // ������ 1-0 (��� ������������� � ���������)
 
double barVols[];     // ������ �������������
double avgVol;       // ������� �������������
//-------------------------------------------------
int barsInDay;
//-------------------------------------------------
int init() 
{ 
  barsInDay = 1440 / Period();   // ���. ����� � ������� ���
  if (barsInDay == 0)return(0);
  //....................................
  IndicatorBuffers(3);
  SetIndexBuffer(0, BufLowVol);
  SetIndexBuffer(1, BufHighVol);
  SetIndexBuffer(2, Buf10);
  SetIndexStyle(0, DRAW_HISTOGRAM);
  SetIndexStyle(1, DRAW_HISTOGRAM);
  SetIndexStyle(2, DRAW_LINE);
  SetIndexShift(0, barsInDay);
  SetIndexShift(1, barsInDay);
  SetIndexShift(2, barsInDay);
  //....................................
  ArrayResize(barVols, barsInDay);
  int barCounts[];  // ������ ���������� ���������
  ArrayResize(barCounts, barsInDay);
  ArrayInitialize(barVols,0);
  ArrayInitialize(barCounts,0);
  //....................................
  for (int iBar = 1; iBar <= Bars; iBar++) 
  {
    int barOfDay = iBarOfDay(iTime(NULL, 0, iBar));
    barVols[barOfDay] += GetVol(iBar); // ����������� ������� ����� � �����. ������ �������
    barCounts[barOfDay]++; // ���������� ���������� � ������ ������
  }
  
  for (int i = 0; i < barsInDay; i++) // ��������� ���������
    if (barCounts[i] != 0)barVols[i] /= barCounts[i];
  
  double maxVol = barVols[ArrayMaximum(barVols)];
  double minVol = barVols[ArrayMinimum(barVols)];
  
  avgVol = 0.0;   // ����� ������� �������������
  if (maxVol > minVol)
     for (i = 0; i < barsInDay; i++) 
     {
         barVols[i] = (barVols[i] - minVol) / (maxVol - minVol); // ����������� ��������� � ��������� 0...1
         avgVol += barVols[i];   // ��������� ��� ���������
     }
  
  avgVol /= barsInDay;  // ������� �������� ���� ��������� - ����� �������������
 
  return(0);
}
//-------------------------------------------------
int start()
{
   if (barsInDay == 0)return(0);
   int    limit;
   int    counted_bars=IndicatorCounted();
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
  
  for(int iBar = 0; iBar < limit; iBar++) 
  {
    int barOfDay = iBarOfDay(iTime(NULL, 0, iBar));
    double vol = barVols[barOfDay];
    if (vol >= avgVol) 
    {
      BufLowVol[iBar] = EMPTY_VALUE;
      BufHighVol[iBar] = vol;
      Buf10[iBar]=1;
    }
    else 
    {
      BufLowVol[iBar] = vol;
      BufHighVol[iBar] = EMPTY_VALUE;
      Buf10[iBar]=0;
    }
  }
                
  return(0);
}
//-------------------------------------------------
int iBarOfDay(datetime timeOpenBar) 
{
  int minutesInPeriod = Period();
  double minutesSinceMidnight = MathMod(timeOpenBar / 60, 1440); // ���������� ������ ���
  int barsSinceMidnight = MathFloor(minutesSinceMidnight / minutesInPeriod); // ��������� ��� ������ � ������ ������� ���
  return (barsSinceMidnight);
}
//-------------------------------------------------
double GetVol(int iBar) 
{
   return (iHigh(NULL, 0, iBar) - iLow(NULL, 0, iBar));
}
//-------------------------------------------------