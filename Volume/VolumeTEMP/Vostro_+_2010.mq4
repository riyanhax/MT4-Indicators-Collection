
#property copyright "Copyright © 2010, GoldenTraders Software Corp."
#property link      "http://www.Golden-Traders.com"

#property indicator_separate_window
#property indicator_minimum -100.0
#property indicator_maximum 100.0
#property indicator_levelcolor Red
#property indicator_width1 2
#property indicator_level1 80.0
#property indicator_level2 -80.0


extern color Color = Blue;
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double gd_120;
double gd_128;
double gd_136;
int gi_148;
int gi_152;
extern int Per_Lwma=24;
extern int Value_Filter=5;
extern double ValuePava=6;

int init() {
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_LINE, EMPTY, 2, Color);
   SetIndexBuffer(0, g_ibuf_108);
   SetIndexBuffer(1, g_ibuf_116);
   SetIndexBuffer(2, g_ibuf_112);
   IndicatorShortName("Vostro © 2010       ");
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   for (gi_152 = 0; gi_152 < Bars; gi_152++) {
      gd_120 = 0;
      for (gi_148 = gi_152; gi_148 < Value_Filter + gi_152; gi_148++) gd_120 += (High[gi_148] + Low[gi_148]+Close[gi_148]) / 3.0;
      gd_128 = gd_120 / Value_Filter;
      gd_120 = 0;
      for (gi_148 = gi_152; gi_148 < Value_Filter + gi_152; gi_148++) gd_120 += High[gi_148] - Low[gi_148];
      gd_136 = 0.2 * (gd_120 / Value_Filter);
      g_ibuf_116[gi_152] = (Low[gi_152] - gd_128) / gd_136;
      g_ibuf_112[gi_152] = (High[gi_152] - gd_128) / gd_136;
      if (g_ibuf_112[gi_152] > ValuePava && Low[gi_152] > iMA(NULL, 0, Per_Lwma, 0, MODE_LWMA, PRICE_TYPICAL, gi_152)) g_ibuf_108[gi_152] = 90.0;
      else {
         if (g_ibuf_116[gi_152] < -ValuePava && High[gi_152] < iMA(NULL, 0,Per_Lwma, 0, MODE_LWMA, PRICE_TYPICAL, gi_152)) g_ibuf_108[gi_152] = -90.0;
         else g_ibuf_108[gi_152] = 0.0;
      }
   }
   return (0);
}