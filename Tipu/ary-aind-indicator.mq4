
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Lime
#property indicator_color3 Red

extern int period = 27;
double Mas1[];
double Mas2[];
double Mas3[];

int init() {
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 3, DeepSkyBlue);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 3, Crimson);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, Mas1);
   SetIndexBuffer(1, Mas2);
   SetIndexBuffer(2, Mas3);
   IndicatorShortName("ARYAIND");
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   return (0);
}

int start() {
   double arya1;
   double arya2;
   double arya10;
   int aryax = IndicatorCounted();
   double aryay = 0;
   double aryaz = 0;
   double aryam = 0;
   double aryalow = 0;
   double aryahigh = 0;
   if (aryax > 0) aryax--;
   int k = Bars - aryax;
   for (int aryak = 0; aryak < k; aryak++) {
      aryahigh = High[iHighest(NULL, 0, MODE_HIGH, period, aryak)];
      aryalow = Low[iLowest(NULL, 0, MODE_LOW, period, aryak)];
      arya10 = (High[aryak] + Low[aryak]) / 2.0;
      aryay = 0.66 * ((arya10 - aryalow) / (aryahigh - aryalow) - 0.5) + 0.67 * aryaz;
      aryay = MathMin(MathMax(aryay, -0.999), 0.999);
      Mas1[aryak] = MathLog((aryay + 1.0) / (1 - aryay)) / 2.0 + aryam / 2.0;
      aryaz = aryay;
      aryam = Mas1[aryak];
   }
   bool aryacheck = TRUE;
   for (aryak = k - 2; aryak >= 0; aryak--) {
      arya2 = Mas1[aryak];
      arya1 = Mas1[aryak + 1];
      if ((arya2 < 0.0 && arya1 > 0.0) || arya2 < 0.0) aryacheck = FALSE;
      if ((arya2 > 0.0 && arya1 < 0.0) || arya2 > 0.0) aryacheck = TRUE;
      if (!aryacheck) {
         Mas3[aryak] = arya2;
         Mas2[aryak] = 0.0;
      } else {
         Mas2[aryak] = arya2;
         Mas3[aryak] = 0.0;
      }
   }
   return (0);
}
