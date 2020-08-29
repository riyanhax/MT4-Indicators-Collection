//+-------------------------------------------------------------------------------------------+
//|                                                                                           |
//|                                   SonicR PVA Volumes.mq4                                  |
//|                                                                                           |
//+-------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2014 traderathome and qFish"
#property link      "email:   traderathome@msn.com"

/*---------------------------------------------------------------------------------------------
User Notes:

This indicator is coded to run on MT4 Build 600.

This indicator creates standard volume bars to be used together with the SonicR PVA Candles 
indicator.  Special colors are used denote candles and corresponding volume bars where special 
situations occur involving price and volume, hence PVA (Price-Volume Analysis).  The special 
situations, or requirements for the colors are as follows.

Situation "Climax"
   Bars with volume >= 200% of the average volume of the 10 most recent previous chart TFs,
   and bars where the product of candle spread x candle volume is >= the highest for the 10 
   most recent previous chart time TFs.  Bull bars are green and bear bars are red.
        
Situation "Volume Rising Above Average" 
   Bars with volume >= 150% of the average volume of the 10 most recent previous chart TFs.
   Bull bars are blue and bear are blue-violet.         

Setting the Volume Alert-
This indicator includes the sound with text alert that will trigger once per TF at the first
qualification of the volume bar as a "Climax" volume situation.  Set "Volume_Alert_On" to
"true" to activate the alert.  You can use your "Broker_Name_In_Alert" so that your broker 
name so it will appear in the on-screen alert tile.  This helps to avoid confusion if you
simultaneously use multiple platforms from different brokers.

Changes from release 05-25-2013 to current release 03-17-2014:     
01 - Removed the automatic and manual zoom selections.  Recoded using feature in new MQL4 for 
     automating bar width adjustments as chart is scaled in/out. 
02 - Corrected period calculation coding.        
03 - Added code to assure the scale for volume bars starts at zero.
04 - Improved the Alert coding.
          
                                                                    - Traderathome, 03-17-2014
-----------------------------------------------------------------------------------------------
Acknowledgements:
BetterVolume.mq4 - for "climax" candle code definition (BetterVolume_v1.4). 

----------------------------------------------------------------------------------------------
Suggested Colors            White Chart        Black Chart        Remarks
                             
indicator_color1            C'113,131,149'     C'102,099,163'     Normal Volume
indicator_color2            C'045,081,206'     C'017,136,255'     Bull Rising
indicator_color3            C'154,038,232'     C'173,051,255'     Bear Rising
indicator_color4            C'000,166,100'     C'033,207,077'     Bull Climax 
indicator_color5            C'214,012,083'     C'224,001,006'     Bear Climax
 
Note: Suggested colors coincide with the colors of the SonicR Suite of Candles indicator.             
---------------------------------------------------------------------------------------------*/


//+-------------------------------------------------------------------------------------------+
//| Indicator Global Inputs                                                                   |                                                        
//+-------------------------------------------------------------------------------------------+ 
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_minimum 0

#property indicator_color1  C'102,099,163'
#property indicator_color2  C'017,136,255'
#property indicator_color3  C'173,051,255' 
#property indicator_color4  C'033,207,077'
#property indicator_color5  C'224,001,006'

//Global External Inputs 
extern bool   Indicator_On                    = true;
extern bool   Volume_Alert_On                 = true;
extern string Broker_Name_In_Alert            = "";

//Global Buffers and Variables
bool          Deinitialized;       
int           Chart_Scale,i,j,n,Bar_Width,counted_bars,limit; 
double        Normal[],RisingBull[],RisingBear[],ClimaxBull[],ClimaxBear[],
              av,rv,Range,Value2,HiValue2,tempv2;
string        ShortName;

//Alert
bool          Alert_Allowed;
static bool   allow = true;
static bool   disallow = false; 
     
//+-------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                  |
//+-------------------------------------------------------------------------------------------+
int init()
  {
  Deinitialized = false;   
  
  //Determine the current chart scale (chart scale number should be 0-5)
  Chart_Scale = ChartScaleGet();
  
  //Set bar widths             
        if(Chart_Scale == 0) {Bar_Width = 1;}
  else {if(Chart_Scale == 1) {Bar_Width = 2;}      
  else {if(Chart_Scale == 2) {Bar_Width = 2;}
  else {if(Chart_Scale == 3) {Bar_Width = 3;}
  else {if(Chart_Scale == 4) {Bar_Width = 6;}
  else {Bar_Width = 13;} }}}}

  //Normal Bars
  SetIndexBuffer(0, Normal);  
  SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, indicator_color1);                        
  //PVA: Rising volume 
  SetIndexBuffer(1, RisingBull);   
  SetIndexStyle(1, DRAW_HISTOGRAM, 0, Bar_Width, indicator_color2);
  SetIndexBuffer(2, RisingBear);                                                                
  SetIndexStyle(2, DRAW_HISTOGRAM, 0, Bar_Width, indicator_color3);

  //PVA: Climax volume     
  SetIndexBuffer(3, ClimaxBull);
  SetIndexStyle(3, DRAW_HISTOGRAM, 0, Bar_Width, indicator_color4); 
  SetIndexBuffer(4, ClimaxBear);        
  SetIndexStyle(4, DRAW_HISTOGRAM, 0, Bar_Width, indicator_color5);
                           
  //Indicator ShortName 
  ShortName= "SonicR PVA  (Chart Scale " + DoubleToStr(Chart_Scale,0) + ")";
  if(Volume_Alert_On) {ShortName= ShortName + "   Alert On";}
  IndicatorShortName (ShortName);           
                           
  //Indicator subwindow data
  IndicatorDigits(0);                  
  SetIndexLabel(0,  NULL);
  SetIndexLabel(1,  NULL); 
  SetIndexLabel(2,  NULL);
  SetIndexLabel(3,  NULL);
  SetIndexLabel(4,  NULL);

  //Alert  
  if(Volume_Alert_On == true) {Alert_Allowed = true;} 

  return(0);
  }
  
//+-------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                |
//+-------------------------------------------------------------------------------------------+
int deinit()
  {
  return(0);
  }
  
//+-------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                       |
//+-------------------------------------------------------------------------------------------+
int start()
  {
  //If Indicator is "Off" deinitialize only once, not every tick 
  if (!Indicator_On)
    {
    if (!Deinitialized) {deinit(); Deinitialized = true;}
    return(0);
    }
   
  //Confirm range of chart bars for calculations   
  //check for possible errors
  counted_bars = IndicatorCounted();
  if(counted_bars < 0)  return(-1);     
  //last counted bar will be recounted
  if(counted_bars > 0) counted_bars--;    
  limit = Bars - counted_bars;
 
  //Begin the loop of calculations for the range of chart bars. 
  for(i = limit - 1; i >= 0; i--)    
    {       
    //Clear buffers
    Normal[i]     = 0;   
    RisingBull[i] = 0;
    RisingBear[i] = 0;   
    ClimaxBull[i] = 0;
    ClimaxBear[i] = 0;    
    Value2        = 0;
    HiValue2      = 0;
    tempv2        = 0; 
    av            = 0;      
            
    //Define Normal histogram bars      
    Normal[i] = (double)Volume[i];   
  
    //Rising Volume           
    for(j = i+1; j <= i+10; j++) {av = av + Volume[j];}   
    av = av / 10;                           
    if(Volume[i] >= av * 1.5)
      {
      if(Close[i] > Open[i]) {RisingBull[i] = NormalizeDouble(Volume[i],0);}
      if(Close[i] <= Open[i]) {RisingBear[i] = NormalizeDouble(Volume[i],0);}
      }
                       
    //Climax Volume                  
    Range = (High[i]-Low[i]);
    Value2 = Volume[i]*Range;                 
    for(n = i+1; n <= i+10; n++)
      {
      tempv2 = Volume[n]*((High[n]-Low[n])); 
      if (tempv2 >= HiValue2) {HiValue2 = tempv2;}    
      }      
    //Define Current and Historic "Climax" bars                  
    if((Value2 >= HiValue2) || (Volume[i] >= av * 2))
      { 
      //Bull Candle                                  
      if(Close[i] > Open[i]) 
        {
        ClimaxBull[i] = NormalizeDouble(Volume[i],0);
        }
      //Bear Candle  
      else if (Close[i] <= Open[i]) 
        {
        ClimaxBear[i] = NormalizeDouble(Volume[i],0);
        }               
      //Sound & Text Alert 
      if((Volume_Alert_On == true) && (Alert_Allowed == true) && (i == 0))
        {
        Alert_Allowed = false;      
        Alert(Broker_Name_In_Alert,":  ",Symbol(),"-",Period(),"   PVA alert!");               
        }//End Alert                               
      }//End Climax Volume                                
    }//End PVA "for i" loop     

  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Subroutine:  Set up to get the chart scale number                                         |
//+-------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)                                                    
  {
  Chart_Scale = ChartScaleGet();
  if(Alert_Allowed == allow)
    {
    init();
    Alert_Allowed = allow;
    }
  else
    {
    init();
    Alert_Allowed = disallow;
    }          
  }

//+-------------------------------------------------------------------------------------------+
//| Subroutine:  Get the chart scale number                                                   |
//+-------------------------------------------------------------------------------------------+
int ChartScaleGet()
  {
  long result = -1;
  ChartGetInteger(0,CHART_SCALE,0,result);
  return((int)result);
  }
    
//+-------------------------------------------------------------------------------------------+
//|Custom indicator end                                                                       |
//+-------------------------------------------------------------------------------------------+    
         