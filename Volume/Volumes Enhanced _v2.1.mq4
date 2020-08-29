//+------------------------------------------------------------------+
//|                                                                  |
//|                      Volumes Enhanced.mq4                        |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 traderathome"
#property link      "email:   traderathome@msn.com"
/*--------------------------------------------------------------------
Acknowledgements:

Vadim Shumiloff, for his core coding of "NormalizedVolumeOscillator".

MissPips, for her gracious coding critical to enabling the "Crown Jewels" 
of this effort....the real-time update of the current bar volume, and 
the percentage that volume is to the average bar volume for the selected 
averaging period.

Domas1, for his coding _v2 with a sound alert, including the addition 
of the female voice sound alert!
-----------------------------------------------------------------------
Volumes Enhanced:

This indicator is based upon the "NormalizedVolumeOscillator" by 
Vadim Shumiloff.  Considerable enhancements are made which enable this 
new indicator to display a normal 'Volumes' study, overlayed with colors 
for different graduations of volume amounts, computed using core coding
of the referenced indicator.

The volume study, enhanced with the volume graduation colors, can be
full sized in the study window, or it can be downsized (for example: 
occupying only the bottom half or bottom third of the study window).
This downsizing feature allows this indicator to be 'dragged and dropped'
into the window of another indicator that may not be using the bottom
most area of the study window, thus conserving space.

The BarHeightNumber "1" sets a full sized display, which is to say that
the volume histogram bars are the full normal height within the study
window.  Using "2" cuts those bars in half, so only the lower half of
the study window is being used.  Using "3" means only the bottom third
of the study window is used, etc.  A non-integer value is accepted 
(example: 1.25 provides slightly less than normal height volume bars, 
giving a little extra clearance at the top of the study window).  

The volume bars for the various volume graduations display at proper
height within the overall volume study. But they can be emphasized 
with different colors and by varying their width from the normal bars 
they overlay, thus enhancing the total volume study.
  
You can alter the graduations. Their default settings of 33 & 66
divide the range from 'normal volume' to '100% normal volume'
into three equal parts.  You can choose to not display a graduation.
To avoid displaying it, simply assign it the same histogram bar
thickness and color of the background 'Volumes' bars.  You are not
restricted to having "over 100%" as the top volume graduation.  You can 
increase this, for example, to "over 150%" and selecting the 3 numbers 
to divide the 0 - 150 range (example: 50,100,150).

You can eliminate the display of the normal histogram and selected 
graduations by coloring them "CLR_NONE", of if this does not work 
satisfactorily, color them the same as the chart background color.
This will cause only the remaining graduated colored bars to be shown.

The Color tab of the Indicator's Properties Window allows you to set 
the color and width of the normal histogram, of the three graduations 
between 0-100, and the 100+ graduation.  In addition to these, the 
first two items on the list are for the zero line (normally not used) 
and an extra, "Phantom" normal histogram, which is required to maintain
the indicator window height when the display is "shrunken" within the
window of another indicator.  This item should always be made invisible 
using "CLR_NONE" as the color choice.  If this does not work, then it 
should be colored the same color as the chart background.

The "Volume" and "Percent" labels can be turned ON/OFF by selecting 
true/false.  The text can be moved left, away from the values, by 
increasing the numerical input for "Widen_text_labels".
----------------------------------------------------------------------
_v2:
Adds Volume AlertLevel input.  In external inputs enter an amount
for the AlertLevel volume and specify what time freme it is for
(for example:  "500" volume on a  "15" minute time frame).  As the
chart TF is altered, the Volume AlertLevel line will automatically 
adjust.  Compliments of Domas4, a female voice SoundAlert is included.  
The standard MT4 visual/audio Alert is also included.  You can turn
either, neither or both of these alerts on.  The "BriefMode" codes
are deleted.
                                                       - Traderathome
----------------------------------------------------------------------
Volume Bar Colors Recommended:

  WHITE CHART   BLACK CHART
  Magenta       Magenta         Alert Level Line                                                  
  Silver        DarkSlateBlue   Volumes from zero up to average
  C'0,145,0'    Green           Volumes in 1st graduation over average
  LimeGreen     LimeGreen       Volumes in 2nd graduation over average  
  Blue          Yellow          Volumes in 3rd graduation over average
  Red           WhiteSmoke      Volumes in final graduation over average 
  DarkGray      DarkSlateBlue   Zero Axis line                                                         
--------------------------------------------------------------------*/
#property indicator_chart_window

#property indicator_buffers 13
#property indicator_color1 clrNONE        // Phantom histogram maintains normal window height
#property indicator_color2 clrNONE        // Phantom histogram maintains normal window height

#property indicator_width1 1  
#property indicator_width2 1  
  


#property indicator_color3  clrDarkSlateBlue    // Volumes from zero up to average
#property indicator_color4  clrNONE
#property indicator_color5  clrGreen            // Volumes in 1st graduation over average
#property indicator_color6  clrNONE
#property indicator_color7  clrLimeGreen        // Volumes in 2nd graduation over average
#property indicator_color8  clrNONE
#property indicator_color9  clrYellow           // Volumes in 3rd graduation over average
#property indicator_color10 clrNONE
#property indicator_color11 clrWhiteSmoke       // Volumes in final graduation over average
#property indicator_color12 clrNONE
#property indicator_color13 clrMagenta          // Volume AlertLevel Line (500-1000 typically)

#property indicator_width3  2
#property indicator_width4  2  
#property indicator_width5  2
#property indicator_width6  2  
#property indicator_width7  2
#property indicator_width8  2
#property indicator_width9  2 
#property indicator_width10 2
#property indicator_width11 2
#property indicator_width12 2
#property indicator_width13 1
/*---------------------------------------------------------------------
Label Colors Suggested:

  White CHART     Black CHART

  C'159,0,244'    C'194,81,255'    Label for volume amount
  C'106,106,106'  CornflowerBlue   Volumes from zero up to average
  Green           C'39,163,39'     Volumes in 1st graduation over average
  C'11,176,6'     LimeGreen        Volumes in 2nd graduation over average
  Blue            Yellow           Volumes in 3rd graduation over average
  Crimson         WhiteSmoke       Volumes in final graduation over average
  DarkGray        DimGray          AlertV label for untriggered status
  C'230,0,230'    Magenta          AlertV label for triggered status 
----------------------------------------------------------------------*/
//---- External Inputs 
extern bool   Indicator_On                     = true;
extern int    Averaging_Period                 = 10;
extern int    Volume_AlertLevel                = 250;
extern int    For_TimeFrame                    = 15;
extern bool   Show_AlertLevel_Line             = true;
extern bool   SoundAlert_With_Voice            = false;
extern bool   SoundAlert_MessageBox            = false;
extern bool   Show_ZeroLevel_Line              = true;
extern string _                                = "";
extern string Part_1                           = "Setting Volume Bar Height in Window:";
extern string note1                            = "You can reduce volume bar height.";
extern string note2                            = "BarHeightNumber 2= half of window.";
extern string note3                            = "2=1/2   3=1/3   4=1/4   5=1/5   etc";
extern double BarHeightNumber                  = 1.0;
extern double VolumeHeightPercent              = 0.2;
extern string __                               = "";
extern string Part_2                           = "Setting Volume Graduations:";
extern string note4_                           = "Enter 3 numbers dividing volume into";
extern string note5_                           = "5 graduations.  Defaults 33, 66, 100";
extern string note6_                           = "product these 5 percent graduations:";
extern string note9                            = "<0   0-33   33-66   66-100   >=100";
extern double Enter_Number_1                   = 33;
extern double Enter_Number_2                   = 66;
extern double Enter_Number_3                   = 100;
extern string ___                              = "";
extern string Part_3                           = "Volume & Percent Labels Settings:";
extern bool   Display_Labels                   = true;
extern int    Corner_0123                      = 3;
extern int    Horizontal_Indent                = 5;
extern int    Vertical_Indent                  = 1; 
extern int    FontStyle_Normal_Bold_12         = 1;
extern int    Widen_labels                     = 2;
extern int    Add_Space_Between_Labels         = 2;
extern color  VolumeLabel_Color                = C'194,81,255'; 
extern color  LabelColorForGraduation_0        = clrCornflowerBlue;     
extern color  LabelColorForGraduation_1        = C'39,163,39';    
extern color  LabelColorForGraduation_2        = clrLimeGreen; 
extern color  LabelColorForGraduation_3        = clrYellow;     
extern color  LabelColorForGraduation_4        = clrWhiteSmoke; 
extern color  AlertVlabel_Untriggered_Color    = clrDimGray;  
extern color  AlertVlabel_Triggered_Color      = clrMagenta;       

//---- Buffers & Other Inputs
double VolBufferH1[];
double VolBufferH3[];
double VolBufferH4[];
double VolBufferH5[];
double VolBufferH6[];
double VolBufferH7[];

double VolBufferH1min[];
double VolBufferH3min[];
double VolBufferH4min[];
double VolBufferH5min[];
double VolBufferH6min[];
double VolBufferH7min[];
double VolBufferH2[];

int      Window_0123 = 0;
datetime ct1, ct2;
double   prev_minprice, prev_maxprice, maxvolume;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
   {
   ct1 = iTime(NULL,0,1); ct2 = ct1;
     
   
   IndicatorDigits(Digits);
      
   SetIndexBuffer(0 , VolBufferH1   ); SetIndexStyle( 0, DRAW_HISTOGRAM);    //This draws phantom normal bars forcing normal window height
   SetIndexBuffer(1 , VolBufferH1min); SetIndexStyle( 1, DRAW_HISTOGRAM);
         
   SetIndexBuffer(2 , VolBufferH3   ); SetIndexStyle( 2, DRAW_HISTOGRAM);    //This draws the bars for Voumes from zero up to average
   SetIndexBuffer(3 , VolBufferH3min); SetIndexStyle( 3, DRAW_HISTOGRAM);
   
   SetIndexBuffer(4 , VolBufferH4   ); SetIndexStyle( 4, DRAW_HISTOGRAM);    //This draws the bars for Volumes in 1st graduation over average
   SetIndexBuffer(5 , VolBufferH4min); SetIndexStyle( 5, DRAW_HISTOGRAM);
   
   SetIndexBuffer(6 , VolBufferH5   ); SetIndexStyle( 6, DRAW_HISTOGRAM);    //This draws the bars for Volumes in 2nd graduation over average
   SetIndexBuffer(7 , VolBufferH5min); SetIndexStyle( 7, DRAW_HISTOGRAM); 
   
   SetIndexBuffer(8 , VolBufferH6   ); SetIndexStyle( 8, DRAW_HISTOGRAM);    //This draws the bars for Volumes in 3rd graduation over average
   SetIndexBuffer(9 , VolBufferH6min); SetIndexStyle( 9, DRAW_HISTOGRAM); 
   
   SetIndexBuffer(10, VolBufferH7   ); SetIndexStyle(10, DRAW_HISTOGRAM);   //This draws the bars for Volumes in final graduation over average
   SetIndexBuffer(11, VolBufferH7min); SetIndexStyle(11, DRAW_HISTOGRAM); 
   
   if(Show_AlertLevel_Line){   
   SetIndexBuffer(12, VolBufferH2   ); SetIndexStyle(12,     DRAW_LINE);}    //This draws the AlertLevel line (500-1000 typically)
       
 
   
   //---- Indicator Window name and data labels 
   string short_name = "Volumes Enhanced_v2.1"; 
   IndicatorShortName(short_name); 
   SetIndexLabel( 0,  NULL);
   SetIndexLabel( 1,  NULL);
   SetIndexLabel( 2,  NULL);
   SetIndexLabel( 3,  NULL);
   SetIndexLabel( 4,  NULL);
   SetIndexLabel( 5,  NULL);
   SetIndexLabel( 6,  NULL);
   SetIndexLabel( 7,  NULL);
   SetIndexLabel( 8,  NULL);
   SetIndexLabel( 9,  NULL);
   SetIndexLabel(10,  NULL);
   SetIndexLabel(11,  NULL);
   SetIndexLabel(12,  NULL); 
   
   
   
   return(0);
   }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
   {
   int obj_total= ObjectsTotal();  
   for (int i= obj_total; i>=0; i--) {
      string name= ObjectName(i);    
      if (StringSubstr(name,0,18)=="[Volumes Enhanced]"){ObjectDelete(name);} } 
   return(0);
   }

//+-------------------------------------------------------------------+
//| Calculations body of program                                      |                                                        
//+-------------------------------------------------------------------+
int start()
   {
   deinit();if (Indicator_On == false) {
   IndicatorShortName("Volumes Enhanced_v2  ("+Averaging_Period+", "+Volume_AlertLevel+")  -Indicator is off.   ");
   return(0);}
    
   
   //Volume by timeframe indexing
   double Vin = Volume_AlertLevel;
   double Vout;
   double Vsum;
   if(For_TimeFrame == 1)    {Vsum = Vin*5*15*30*60*240*1440*10080*43200;}
   if(For_TimeFrame == 5)    {Vsum = Vin*15*30*60*240*1440*10080*43200;}
   if(For_TimeFrame ==15)    {Vsum = Vin*5*30*60*240*1440*10080*43200;}
   if(For_TimeFrame ==30)    {Vsum = Vin*5*15*60*240*1440*10080*43200;} 
   if(For_TimeFrame ==60)    {Vsum = Vin*5*15*30*240*1440*10080*43200;}
   if(For_TimeFrame ==240)   {Vsum = Vin*5*15*30*60*1440*10080*43200;} 
   if(For_TimeFrame ==1440)  {Vsum = Vin*5*15*30*60*240*10080*43200;} 
   if(For_TimeFrame ==10080) {Vsum = Vin*5*15*30*60*240*1440*43200;} 
   if(For_TimeFrame ==43200) {Vsum = Vin*5*15*30*60*240*1440*10080;} 
   
   if(Period()== 1)     {Vout = Vsum/5/15/30/60/240/1440/10080/43200;}
   if(Period()== 5)     {Vout = Vsum/15/30/60/240/1440/10080/43200;}
   if(Period()== 15)    {Vout = Vsum/5/30/60/240/1440/10080/43200;}
   if(Period()== 30)    {Vout = Vsum/5/15/60/240/1440/10080/43200;}
   if(Period()== 60)    {Vout = Vsum/5/15/30/240/1440/10080/43200;}
   if(Period()== 240)   {Vout = Vsum/5/15/30/60/1440/10080/43200;}
   if(Period()== 1440)  {Vout = Vsum/5/15/30/60/240/10080/43200;}
   if(Period()== 10080) {Vout = Vsum/5/15/30/60/240/1440/43200;}
   if(Period()== 43200) {Vout = Vsum/5/15/30/60/240/1440/10080;}
   
   double Volume_Alert_Displayed = Vout; 
   string Vlabel= DoubleToStr(Vout,0);
   IndicatorShortName("Volumes Enhanced_v2  (Period " + Averaging_Period + ", Alert Level " + Vlabel + ")   ");
   if(Show_AlertLevel_Line==false){IndicatorShortName("Volumes Enhanced_v2  (Period "+Averaging_Period+", Alert Level off)   ");}  
     
   //Get volume bar heights       
   double nvo;  
   int counted_bars = IndicatorCounted();      
   
   double minprice = ChartPriceMin(0);
   double maxprice = ChartPriceMax(0);
   
   if(prev_minprice != minprice || prev_maxprice != maxprice)
   {
   counted_bars = 0;
   prev_minprice = minprice;
   prev_maxprice = maxprice;
   }
   
   
   for(int i = Bars-1-counted_bars; i >= 0; i--) maxvolume = MathMax(Volume[i],maxvolume);
   
   double scale = VolumeHeightPercent*(maxprice - minprice)/maxvolume;
   
   for(i = Bars-1-counted_bars; i >= 0; i--) 
      {
      //---- Specify IndicatorShortName that will display current bar volume in real-time
      //IndicatorShortName("Volumes Emphasized_v2  ( Period " + Volume_Averaging_Period + ",  Current Bar Volume "+ DoubleToStr(iVolume(NULL,0,i),0) + " )");
                  
      VolBufferH1[i]    = minprice + scale*Volume[i]*BarHeightNumber;       //force window height larger based on shrink factor 
      VolBufferH1min[i] = minprice;
      VolBufferH2[i]    = minprice + scale*Vout;                            //Volume AlertLevel Line = 500 to 1000 typically       
      VolBufferH3[i]    = minprice + scale*Volume[i];                       //normal volume bars can be displayed as backdrop
      VolBufferH3min[i] = minprice;
      VolBufferH4[i]    = minprice;//0;                               //one of the four graduation level overlay buffers for each [i]
      VolBufferH4min[i] = minprice;
      VolBufferH5[i]    = minprice;//0;                               //one of the four graduation level overlay buffers for each [i]  
      VolBufferH5min[i] = minprice;
      VolBufferH6[i]    = minprice;//0;                               //one of the four graduation level overlay buffers for each [i]
      VolBufferH6min[i] = minprice;
      VolBufferH7[i]    = minprice;//0;                               //one of the four graduation level overlay buffers for each [i]
      VolBufferH7min[i] = minprice;
     
                                        
      int Salert1= Volume[i]; 
      int Salert2= Vout;
                                                                                
      nvo = nvoSubr(i)*100 - 100; //goto "NormalizedVolume" subroutine for NormalizedVolume percent of period average volume       
      if (nvo<0) {VolBufferH3[i]=minprice + scale*Volume[i];}   
         else {if (nvo<Enter_Number_1) {VolBufferH4[i]=minprice + scale*Volume[i];}  //nvo<Enter_Number_1    
            else {if (nvo<Enter_Number_2) {VolBufferH5[i]=minprice + scale*Volume[i];}  //nvo<Enter_Number_2
               else {if (nvo<Enter_Number_3) {VolBufferH6[i]=minprice + scale*Volume[i];}  //nvo<Enter_Number_3
                  else {VolBufferH7[i]=minprice + scale*Volume[i];}  //nvo=>Enter_Number_3
               }
             } 
           } 
                   
      if(Display_Labels)
         { 
         //Volume label
         string Spc1 = ""; for (int j = 0; j<Widen_labels; j++) {Spc1 = Spc1 + " ";}    
         string spc = ""; if (FontStyle_Normal_Bold_12 == 1){spc = spc + " ";}        
         string Nvo = ""; string Font = "Arial"; string Vol = "";string BarVol="";string BarPct="";         
         if (FontStyle_Normal_Bold_12 == 2){Font = "Arial Bold";}  
              
         Vol = DoubleToStr(Volume[i], Digits-4);
         if(StringLen(Vol)==1){Vol = "          "+Vol;}
         if(StringLen(Vol)==2){Vol = "        "+Vol;} 
         if(StringLen(Vol)==3){Vol = "      "+Vol;} 
         if(StringLen(Vol)==4){Vol = "    "+Vol;}   
         if(StringLen(Vol)==5){Vol = "  "+Vol;} 
         if(StringLen(Vol)==6){Vol = ""+Vol;} 

         if(FontStyle_Normal_Bold_12 == 1)
            {BarVol = "Volume:"+Spc1; VolumeSubr(BarVol+Vol+" v ", VolumeLabel_Color, 10, Font);}         
         if(FontStyle_Normal_Bold_12 == 2) 
            {BarVol = "Volume:"+Spc1; VolumeSubr(BarVol+Vol+" v", VolumeLabel_Color, 10, Font);}         
      
         //Percent label
         Nvo = DoubleToStr(nvo+100, Digits-4);       
         if(StringLen(Nvo)==1){Nvo = "      "+Nvo;}
         if(StringLen(Nvo)==2){Nvo = "    "+Nvo;}
         if(StringLen(Nvo)==3){Nvo = "  "+Nvo;}
                        
         if (nvo<0){BarPct = "Percent:    "+Spc1; PercentSubr(BarPct+Nvo+"%",LabelColorForGraduation_0,10,Font);}                
         else {if (nvo<Enter_Number_1){BarPct = "Percent:    "+Spc1; PercentSubr(BarPct+Nvo+"%",LabelColorForGraduation_1,10,Font);}              
            else {if (nvo<Enter_Number_2){BarPct = "Percent:    "+Spc1; PercentSubr("Percent:    "+Spc1+Nvo+"%",LabelColorForGraduation_2,10,Font);}           
               else {if (nvo<Enter_Number_3){BarPct = "Percent:    "+Spc1; PercentSubr("Percent:    "+Spc1+Nvo+"%",LabelColorForGraduation_3,10,Font);}                      
                  else {BarPct = "Percent:    "+Spc1; PercentSubr("Percent:    "+Spc1+Nvo+"%",LabelColorForGraduation_4,10,Font);}  }}}  
                  
         //AlertV label         
         string VolVout = DoubleToStr(Vout, Digits-4); string Vout1= VolVout;
         if(StringLen(VolVout)==1){VolVout = "          "+VolVout;}
         if(StringLen(VolVout)==2){VolVout = "        "+VolVout;} 
         if(StringLen(VolVout)==3){VolVout = "      "+VolVout;} 
         if(StringLen(VolVout)==4){VolVout = "    "+VolVout;}   
         if(StringLen(VolVout)==5){VolVout = "  "+VolVout;} 
         if(StringLen(VolVout)==6){VolVout = ""+VolVout;} 

         if(SoundAlert_With_Voice == false && SoundAlert_MessageBox== false) {
         if(Vout > Volume[i]) {                 
            if(FontStyle_Normal_Bold_12 == 1)
            {BarVol = "AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v ", AlertVlabel_Untriggered_Color, 10, Font);}       
            if(FontStyle_Normal_Bold_12 == 2) 
            {BarVol = "AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v", AlertVlabel_Untriggered_Color, 10, Font);}}                 
         if(Volume[i] >= Vout) {                 
            if(FontStyle_Normal_Bold_12 == 1)
            {BarVol = "AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v ", AlertVlabel_Triggered_Color, 10, Font);}        
            if(FontStyle_Normal_Bold_12 == 2) 
            {BarVol = "AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v", AlertVlabel_Triggered_Color, 10, Font);}}} 
                       
         if(SoundAlert_With_Voice || SoundAlert_MessageBox) {
         if(Vout > Volume[i]) {                 
            if(FontStyle_Normal_Bold_12 == 1)
            {BarVol = "*AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v ", AlertVlabel_Untriggered_Color, 10, Font);}       
            if(FontStyle_Normal_Bold_12 == 2) 
            {BarVol = "*AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v", AlertVlabel_Untriggered_Color, 10, Font);}}                 
         if(Volume[i] >= Vout) {                 
            if(FontStyle_Normal_Bold_12 == 1)
            {BarVol = "*AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v ", AlertVlabel_Triggered_Color, 10, Font);}        
            if(FontStyle_Normal_Bold_12 == 2) 
            {BarVol = "*AlertV:"+Spc1; AlertVSubr(BarVol+VolVout+" v", AlertVlabel_Triggered_Color, 10, Font);}}}                                                  
         } //End Display labels
      } //End volume histogram, labels, sound alert  
       
      //Alert sound with message subsection
      if(SoundAlert_MessageBox){    
         if(ct1 != iTime(NULL,0,0) && Salert1 >= Salert2){
            Alert(Symbol()," - ",Period(),"    Volume Alert:   "+Vout1);
            ct1 = iTime(NULL,0,0);}} 
             
      //Alert sound without message subsection
      if(SoundAlert_With_Voice){  
         if(ct2 != iTime(NULL,0,0) && Salert1 >= Salert2){
            PlaySound("vol_alert.wav");
            ct2 = iTime(NULL,0,0);}}   
                                                     
   return(0);
   }
    
//+-------------------------------------------------------------------+
//| Subroutine to compute normalized volume                           |                                                        
//+-------------------------------------------------------------------+
double nvoSubr(int i)
   {
   double nv = 0;
   for (int j = i; j < (i+Averaging_Period); j++) nv = nv + Volume[j];
   nv = nv / Averaging_Period;
   return (Volume[i] / nv);
   }
        
//+-------------------------------------------------------------------+
//| Subroutine to draw Volume text label                              |                                                        
//+-------------------------------------------------------------------+
void VolumeSubr (string text, color Color, int fontsize, string fontstyle) 
   {
   ObjectDelete("[Volumes Enhanced] Vol");
   ObjectCreate("[Volumes Enhanced] Vol", OBJ_LABEL, Window_0123, 0, 0);
   ObjectSet("[Volumes Enhanced] Vol", OBJPROP_CORNER, Corner_0123);
   ObjectSet("[Volumes Enhanced] Vol", OBJPROP_XDISTANCE, Horizontal_Indent);
   ObjectSet("[Volumes Enhanced] Vol", OBJPROP_YDISTANCE,  Vertical_Indent+24+2*(Add_Space_Between_Labels));
   if(Corner_0123<2){ObjectSet("[Volumes Enhanced] Vol", OBJPROP_YDISTANCE,  Vertical_Indent-24-2*(Add_Space_Between_Labels));}
   ObjectSet("[Volumes Enhanced] Vol", OBJPROP_COLOR, Color);
   ObjectSetText("[Volumes Enhanced] Vol", text, fontsize, fontstyle);    
   }

//+-------------------------------------------------------------------+
//| Subroutine to draw Percent text label                             |                                                        
//+-------------------------------------------------------------------+
void PercentSubr(string text, color Color, int fontsize, string fontstyle)  
   {
   ObjectDelete("[Volumes Enhanced] Pct");
   ObjectCreate("[Volumes Enhanced] Pct", OBJ_LABEL, Window_0123, 0, 0);
   ObjectSet("[Volumes Enhanced] Pct", OBJPROP_CORNER, Corner_0123);
   ObjectSet("[Volumes Enhanced] Pct", OBJPROP_XDISTANCE, Horizontal_Indent);
   ObjectSet("[Volumes Enhanced] Pct", OBJPROP_YDISTANCE,  Vertical_Indent+12+Add_Space_Between_Labels);
  if(Corner_0123<2){ObjectSet("[Volumes Enhanced] Pct", OBJPROP_YDISTANCE,  Vertical_Indent-12-Add_Space_Between_Labels);}   
   ObjectSet("[Volumes Enhanced] Pct", OBJPROP_COLOR, Color);
   ObjectSetText("[Volumes Enhanced] Pct", text, fontsize, fontstyle);    
   }
        
//+-------------------------------------------------------------------+
//| Subroutine to draw AlertV text label                              |                                                        
//+-------------------------------------------------------------------+
void AlertVSubr (string text, color Color, int fontsize, string fontstyle) 
   {
   ObjectDelete("[Volumes Enhanced] AlertV");
   ObjectCreate("[Volumes Enhanced] AlertV", OBJ_LABEL, Window_0123, 0, 0);
   ObjectSet("[Volumes Enhanced] AlertV", OBJPROP_CORNER, Corner_0123);
   ObjectSet("[Volumes Enhanced] AlertV", OBJPROP_XDISTANCE, Horizontal_Indent);
   ObjectSet("[Volumes Enhanced] AlertV", OBJPROP_YDISTANCE,  Vertical_Indent);
   if(Corner_0123<2){ObjectSet("[Volumes Enhanced] AlertV", OBJPROP_YDISTANCE,  Vertical_Indent);}
   ObjectSet("[Volumes Enhanced] AlertV", OBJPROP_COLOR, Color);
   ObjectSetText("[Volumes Enhanced] AlertV", text, fontsize, fontstyle);    
   }
   
//+-------------------------------------------------------------------+
//| End of program                                                    |                                                        
//+-------------------------------------------------------------------+

//+---------------------------------------------------------------------------------+
//| The function receives the value of the chart minimum in the main window or a    |
//| subwindow.                                                                      |
//+---------------------------------------------------------------------------------+
double ChartPriceMin(const long chart_ID=0,const int sub_window=0)
{
//--- prepare the variable to get the result
   double result = EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetDouble(chart_ID,CHART_PRICE_MIN,sub_window,result))
   {
   //--- display the error message in Experts journal
   Print(__FUNCTION__+", Error Code = ",GetLastError());
   }
//--- return the value of the chart property
   return(result);
}

//+--------------------------------------------------------------------------------+
//| The function receives the value of the chart maximum in the main window or a   |
//| subwindow.                                                                     |
//+--------------------------------------------------------------------------------+
double ChartPriceMax(const long chart_ID=0,const int sub_window=0)
{
//--- prepare the variable to get the result
   double result=EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetDouble(chart_ID,CHART_PRICE_MAX,sub_window,result))
   {
   //--- display the error message in Experts journal
   Print(__FUNCTION__+", Error Code = ",GetLastError());
   }
//--- return the value of the chart property
   return(result);
}