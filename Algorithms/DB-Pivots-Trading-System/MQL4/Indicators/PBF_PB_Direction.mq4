/*
   Generated by EX4 TO MQ4 decompile Service 
   Website: http://www.ex4Tomq4.net 
   E-mail : info@ex4Tomq4.net 
*/
#property copyright "Sagacity International Corp"
#property link      "http://www.paintbarforex.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red

/*#import "ServerValidate.dll"
   void ValidateUser(string a0, string a1, int a2, int a3, int& a4[], int& a5[], string a6);
   int Func1(double a0, double a1);
   double Func3();
   double Func4();
   int Func9(double a0, double a1);
   int IsValidated();
#import
*/
extern int Length = 21;
/*
extern string Username;
extern string Password;
*/
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];
bool gi_128 = TRUE;
int gi_132 = 10;
double gda_136[];
double gda_140[];
double gda_144[];
double gda_148[];

int init() {
   IndicatorBuffers(8);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(0, g_ibuf_96);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(1, g_ibuf_100);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(2, g_ibuf_104);
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(3, g_ibuf_108);
   SetIndexStyle(4, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(4, g_ibuf_104);
   SetIndexStyle(5, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(5, g_ibuf_108);
   SetIndexBuffer(0, g_ibuf_96);
   SetIndexBuffer(1, g_ibuf_100);
   SetIndexBuffer(2, g_ibuf_104);
   SetIndexBuffer(3, g_ibuf_108);
   SetIndexBuffer(4, g_ibuf_112);
   SetIndexBuffer(5, g_ibuf_116);
   SetIndexBuffer(6, g_ibuf_120);
   SetIndexBuffer(7, g_ibuf_124);
   gi_132 = Length;
   ArrayResize(gda_136, gi_132);
   ArrayResize(gda_140, gi_132);
   ArrayResize(gda_144, gi_132);
   ArrayResize(gda_148, gi_132);
   ArraySetAsSeries(gda_136, TRUE);
   ArraySetAsSeries(gda_140, TRUE);
   ArraySetAsSeries(gda_144, TRUE);
   ArraySetAsSeries(gda_148, TRUE);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   string ls_0;
   double ima_on_arr_28;
   double ima_on_arr_36;
/*
   if (AccountNumber() == 0) return (0);
   Comment("");
   if (IsValidated() == 1) gi_128 = TRUE;  
   if (gi_128 == FALSE) {
      ls_0 = "12345678901234567890123456789012345678901234567890ABCDEFGHIJKLMNOP";
      int lia_8[] = {0};
      int lia_12[] = {1};
      ValidateUser(Username, Password, AccountNumber(), 0, lia_12, lia_8, ls_0); 
      if (lia_12[0] == 1) {
         Print("Validated");
         gi_128 = TRUE;
      } else {
         Alert("Not validated - return message: ", ls_0);
         return (0);
      }
   }
*/
   int li_24 = IndicatorCounted();
   if (li_24 < 0) return (-1);
   if (li_24 > 0) li_24--;
   if (li_24 > 0) li_24--;
   int li_16 = Bars - li_24;
   for (int li_20 = li_16 - 1; li_20 >= 0; li_20--) g_ibuf_124[li_20] = Close[li_20] - (Close[li_20 + 1]);
   for (li_20 = li_16 - 1; li_20 >= 0; li_20--) g_ibuf_120[li_20] = f0_0(Length, 4, 4, g_ibuf_124, li_20);
   for (li_20 = li_16 - 1; li_20 >= 0; li_20--) {
      ima_on_arr_28 = iMAOnArray(g_ibuf_120, 0, 2, 0, MODE_EMA, li_20);
      ima_on_arr_36 = iMAOnArray(g_ibuf_120, 0, 10.0 * 0.5, 0, MODE_EMA, li_20);
      if (g_ibuf_120[li_20] > ima_on_arr_28 && g_ibuf_120[li_20] > ima_on_arr_36) {
         g_ibuf_96[li_20] = High[li_20];
         g_ibuf_100[li_20] = Low[li_20];
         g_ibuf_104[li_20] = MathMax(Open[li_20], Close[li_20]);
         g_ibuf_108[li_20] = MathMin(Open[li_20], Close[li_20]);
      } else {
         if (g_ibuf_120[li_20] < ima_on_arr_28 && g_ibuf_120[li_20] < ima_on_arr_36) {
            g_ibuf_96[li_20] = Low[li_20];
            g_ibuf_100[li_20] = High[li_20];
            g_ibuf_104[li_20] = MathMin(Open[li_20], Close[li_20]);
            g_ibuf_108[li_20] = MathMax(Open[li_20], Close[li_20]);
         } else {
            if (g_ibuf_120[li_20] > ima_on_arr_28 && g_ibuf_120[li_20] < ima_on_arr_36) {
               g_ibuf_96[li_20] = EMPTY_VALUE;
               g_ibuf_100[li_20] = EMPTY_VALUE;
               g_ibuf_104[li_20] = EMPTY_VALUE;
               g_ibuf_108[li_20] = EMPTY_VALUE;
            } else {
               if (g_ibuf_120[li_20] < ima_on_arr_28 && g_ibuf_120[li_20] > ima_on_arr_36) {
                  g_ibuf_96[li_20] = EMPTY_VALUE;
                  g_ibuf_100[li_20] = EMPTY_VALUE;
                  g_ibuf_104[li_20] = EMPTY_VALUE;
                  g_ibuf_108[li_20] = EMPTY_VALUE;
               }
            }
         }
      }
   }
   return (0);
}

double f0_0(int a_period_0, int a_period_4, int a_period_8, double ada_12[], int ai_16) {
   int li_20 = MathMin(ArraySize(gda_136), ArraySize(ada_12));
   for (int li_24 = li_20 - 1; li_24 >= 0; li_24--) gda_136[li_24] = iMAOnArray(ada_12, 0, a_period_0, 0, MODE_EMA, ai_16 + li_24);
   for (li_24 = li_20 - 1; li_24 >= 0; li_24--) gda_140[li_24] = iMAOnArray(gda_136, 0, a_period_4, 0, MODE_EMA, li_24);
   double ld_28 = 100.0 * iMAOnArray(gda_140, 0, a_period_8, 0, MODE_EMA, 0);
   for (li_24 = li_20 - 1; li_24 >= 0; li_24--) gda_144[li_24] = iMA(NULL, 0, a_period_0, 1, MODE_EMA, PRICE_CLOSE, ai_16 + li_24);
   for (li_24 = li_20 - 1; li_24 >= 0; li_24--) gda_148[li_24] = iMAOnArray(gda_144, 0, a_period_4, 0, MODE_EMA, li_24);
   double ima_on_arr_36 = iMAOnArray(gda_148, 0, a_period_8, 0, MODE_EMA, 0);
   if (ima_on_arr_36 != 0.0) return (ld_28 / ima_on_arr_36);
   return (0);
}