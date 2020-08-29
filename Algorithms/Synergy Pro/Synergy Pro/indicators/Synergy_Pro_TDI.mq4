/*
   Generated by EX4-TO-MQ4 decompiler V4.0.427.4 [-]
   Website: https://purebeam.biz
   E-mail : purebeam@gmail.com
*/
#property copyright "Copyright � 2012, Dean Malone"
#property link      "www.synergyprotrader.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Black
#property indicator_color2 DodgerBlue
#property indicator_color3 Yellow
#property indicator_color4 DodgerBlue
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 LimeGreen
#property indicator_color8 Fuchsia

#import "CompassFX.dll"
   string gGrab(string a0, string a1);
#import "synergy_pro.dll"
   string returnReg(string a0, string a1);
#import

int g_file_76;
bool gi_80 = FALSE;
string gs_unused_84;
double gd_unused_92 = 1.1;
extern string Custom_Indicator = "Synergy Pro Traders Dynamic Index";
extern string Copyright = "� 2012, Dean Malone";
extern string Web_Address = "www.synergyprotrader.com";
extern int RSI_Value = 10;
extern string Color = "=== Color settings ===";
extern color TDI_Color = Green;
extern color TDI_Signal_Color = Red;
extern color Market_Base_Color = Yellow;
extern color Volatility_Band_Color = DodgerBlue;
extern color Arrow_Up_Color = LimeGreen;
extern color Arrow_Down_Color = Fuchsia;
extern int Arrow_Size = 0;
extern string Alert_mode = "=== Alert settings ===";
extern bool Show_Arrows = TRUE;
extern bool Show_Message_alert = TRUE;
extern bool TDI_Signal_Cross_alert = FALSE;
extern bool MBL_Cross_alert = FALSE;
extern bool TDI_Hook_alert = FALSE;
double g_ibuf_192[];
double g_ibuf_196[];
double g_ibuf_200[];
double g_ibuf_204[];
double g_ibuf_208[];
double g_ibuf_212[];
double g_ibuf_216[];
double g_ibuf_220[];
bool gi_224 = FALSE;
bool gi_228 = FALSE;
int g_datetime_232 = 0;
string gs_dummy_236;
datetime g_time_244;

int f0_4() {
   int str2int_0;
   bool li_4;
   int li_8;
   g_file_76 = FileOpen("synergy_d.bin", FILE_CSV|FILE_READ);
   if (g_file_76 < 1) li_4 = FALSE;
   else {
      str2int_0 = StrToInteger(FileReadString(g_file_76));
      FileClose(g_file_76);
      li_4 = TRUE;
   }
   if (TimeLocal() - str2int_0 >= 86400 || li_4 == FALSE) {
      li_8 = f0_0();
      switch (li_8) {
      case 0:
         g_file_76 = FileOpen("synergy_d.bin", FILE_WRITE, 8);
         if (g_file_76 < 1) {
            Print("Cannot open password cache!");
            return (0);
         }
         FileWrite(g_file_76, TimeLocal());
         FileClose(g_file_76);
         break;
      case 1:
         Alert("Invalid software key provided!! Please re-install the software with the correct key.");
         gi_80 = TRUE;
         break;
      case 4:
         Alert("Your account has been disabled! Please contact support@compassfx.com");
         gi_80 = TRUE;
         break;
      case 5:
         Alert("Server error!! Please make sure you are connected to the Internet and try again.");
         gi_80 = TRUE;
         break;
      case 6:
         Alert("No key found in your registry (could be a bad installation)! Please re-install Synergy.");
         gi_80 = TRUE;
      }
   }
   return (0);
}

int f0_0() {
   string ls_unused_0;
   string ls_unused_8;
   string ls_unused_16;
   string ls_24 = returnReg("Software\\CompassFX\\Synergy", "key");
   if (ls_24 == "") return (6);
   string ls_32 = "key=" + ls_24;
   string ls_40 = gGrab("http://www.compassfx.com/synergy_scripts/s_login.php", ls_32);
   Print("Result -- ", ls_40);
   if (StringSubstr(ls_40, 0, 1) == "0") {
      gs_unused_84 = ls_40;
      return (0);
   }
   if (StringSubstr(ls_40, 0, 1) == "1") return (1);
   if (StringSubstr(ls_40, 0, 1) == "4") return (4);
   return (5);
}

string f0_2() {
   string ls_ret_0 = "no info";
   switch (Period()) {
   case PERIOD_MN1:
      ls_ret_0 = " on monthly chart";
      break;
   case PERIOD_W1:
      ls_ret_0 = " on weekly chart";
      break;
   case PERIOD_D1:
      ls_ret_0 = " on daily chart";
      break;
   case PERIOD_H4:
      ls_ret_0 = " on 4-hour chart";
      break;
   case PERIOD_H1:
      ls_ret_0 = " on 1-hour chart";
      break;
   case PERIOD_M30:
   case PERIOD_M15:
   case PERIOD_M5:
   case PERIOD_M1:
      ls_ret_0 = " on " + Period() + "-minute chart";
   }
   return (ls_ret_0);
}

int init() {
   HideTestIndicators(TRUE);
   IndicatorShortName("Synergy_Pro_TDI");
   SetIndexBuffer(0, g_ibuf_192);
   SetIndexBuffer(1, g_ibuf_196);
   SetIndexBuffer(2, g_ibuf_200);
   SetIndexBuffer(3, g_ibuf_204);
   SetIndexBuffer(4, g_ibuf_208);
   SetIndexBuffer(5, g_ibuf_212);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, Volatility_Band_Color);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2, Market_Base_Color);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, Volatility_Band_Color);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 2, TDI_Color);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 2, TDI_Signal_Color);
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, "MBL");
   SetIndexLabel(3, NULL);
   SetIndexLabel(4, "TDI");
   SetIndexLabel(5, "TDI_Signal");
   SetIndexLabel(6, NULL);
   SetIndexLabel(7, NULL);
   SetIndexBuffer(6, g_ibuf_216);
   SetIndexArrow(6, 233);
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, Arrow_Size, Arrow_Up_Color);
   SetIndexBuffer(7, g_ibuf_220);
   SetIndexArrow(7, 234);
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, Arrow_Size, Arrow_Down_Color);
   SetLevelValue(0, 50);
   SetLevelValue(1, 68);
   SetLevelValue(2, 32);
   SetLevelStyle(2, 1, DimGray);
   //f0_4();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double ld_8;
   double lda_16[];
   if (gi_80) return (0);
   int li_0 = IndicatorCounted();
   if (g_datetime_232 < iTime(NULL, 0, 0)) g_datetime_232 = iTime(NULL, 0, 0);
   if (li_0 < 0) return (-1);
   if (li_0 > 0) li_0--;
   int li_4 = MathMin(Bars - li_0, Bars - 1);
   ArrayResize(lda_16, 34);
   for (int li_20 = li_4; li_20 >= 0; li_20--) {
      g_ibuf_192[li_20] = iRSI(NULL, 0, RSI_Value, PRICE_TYPICAL, li_20);
      ld_8 = 0;
      for (int li_24 = li_20; li_24 < li_20 + 34; li_24++) {
         lda_16[li_24 - li_20] = g_ibuf_192[li_24];
         ld_8 += g_ibuf_192[li_24] / 34.0;
      }
      g_ibuf_196[li_20] = ld_8 + 1.6185 * f0_1(lda_16, 34);
      g_ibuf_204[li_20] = ld_8 - 1.6185 * f0_1(lda_16, 34);
      g_ibuf_200[li_20] = (g_ibuf_196[li_20] + g_ibuf_204[li_20]) / 2.0;
   }
   for (li_20 = li_4 - 1; li_20 >= 0; li_20--) {
      g_ibuf_208[li_20] = iMAOnArray(g_ibuf_192, 0, 2, 0, MODE_SMMA, li_20);
      g_ibuf_212[li_20] = iMAOnArray(g_ibuf_192, 0, 7, 0, MODE_SMA, li_20);
      if (Show_Arrows == TRUE) {
         if (TDI_Signal_Cross_alert == TRUE) {
            if (gi_224 == FALSE && (g_ibuf_208[li_20] > g_ibuf_212[li_20] && g_ibuf_208[li_20 + 1] > g_ibuf_212[li_20 + 1] && g_ibuf_208[li_20 + 2] < g_ibuf_212[li_20 + 2]) &&
               g_ibuf_208[li_20] < 90.0) {
               g_ibuf_216[li_20] = g_ibuf_212[li_20] - 8.0;
               if (g_ibuf_216[0] != EMPTY_VALUE && Show_Message_alert == TRUE && f0_5()) {
                  PlaySound("alert.wav");
                  Alert("TDI Cross Long: ", Symbol(), " at ", Close[0], f0_2());
               }
               gi_228 = FALSE;
               gi_224 = TRUE;
            }
            if (gi_228 == FALSE && (g_ibuf_208[li_20] < g_ibuf_212[li_20] && g_ibuf_208[li_20 + 1] < g_ibuf_212[li_20 + 1] && g_ibuf_208[li_20 + 2] > g_ibuf_212[li_20 + 2]) &&
               g_ibuf_208[li_20] > 10.0) {
               g_ibuf_220[li_20] = g_ibuf_212[li_20] + 8.0;
               if (g_ibuf_220[0] != EMPTY_VALUE && Show_Message_alert == TRUE && f0_5()) {
                  PlaySound("alert.wav");
                  Alert("TDI Cross Short: ", Symbol(), " at ", Close[0], f0_2());
               }
               gi_224 = FALSE;
               gi_228 = TRUE;
            }
         }
      }
      if (MBL_Cross_alert == TRUE) {
         if (g_ibuf_208[li_20 + 1] > g_ibuf_200[li_20 + 1] && g_ibuf_208[li_20 + 2] < g_ibuf_200[li_20 + 2] && g_ibuf_208[li_20] > g_ibuf_200[li_20] && g_ibuf_208[li_20] < 90.0 &&
            g_ibuf_208[li_20] > g_ibuf_212[li_20]) {
            g_ibuf_216[li_20] = g_ibuf_212[li_20] - 8.0;
            if (g_ibuf_216[0] != EMPTY_VALUE && Show_Message_alert == TRUE && f0_5()) {
               PlaySound("alert.wav");
               Alert("MBL Cross Long: ", Symbol(), " at ", Close[0], f0_2());
            }
         }
         if (g_ibuf_208[li_20 + 1] < g_ibuf_200[li_20 + 1] && g_ibuf_208[li_20 + 2] > g_ibuf_200[li_20 + 2] && g_ibuf_208[li_20] < g_ibuf_200[li_20] && g_ibuf_208[li_20] > 10.0 &&
            g_ibuf_208[li_20] < g_ibuf_212[li_20]) {
            g_ibuf_220[li_20] = g_ibuf_212[li_20] + 8.0;
            if (g_ibuf_220[0] != EMPTY_VALUE && Show_Message_alert == TRUE && f0_5()) {
               PlaySound("alert.wav");
               Alert("MBL Cross Short: ", Symbol(), " at ", Close[0], f0_2());
            }
         }
      }
      if (TDI_Hook_alert == TRUE) {
         if (g_ibuf_208[li_20] > g_ibuf_204[li_20] && g_ibuf_208[li_20 + 1] > g_ibuf_204[li_20 + 1] && g_ibuf_208[li_20 + 2] < g_ibuf_204[li_20 + 2] && g_ibuf_208[li_20 + 2] < 32.0) {
            g_ibuf_216[li_20] = g_ibuf_212[li_20] - 8.0;
            if (g_ibuf_216[0] != EMPTY_VALUE && Show_Message_alert == TRUE && f0_5()) {
               PlaySound("alert.wav");
               Alert("TDI Hook Up: ", Symbol(), " at ", Close[0], f0_2());
            }
         }
         if (g_ibuf_208[li_20] < g_ibuf_196[li_20] && g_ibuf_208[li_20 + 1] < g_ibuf_196[li_20 + 1] && g_ibuf_208[li_20 + 2] > g_ibuf_196[li_20 + 2] && g_ibuf_208[li_20 + 2] > 68.0) {
            g_ibuf_220[li_20] = g_ibuf_212[li_20] + 8.0;
            if (g_ibuf_220[0] != EMPTY_VALUE && Show_Message_alert == TRUE && f0_5()) {
               PlaySound("alert.wav");
               Alert("TDI Hook Down: ", Symbol(), " at ", Close[0], f0_2());
            }
         }
      }
   }
   return (0);
}

int f0_5() {
   bool bool_0 = Time[0] != g_time_244;
   g_time_244 = Time[0];
   return (bool_0);
}

double f0_1(double ada_0[], int ai_4) {
   return (MathSqrt(f0_3(ada_0, ai_4)));
}

double f0_3(double ada_0[], int ai_4) {
   double ld_8;
   double ld_16;
   for (int index_24 = 0; index_24 < ai_4; index_24++) {
      ld_8 += ada_0[index_24];
      ld_16 += MathPow(ada_0[index_24], 2);
   }
   return ((ld_16 * ai_4 - ld_8 * ld_8) / (ai_4 * (ai_4 - 1)));
}