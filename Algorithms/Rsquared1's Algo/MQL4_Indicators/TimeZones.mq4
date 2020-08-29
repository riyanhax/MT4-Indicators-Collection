//+------------------------------------------------------------------+
//|                                                    TimeZones.mq4 |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 11

extern int    NumBars     = 999;
extern int    Offset_USD  = 18;
extern int    Offset_CAD  = 18;
extern int    Offset_GBP  = 23;
extern int    Offset_EUR  = 00;
extern int    Offset_CHF  = 00;
extern int    Offset_JPY  = 07;
extern int    Offset_AUD  = 09;
extern int    Offset_NZD  = 11;
extern int    Offset_LCL  = 11;
extern string Font_Type   = "Arial";
extern int    Font_Size   = 7;
extern color  Color_USD   = CornflowerBlue;
extern color  Color_CAD   = Lime;
extern color  Color_GBP   = Red;
extern color  Color_EUR   = Orange;
extern color  Color_CHF   = Yellow;
extern color  Color_JPY   = Magenta;
extern color  Color_AUD   = MediumOrchid;
extern color  Color_NZD   = BlueViolet;
extern color  Color_LCL   = White;

int curr_hr, prev_hr, wintot;
int times[9][24];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

  for(int j=0; j<=23; j++) {
    times[0][j] = j + Offset_USD;
    times[1][j] = j + Offset_CAD;
    times[2][j] = j + Offset_GBP;
    times[3][j] = j + Offset_EUR;
    times[4][j] = j + Offset_CHF;
    times[5][j] = j + Offset_JPY;
    times[6][j] = j + Offset_AUD;
    times[7][j] = j + Offset_NZD;
    times[8][j] = j + Offset_LCL;
  }
  for(int i=0; i<=8; i++) {
    for(j=0; j<=23; j++) {
      if (times[i][j] < 0)   times[i][j] += 24;
      if (times[i][j] > 24)  times[i][j] -= 24;
      if (i<8)  {
        if (times[i][j] < 8)   times[i][j] = 0;
        if (times[i][j] > 17)  times[i][j] = 0;
       } 
      if (times[i][j] > 12)  times[i][j] -= 12;
  } }    

  del_obj();

  return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {
  del_obj();
  return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()  {
  curr_hr = Hour();
  if (curr_hr != prev_hr)  {
    del_obj();
    process_times();
  }  
  prev_hr = curr_hr;
  return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void process_times()  {
  wintot = WindowsTotal();
  for (int j=NumBars; j>=0; j--)  {
    string tim = TimeToStr(Time[j],TIME_DATE|TIME_SECONDS);
    if (StringSubstr(tim,13,6) == ":00:00")  {
      int hr = StrToInteger(StringSubstr(tim,11,2));
      for (int i=0; i<=8; i++)  {
        if (times[i][hr] > 0)  {
          string objname = "tmzn-" + j + "-" + i;
          string tmptxt  = times[i][hr];
          color  clr     = White;
          switch(i) {
            case 0 : clr = Color_USD; break;
            case 1 : clr = Color_CAD; break;
            case 2 : clr = Color_GBP; break;
            case 3 : clr = Color_EUR; break;
            case 4 : clr = Color_CHF; break;
            case 5 : clr = Color_JPY; break;
            case 6 : clr = Color_AUD; break;
            case 7 : clr = Color_NZD; break;
            case 8 : clr = Color_LCL; break;
          }
          ObjectCreate(objname,OBJ_TEXT,wintot-1,Time[j],9-i);
          ObjectSetText(objname,tmptxt,Font_Size,Font_Type,clr);
  } } } }
  for (i=0; i<=8; i++)  {
    objname = "tmzn-x-" + i;
    clr     = White;
    switch(i) {
      case 0 : clr = Color_USD; tmptxt = "USD"; break;
      case 1 : clr = Color_CAD; tmptxt = "CAD"; break;
      case 2 : clr = Color_GBP; tmptxt = "GBP"; break;
      case 3 : clr = Color_EUR; tmptxt = "EUR"; break;
      case 4 : clr = Color_CHF; tmptxt = "CHF"; break;
      case 5 : clr = Color_JPY; tmptxt = "JPY"; break;
      case 6 : clr = Color_AUD; tmptxt = "AUD"; break;
      case 7 : clr = Color_NZD; tmptxt = "NZD"; break;
      case 8 : clr = Color_LCL; tmptxt = "LCL"; break;
    }
    ObjectCreate(objname,OBJ_TEXT,wintot-1,Time[0]+300*Period(),9-i);
    ObjectSetText(objname,tmptxt,Font_Size,Font_Type,clr);
  }  
  return(0);
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void del_obj()   {
  for(int i=ObjectsTotal()-1; i>=0; i--)  {
    string objname = ObjectName(i);
    if (ObjectType(objname) == OBJ_TEXT && StringSubstr(objname,0,4) == "tmzn")   ObjectDelete(objname);
  }  
  return(0);
}