
// +------------------------------------------------------------------------------------------+ //
// |    .-._______                           XARD777                            _______.-.    | //
// |---( )_)______)                 Knowledge of the ancients                  (______(_( )---| //
// |  (    ()___)                              \¦/                               (___()    )  | //
// |       ()__)                              (o o)                               (__()       | //
// |--(___()_)__________________________oOOo___(_)___oOOo___________________________(_()___)--| //
// |______|______|______|______|______|______|______|______|______|______|______|______|______| //
// |___|______|_Cam__|______|______|______|______|______|______|______|Ismael|______|______|__| //
// |______|______|______|______|______|______|__Big_Joe____|______|______|______|______|______| //
// |___|______|______|______|_Mundu|______|______|______|______|______|______|______|______|__| //
// |______|__cja_|______|______|______|__Hendrik____|______|______|______|______|______|______| //
// |___|______|______|______|______|______|______|______|Tzuman|______|______|______|______|__| //
// |______|______|______|Hercs_|______|______|______|______|______|______|Joy22_|______|______| //
// |___|______|______|______|______|______|___Poruchik__|______|______|______|______|______|__| //
// |______|___Pava_the_Clown___|______|______|______|______|__Leledc_____|______|______|_Xard_| //
// |                                                                                     2011 | //
// |                 File:     !XPS v8 TRENDBARS.mq4                                          | //
// | Programming language:     MQL4                                                           | //
// | Development platform:     MetaTrader 4                                                   | //
// |          End product:     THIS SOFTWARE IS FOR FOREX TRADERS                             | //
// |                                                                                          | //
// |                                                                                          | //
// |     Online Resources:     http://search4metatrader.com/index.php                         | //
// |                           www.2bgoogle.com/forex4.html                                   | //
// |                           www.forex-tsd.com                                              | //
// |                           www.forexstrategiesresources.com                               | //
// |                           www.traderszone.com                                            | //
// |                           http://fxcoder.ru/indicators                                   | //
// |                           www.worldwide-invest.org/                                      | //
// |                           http://indo-investasi.com                                      | //
// |                                                                                          | //
// |                                                           [Xard777 Proprietory Software] | //
// +------------------------------------------------------------------------------------------+ //

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 DeepSkyBlue//Aqua
#property indicator_width1 4
#property indicator_color2 Violet
#property indicator_width2 4
#property indicator_color3 C'127,127,40'
#property indicator_width3 4
#property indicator_color4 C'127,127,40'
#property indicator_width4 4
#property indicator_color5 DeepSkyBlue//Aqua
#property indicator_color6 Violet
#property indicator_color7 C'127,127,40'
#property indicator_color8 C'127,127,40'

int Sensitivity = 2;
int g_period_80;
int g_period_84;
double g_ibuf_88[];
double g_ibuf_92[];
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];

int init() {
   
   ObjectCreate("Close line", OBJ_HLINE, 0, Time[10], Close[0]);
   ObjectSet("Close line", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("Close line", OBJPROP_COLOR, SlateBlue);
   ObjectSet("Close line", OBJPROP_WIDTH, 2);
   ObjectSet("Close line", OBJPROP_BACK, 1); 
    
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, g_ibuf_88);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, g_ibuf_92);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, g_ibuf_96);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(3, g_ibuf_100);
   SetIndexStyle(4, DRAW_HISTOGRAM);
   SetIndexBuffer(4, g_ibuf_104);
   SetIndexStyle(5, DRAW_HISTOGRAM);
   SetIndexBuffer(5, g_ibuf_108);
   SetIndexStyle(6, DRAW_HISTOGRAM);
   SetIndexBuffer(6, g_ibuf_112);
   SetIndexStyle(7, DRAW_HISTOGRAM);
   SetIndexBuffer(7, g_ibuf_116);
   IndicatorShortName("TrendBars");
   return (0);
}

int deinit() {
   ObjectDelete("Close line");
   Comment("");
   return (0);
}

int start() {
   double l_icci_0;
   double l_icci_8;
   int li_16;
   ObjectMove("Close line", 0, Time[10], Close[0]);
   
   if (Sensitivity == 1) {
      g_period_84 = 5;
      g_period_80 = 14;
   }
   if (Sensitivity == 0 || Sensitivity == 2 || Sensitivity > 3) {
      g_period_84 =  8;
      g_period_80 = 34;//48;
   }
   if (Sensitivity == 3) {
      g_period_84 = 89;
      g_period_80 = 200;
   }
   
   int l_ind_counted_20 = IndicatorCounted();
   if (Bars <= 15) return (0);
   if (l_ind_counted_20 < 1) {
      for (int li_24 = 1; li_24 <= 15; li_24++) {
         g_ibuf_88[Bars - li_24] = 0.0;
         g_ibuf_96[Bars - li_24] = 0.0;
         g_ibuf_92[Bars - li_24] = 0.0;
         g_ibuf_100[Bars - li_24] = 0.0;
         g_ibuf_104[Bars - li_24] = 0.0;
         g_ibuf_112[Bars - li_24] = 0.0;
         g_ibuf_108[Bars - li_24] = 0.0;
         g_ibuf_116[Bars - li_24] = 0.0;
      }
   }
   if (l_ind_counted_20 > 0) li_16 = Bars - l_ind_counted_20;
   if (l_ind_counted_20 == 0) li_16 = Bars - 15 - 1;
   for (li_24 = li_16; li_24 >= 0; li_24--) {
      l_icci_0 = iCCI(NULL, 0, g_period_84, PRICE_TYPICAL, li_24);
      l_icci_8 = iCCI(NULL, 0, g_period_80, PRICE_TYPICAL, li_24);
      
      g_ibuf_88[li_24] = EMPTY_VALUE;
      g_ibuf_96[li_24] = EMPTY_VALUE;
      g_ibuf_92[li_24] = EMPTY_VALUE;
      g_ibuf_100[li_24] = EMPTY_VALUE;
      g_ibuf_104[li_24] = EMPTY_VALUE;
      g_ibuf_112[li_24] = EMPTY_VALUE;
      g_ibuf_108[li_24] = EMPTY_VALUE;
      g_ibuf_116[li_24] = EMPTY_VALUE;
      
      if (l_icci_0 >= 0.0 && l_icci_8 >= 0.0) {
         g_ibuf_88[li_24] = MathMax(Open[li_24], Close[li_24]);
         g_ibuf_92[li_24] = MathMin(Open[li_24], Close[li_24]);
         g_ibuf_104[li_24] = High[li_24];
         g_ibuf_108[li_24] = Low[li_24];
      } else {
         if (l_icci_8 >= 0.0 && l_icci_0 < 0.0) {
            g_ibuf_96[li_24] = MathMax(Open[li_24], Close[li_24]);
            g_ibuf_100[li_24] = MathMin(Open[li_24], Close[li_24]);
            g_ibuf_112[li_24] = High[li_24];
            g_ibuf_116[li_24] = Low[li_24];
         } else {
            if (l_icci_0 < 0.0 && l_icci_8 < 0.0) {
               g_ibuf_92[li_24] = MathMax(Open[li_24], Close[li_24]);
               g_ibuf_88[li_24] = MathMin(Open[li_24], Close[li_24]);
               g_ibuf_108[li_24] = High[li_24];
               g_ibuf_104[li_24] = Low[li_24];
            } else {
               if (l_icci_8 < 0.0 && l_icci_0 > 0.0) {
                  g_ibuf_100[li_24] = MathMax(Open[li_24], Close[li_24]);
                  g_ibuf_96[li_24] = MathMin(Open[li_24], Close[li_24]);
                  g_ibuf_116[li_24] = High[li_24];
                  g_ibuf_112[li_24] = Low[li_24];
               }
            }
         }
      }
   }
   return (0);
}
// ------------------------------------------------------------------------------------------ //
//                                     E N D   P R O G R A M                                  //
// ------------------------------------------------------------------------------------------ //
/*                                                         
                                        ud$$$**BILLION$bc.                          
                                    u@**"        PROJECT$$Nu                       
                                  J                ""#$$$$$$r                     
                                 @                       $$$$b                    
                               .F                        ^*3$$$                   
                              :% 4                         J$$$N                  
                              $  :F                       :$$$$$                  
                             4F  9                       J$$$$$$$                 
                             4$   k             4$$$$bed$$$$$$$$$                 
                             $$r  'F            $$$$$$$$$$$$$$$$$r                
                             $$$   b.           $$$$$$$$$$$$$$$$$N                
                             $$$$$k 3eeed$$b    XARD777."$$$$$$$$$                
              .@$**N.        $$$$$" $$$$$$F'L $$$$$$$$$$$  $$$$$$$                
              :$$L  'L       $$$$$ 4$$$$$$  * $$$$$$$$$$F  $$$$$$F         edNc   
             @$$$$N  ^k      $$$$$  3$$$$*%   $F4$$$$$$$   $$$$$"        d"  z$N  
             $$$$$$   ^k     '$$$"   #$$$F   .$  $$$$$c.u@$$$          J"  @$$$$r 
             $$$$$$$b   *u    ^$L            $$  $$$$$$$$$$$$u@       $$  d$$$$$$ 
              ^$$$$$$.    "NL   "N. z@*     $$$  $$$$$$$$$$$$$P      $P  d$$$$$$$ 
                 ^"*$$$$b   '*L   9$E      4$$$  d$$$$$$$$$$$"     d*   J$$$$$r   
                      ^$$$$u  '$.  $$$L     "#" d$$$$$$".@$$    .@$"  z$$$$*"     
                        ^$$$$. ^$N.3$$$       4u$$$$$$$ 4$$$  u$*" z$$$"          
                          '*$$$$$$$$ *$b      J$$$$$$$b u$$P $"  d$$P             
                             #$$$$$$ 4$ 3*$"$*$ $"$'c@@$$$$ .u@$$$P               
                               "$$$$  ""F~$ $uNr$$$^&J$$$$F $$$$#                 
                                 "$$    "$$$bd$.$W$$$$$$$$F $$"                   
                                   ?k         ?$$$$$$$$$$$F'*                     
                                    9$$bL     z$$$$$$$$$$$F                       
                                     $$$$    $$$$$$$$$$$$$                        
                                      '#$$c  '$$$$$$$$$"                          
                                       .@"#$$$$$$$$$$$$b                          
                                     z*      $$$$$$$$$$$$N.                       
                                   e"      z$$"  #$$$k  '*$$.                     
                                .u*      u@$P"      '#$$c   "$$c                   
                        u@$*"""       d$$"            "$$$u  ^*$$b.               
                      :$F           J$P"                ^$$$c   '"$$$$$$bL        
                     d$$  ..      @$#                      #$$b         '#$       
                     9$$$$$$b   4$$                          ^$$k         '$      
                      "$$6""$b u$$                             '$    d$$$$$P      
                        '$F $$$$$"                              ^b  ^$$$$b$       
                         '$W$$$$"                                'b@$$$$"         
                                                                  ^$$$*/     