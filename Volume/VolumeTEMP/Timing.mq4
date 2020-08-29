
#property copyright "Timing Indicator"
#property link      "finger"

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 100.0
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Orange
#property indicator_width1 2
#property indicator_level1 70.0
#property indicator_width2 2
#property indicator_level2 30.0
#property indicator_width3 2
#property indicator_level3 50.0

extern int Len = 7;
extern double Filter = 0.0;
double g_ibuf_88[];
double g_ibuf_92[];
double g_ibuf_96[];

int init() {
   IndicatorShortName("Timing Indicator");
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, g_ibuf_88);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, g_ibuf_92);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, g_ibuf_96);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double ld_0;
   double ld_8;
   double ld_16;
   double ld_24;
   double ld_32;
   double ld_40;
   double ld_48;
   double ld_56;
   double ld_64;
   double ld_72;
   double ld_80;
   double ld_88;
   double ld_96;
   double ld_104;
   double ld_112;
   double ld_120;
   double ld_128;
   double ld_136;
   double ld_144;
   double ld_152;
   double ld_160;
   double ld_168;
   double ld_176;
   double ld_184;
   double ld_192;
   double ld_200;
   double ld_208;
   double ld_216 = Bars - Len - 1;
   for (int li_224 = ld_216; li_224 >= 0; li_224--) {
      if (ld_8 == 0.0) {
         ld_8 = 1.0;
         ld_16 = 0.0;
         if (Len - 1 >= 5) ld_0 = Len - 1.0;
         else ld_0 = 5.0;
         ld_80 = 100.0 * ((High[li_224] + Low[li_224] + Close[li_224]) / 3.0);
         ld_96 = 3.0 / (Len + 2.0);
         ld_104 = 1.0 - ld_96;
      } else {
         if (ld_0 <= ld_8) ld_8 = ld_0 + 1.0;
         else ld_8 += 1.0;
         ld_88 = ld_80;
         ld_80 = 100.0 * ((High[li_224] + Low[li_224] + Close[li_224]) / 3.0);
         ld_32 = ld_80 - ld_88;
         ld_112 = ld_104 * ld_112 + ld_96 * ld_32;
         ld_120 = ld_96 * ld_112 + ld_104 * ld_120;
         ld_40 = 1.5 * ld_112 - ld_120 / 2.0;
         ld_128 = ld_104 * ld_128 + ld_96 * ld_40;
         ld_208 = ld_96 * ld_128 + ld_104 * ld_208;
         ld_48 = 1.5 * ld_128 - ld_208 / 2.0;
         ld_136 = ld_104 * ld_136 + ld_96 * ld_48;
         ld_152 = ld_96 * ld_136 + ld_104 * ld_152;
         ld_56 = 1.5 * ld_136 - ld_152 / 2.0;
         ld_160 = ld_104 * ld_160 + ld_96 * MathAbs(ld_32);
         ld_168 = ld_96 * ld_160 + ld_104 * ld_168;
         ld_64 = 1.5 * ld_160 - ld_168 / 2.0;
         ld_176 = ld_104 * ld_176 + ld_96 * ld_64;
         ld_184 = ld_96 * ld_176 + ld_104 * ld_184;
         ld_144 = 1.5 * ld_176 - ld_184 / 2.0;
         ld_192 = ld_104 * ld_192 + ld_96 * ld_144;
         ld_200 = ld_96 * ld_192 + ld_104 * ld_200;
         ld_72 = 1.5 * ld_192 - ld_200 / 2.0;
         if (ld_0 >= ld_8 && ld_80 != ld_88) ld_16 = 1.0;
         if (ld_0 == ld_8 && ld_16 == 0.0) ld_8 = 0.0;
      }
      if (ld_0 < ld_8 && ld_72 > 0.0000000001) {
         ld_24 = 50.0 * (ld_56 / ld_72 + 1.0);
         if (ld_24 > 100.0) ld_24 = 100.0;
         if (ld_24 < 0.0) ld_24 = 0.0;
      } else ld_24 = 50.0;
      g_ibuf_88[li_224] = ld_24;
      g_ibuf_92[li_224] = ld_24;
      g_ibuf_96[li_224] = ld_24;
      if (g_ibuf_88[li_224] > g_ibuf_88[li_224 + 1] - Filter) g_ibuf_96[li_224] = EMPTY_VALUE;
      else {
         if (g_ibuf_88[li_224] < g_ibuf_88[li_224 + 1] + Filter) g_ibuf_92[li_224] = EMPTY_VALUE;
         else {
            if (g_ibuf_88[li_224] == g_ibuf_88[li_224 + 1] + Filter) {
               g_ibuf_92[li_224] = EMPTY_VALUE;
               g_ibuf_96[li_224] = EMPTY_VALUE;
            }
         }
      }
   }
   return (0);
}