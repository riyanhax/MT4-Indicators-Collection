#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Black

extern int CCPeriod = 50;
extern int ATRPeriod = 5;

double g_ibuf_76[];
double g_ibuf_80[];
int gi_84 = 0;

int init() {
  { SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 4);
   SetIndexBuffer(0, g_ibuf_76);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 4);
   SetIndexBuffer(1, g_ibuf_80);}
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   {int li_8;
   double ld_12;
   double ld_20;
   double l_icci_28;
   double l_icci_36;
   int li_52 = IndicatorCounted();
   if (li_52 < 0) return (-1);
   if (li_52 > 0) li_52--;
   int li_0 = Bars - li_52;
   for (int li_4 = li_0; li_4 >= 0; li_4--) {
      l_icci_28 = iCCI(NULL, 0, CCPeriod, PRICE_TYPICAL, li_4);
      l_icci_36 = iCCI(NULL, 0, CCPeriod, PRICE_TYPICAL, li_4 + 1);
      li_8 = li_4;
      ld_12 = 0;
      ld_20 = 0;
      for (li_8 = li_4; li_8 >= li_4 - 9; li_8--) ld_20 += MathAbs(High[li_8] - Low[li_8]);
      ld_12 = ld_20 / 10.0;
      if (l_icci_28 >= gi_84 && l_icci_36 < gi_84) g_ibuf_76[li_4 + 1] = g_ibuf_80[li_4 + 1];
      if (l_icci_28 <= gi_84 && l_icci_36 > gi_84) g_ibuf_80[li_4 + 1] = g_ibuf_76[li_4 + 1];
      if (l_icci_28 >= gi_84) {
         g_ibuf_76[li_4] = Low[li_4] - iATR(NULL, 0, ATRPeriod, li_4);
         if (g_ibuf_76[li_4] < g_ibuf_76[li_4 + 1]) g_ibuf_76[li_4] = g_ibuf_76[li_4 + 1];
      } else {
         if (l_icci_28 <= gi_84) {
            g_ibuf_80[li_4] = High[li_4] + iATR(NULL, 0, ATRPeriod, li_4);
            if (g_ibuf_80[li_4] > g_ibuf_80[li_4 + 1]) g_ibuf_80[li_4] = g_ibuf_80[li_4 + 1];
         }
      }
   }
   }
   return (0);
}