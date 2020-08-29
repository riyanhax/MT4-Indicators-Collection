//+------------------------------------------------------------------+
//|                                                   i-Sessions.mq4 |
//|                                           ��� ����� �. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  16.11.2005  ��������� �������� ������                           |
//+------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window

//------- ������� ��������� ���������� -------------------------------
extern int    NumberOfDays = 99;             // ���������� ����
extern string AsiaBegin    = "00:00";        // �������� ��������� ������
extern string AsiaEnd      = "08:00";        // �������� ��������� ������
extern color  AsiaColor    = ForestGreen;    // ���� ��������� ������
extern string EurBegin     = "06:00";        // �������� ����������� ������
extern string EurEnd       = "16:00";        // �������� ����������� ������
extern color  EurColor     = Purple;         // ���� ����������� ������
extern string USABegin     = "12:00";        // �������� ������������ ������
extern string USAEnd       = "21:00";        // �������� ������������ ������
extern color  USAColor     = DarkBlue;       // ���� ������������ ������
extern bool   ShowPrice    = True;           // ���������� ������� ������
extern color  clFont       = Blue;           // ���� ������
extern int    SizeFont     = 8;              // ������ ������
extern int    OffSet       = 10;             // ��������


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  DeleteObjects();
  for (int i=0; i<NumberOfDays; i++) {
    CreateObjects("AS"+i, AsiaColor);
    CreateObjects("EU"+i, EurColor);
    CreateObjects("US"+i, USAColor);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  DeleteObjects();
  Comment("");
}

//+------------------------------------------------------------------+
//| �������� �������� ����������                                     |
//| ���������:                                                       |
//|   no - ������������ �������                                      |
//|   cl - ���� �������                                              |
//+------------------------------------------------------------------+
void CreateObjects(string no, color cl) {
  ObjectCreate(no, OBJ_RECTANGLE, 0, 0,0, 0,0);
  ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(no, OBJPROP_COLOR, cl);
  ObjectSet(no, OBJPROP_BACK, True);
}

//+------------------------------------------------------------------+
//| �������� �������� ����������                                     |
//+------------------------------------------------------------------+
void DeleteObjects() {
  for (int i=0; i<NumberOfDays; i++) {
    ObjectDelete("AS"+i);
    ObjectDelete("EU"+i);
    ObjectDelete("US"+i);
  }
  ObjectDelete("ASup");
  ObjectDelete("ASdn");
  ObjectDelete("EUup");
  ObjectDelete("EUdn");
  ObjectDelete("USup");
  ObjectDelete("USdn");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  datetime dt=CurTime();
  
  for (int i=0; i<NumberOfDays; i++) {
    if (ShowPrice && i==0) {
      DrawPrices(dt, "AS", AsiaBegin, AsiaEnd);
      DrawPrices(dt, "EU", EurBegin, EurEnd);
      DrawPrices(dt, "US", USABegin, USAEnd);
    }
    DrawObjects(dt, "AS"+i, AsiaBegin, AsiaEnd);
    DrawObjects(dt, "EU"+i, EurBegin, EurEnd);
    DrawObjects(dt, "US"+i, USABegin, USAEnd);
    dt=decDateTradeDay(dt);
    while (TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
  }
}

//+------------------------------------------------------------------+
//| ���������� �������� �� �������                                   |
//| ���������:                                                       |
//|   dt - ���� ��������� ���                                        |
//|   no - ������������ �������                                      |
//|   tb - ����� ������ ������                                       |
//|   te - ����� ��������� ������                                    |
//+------------------------------------------------------------------+
void DrawObjects(datetime dt, string no, string tb, string te) {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];
  ObjectSet(no, OBJPROP_TIME1 , t1);
  ObjectSet(no, OBJPROP_PRICE1, p1);
  ObjectSet(no, OBJPROP_TIME2 , t2);
  ObjectSet(no, OBJPROP_PRICE2, p2);
}

//+------------------------------------------------------------------+
//| ���������� ������� ����� �� �������                              |
//| ���������:                                                       |
//|   dt - ���� ��������� ���                                        |
//|   no - ������������ �������                                      |
//|   tb - ����� ������ ������                                       |
//|   te - ����� ��������� ������                                    |
//+------------------------------------------------------------------+
void DrawPrices(datetime dt, string no, string tb, string te) {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];

  if (ObjectFind(no+"up")<0) ObjectCreate(no+"up", OBJ_TEXT, 0, 0,0);
  ObjectSet(no+"up", OBJPROP_TIME1   , t2);
  ObjectSet(no+"up", OBJPROP_PRICE1  , p1+OffSet*Point);
  ObjectSet(no+"up", OBJPROP_COLOR   , clFont);
  ObjectSet(no+"up", OBJPROP_FONTSIZE, SizeFont);
  ObjectSetText(no+"up", DoubleToStr(p1+Ask-Bid, Digits));

  if (ObjectFind(no+"dn")<0) ObjectCreate(no+"dn", OBJ_TEXT, 0, 0,0);
  ObjectSet(no+"dn", OBJPROP_TIME1   , t2);
  ObjectSet(no+"dn", OBJPROP_PRICE1  , p2);
  ObjectSet(no+"dn", OBJPROP_COLOR   , clFont);
  ObjectSet(no+"dn", OBJPROP_FONTSIZE, SizeFont);
  ObjectSetText(no+"dn", DoubleToStr(p2, Digits));
}

//+------------------------------------------------------------------+
//| ���������� ���� �� ���� �������� ����                            |
//| ���������:                                                       |
//|   dt - ���� ��������� ���                                        |
//+------------------------------------------------------------------+
datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
//+------------------------------------------------------------------+

