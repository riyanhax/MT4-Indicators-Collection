#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 100.0
#property indicator_buffers 5
#property indicator_color1 CLR_NONE
#property indicator_color2 CLR_NONE
#property indicator_color3 Aqua
#property indicator_color4 Magenta
#property indicator_color5 CLR_NONE

extern int KPeriod = 21;
extern int DPeriod = 12;
extern int Slowing = 3;
extern int method = 0;
extern int price = 0;
extern string для_WPR = "";
extern int ExtWPRPeriod = 14;
extern double ZoneHighPer = 70.0;
extern double ZoneLowPer = 30.0;
extern bool modeone = TRUE;
extern bool PlaySoundBuy = TRUE;
extern bool PlaySoundSell = TRUE;
int gi_136 = 0;
extern string FileSoundBuy = "analyze buy";
extern string FileSoundSell = "analyze sell";
double g_ibuf_156[];
double g_ibuf_160[];
double g_ibuf_164[];
double g_ibuf_168[];
double g_ibuf_172[];
int gi_176 = 0;
int gi_180 = 0;
int g_time_184 = 0;
int gi_188 = 0;
int gi_192 = 0;
int gi_196 = 0;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   string ls_unused_0;
   IndicatorBuffers(5);
   SetIndexStyle(0, DRAW_LINE, EMPTY, 0);
   SetIndexBuffer(0, g_ibuf_156);
   SetIndexStyle(1, DRAW_LINE, EMPTY, 0);
   SetIndexBuffer(1, g_ibuf_160);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 5);
   SetIndexArrow(2, 244);
   SetIndexBuffer(2, g_ibuf_164);
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 5);
   SetIndexBuffer(3, g_ibuf_168);
   SetIndexArrow(3, 244);
   SetIndexStyle(4, DRAW_LINE, EMPTY, 0);
   SetIndexBuffer(4, g_ibuf_172);
   gi_176 = KPeriod + Slowing;
   gi_180 = gi_176 + DPeriod;
   SetIndexDrawBegin(0, gi_176);
   SetIndexDrawBegin(1, gi_180);
   SetIndexDrawBegin(4, ExtWPRPeriod);
   SetIndexEmptyValue(2, 0);
   SetIndexEmptyValue(3, 0);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double price_field_12;
   double high_20;
   double low_28;
   double ld_40;
   double ld_48;
   double ld_56;
   double ld_64;
   int shift_72;
   int li_8 = IndicatorCounted();
   if (Bars <= gi_180) return (0);
   if (li_8 < 1) {
      for (int shift_0 = 1; shift_0 <= gi_176; shift_0++) g_ibuf_156[Bars - shift_0] = 0;
      for (shift_0 = 1; shift_0 <= gi_180; shift_0++) g_ibuf_160[Bars - shift_0] = 0;
   }
   if (li_8 > 0) li_8--;
   int li_36 = Bars - li_8;
   for (shift_0 = 0; shift_0 < li_36; shift_0++) {
      g_ibuf_156[shift_0] = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, method, price_field_12, MODE_MAIN, shift_0);
      g_ibuf_160[shift_0] = iStochastic(NULL, 0, 21, DPeriod, Slowing, method, price_field_12, MODE_SIGNAL, shift_0);
   }
   shift_0 = Bars - ExtWPRPeriod - 1;
   if (li_8 > ExtWPRPeriod) shift_0 = Bars - li_8 - 1;
   while (shift_0 >= 0) {
      high_20 = High[iHighest(NULL, 0, MODE_HIGH, ExtWPRPeriod, shift_0)];
      low_28 = Low[iLowest(NULL, 0, MODE_LOW, ExtWPRPeriod, shift_0)];
      if (!f0_0(high_20 - low_28, 0.0)) g_ibuf_172[shift_0] = (high_20 - Close[shift_0]) / (-0.01) / (high_20 - low_28) + 100.0;
      shift_0--;
   }
   if (li_8 > 0) li_8--;
   li_36 = Bars - li_8;
   for (shift_0 = li_36 - 1; shift_0 >= 0; shift_0--) {
      ld_40 = g_ibuf_160[shift_0];
      ld_48 = g_ibuf_160[shift_0 + 1];
      ld_56 = g_ibuf_156[shift_0];
      ld_64 = g_ibuf_156[shift_0 + 1];
      if (ld_56 > ld_40 && ld_64 < ld_48 && ld_64 < ZoneLowPer && ld_48 < ZoneLowPer) {
         g_ibuf_164[shift_0] = 100;
         shift_72 = iBarShift(NULL, 0, gi_188);
         if (modeone && shift_72 != shift_0 && gi_196 == 1) g_ibuf_164[shift_72] = 0;
         gi_188 = Time[shift_0];
         gi_196 = 1;
      } else g_ibuf_164[shift_0] = 0;
      if (ld_56 < ld_40 && ld_64 > ld_48 && ld_64 > ZoneHighPer && ld_48 > ZoneHighPer) {
         g_ibuf_168[shift_0] = 100;
         shift_72 = iBarShift(NULL, 0, gi_192);
         if (modeone && shift_72 != shift_0 && gi_196 == -1) g_ibuf_168[shift_72] = 0;
         gi_192 = Time[shift_0];
         gi_196 = -1;
      } else g_ibuf_168[shift_0] = 0;
   }
   if (PlaySoundBuy && g_ibuf_164[gi_136] > 0.0) {
      if (g_time_184 != Time[gi_136]) PlaySound(FileSoundBuy);
      g_time_184 = Time[gi_136];
   }
   if (PlaySoundSell && g_ibuf_168[gi_136] > 0.0) {
      if (g_time_184 != Time[gi_136]) PlaySound(FileSoundSell);
      g_time_184 = Time[gi_136];
   }
   return (0);
}

// 2B740CB84420C7B62E2B7A7086716360
bool f0_0(double ad_0, double ad_8) {
   bool bool_16 = NormalizeDouble(ad_0 - ad_8, 8) == 0.0;
   return (bool_16);
}