//+------------------------------------------------------------------+
//|                                            Heijden MAC3D.mq4     |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Marco van der Heijden MAC3D"
#property strict

//Indicator settings//
#property indicator_chart_window
#property indicator_buffers 17

//Input parameters and Colors//
input bool Alerts =true;//Global and Local Alerts
input bool Alerts2=true;//New Global High's and Low's Alerts

input int MAC3D1Period =1;//MAC3D Period 1
input int MAC3D2Period =12;//MAC3D Period 2
input int MAC3D3Period =26;//MAC3D Period 3
input int MAC3D4Period =200;//MAC3D Period 4
input int MAC3DIndexLine =200;//MAC3D Index Line
input int MAC3DShift =1;//Shift

input ENUM_CHART_MODE DisplayMode1Chart =CHART_LINE;//Displaymode CHART 
input int DisplayMode2Price = DRAW_HISTOGRAM;//Displaymode PRICE
input int DisplayMode3Trend = DRAW_HISTOGRAM;//Displaymode TREND 1
input int DisplayMode4Trend = 2;//Displaymode TREND 2
 
input int LineWidth =1;//Displaymode LINE WIDTH

input color MAC3D1PeriodColor =clrGreen;//MAC3D Period 1 Color
input color MAC3D2PeriodColor =clrRed;//MAC3D Period 2 Color
input color MAC3D3PeriodColor =clrBlue;//MAC3D Period 3 Color
input color MAC3D4PeriodColor =clrLightPink;//MAC3D Period 4 Color
input color MAC3DIndexColor =clrGray;// MAC3D Index Line Color

input color BackgroundColor =clrSnow;//CHART Background Color
input color ForegroundColor =clrBlack;//CHART Foreground Color
input color GridColor =clrGray;//GRID Color
input bool Grid=false;//Grid On Off

int Condition1 =0; int Condition2=0; int Condition3=0; int Condition4=0; int Condition5=0; int Condition6=0;

//Indicator buffers//

//Index buffer// 
double ExtIndexBuffer[];

//Price line buffer//
double ExtGreenBuffer[];

//Red line buffers//
double ExtRed1Buffer[];
double ExtRed2Buffer[];
double ExtRed3Buffer[];
double ExtRed4Buffer[];
double ExtRed5Buffer[];
double ExtRed6Buffer[];
double ExtRed7Buffer[];

//Blue line buffers//
double ExtBlue1Buffer[];
double ExtBlue2Buffer[];
double ExtBlue3Buffer[];
double ExtBlue4Buffer[];
double ExtBlue5Buffer[];
double ExtBlue6Buffer[];
double ExtBlue7Buffer[];

//200MA Buffer//
double Ext200MABuffer[];

int HighestIndex=0;
int LowestIndex=0;
double Highest=0;
double Lowest=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
 //--- DisplayMode
   if(!ChartSetInteger(0,CHART_MODE,DisplayMode1Chart))
   return;                                                   
//--- Set the chart background color
   if(!ChartSetInteger(0,CHART_COLOR_BACKGROUND,BackgroundColor))
   return;                                                   
 //--- Set the color of axes, scale and OHLC line
   if(!ChartSetInteger(0,CHART_COLOR_FOREGROUND,ForegroundColor))
   return; 
//--- Set the grid
   if(!ChartSetInteger(0,CHART_SHOW_GRID,0,Grid))
   return;
//--- Set chart if grid color 
   if(!ChartSetInteger(0,CHART_COLOR_GRID,GridColor))        
   return;//                                                  
//--- Set the color of Bid price line 
   if(!ChartSetInteger(0,CHART_COLOR_BID,clrRed))              
   return;//                                                   
//--- Set property bid line value 
   if(!ChartSetInteger(0,CHART_SHOW_BID_LINE,0,1))               
   return;//                                         
//--- Set the color of bullish candlestick's body 
   if(!ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrDarkSeaGreen))  
   return;//                                                   
//--- Set the color of up bar, its shadow and border of body of a bullish candlestick    
   if(!ChartSetInteger(0,CHART_COLOR_CHART_UP,clrBlack))        
   return;//                                                   
//--- Set the color of bearish candlestick's body 
   if(!ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrFireBrick))    
   return;//                                                    
//--- Set the color of down bar, its shadow and border of bearish candlestick's body 
   if(!ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrBlack))         
   return;//                                                    
//--- Set color of the chart line and Doji candlesticks 
   if(!ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrBlack))          
   return;//
   
Alert("  Initializing.....");
Alert("  There are ",Bars," Bars on this Chart");
HighestIndex=ArrayMaximum(High,WHOLE_ARRAY,0);
LowestIndex=ArrayMinimum(Low,WHOLE_ARRAY,0);
Highest=High[HighestIndex];
Lowest=Low[LowestIndex];
Alert("  The Highest price on this chart is ",Highest," Reached on ",Time[HighestIndex]);
Alert("  The Lowest  price on this chart is ",Lowest," Reached on ",Time[LowestIndex]);

//-------------------------------------------------------------------------------------------+|
// END OF INITIALIZATION SEQUENCE                                                            ||   
//-------------------------------------------------------------------------------------------+|

   IndicatorDigits(Digits);
 
//Indicator Buffers Mapping//
   SetIndexBuffer(0,ExtGreenBuffer);//PRICE LINE
//Red buffers//     
   SetIndexBuffer(1,ExtRed1Buffer);//RED1
   SetIndexBuffer(2,ExtRed2Buffer);//RED2
   SetIndexBuffer(3,ExtRed3Buffer);//RED3
   SetIndexBuffer(4,ExtRed4Buffer);//RED4
   SetIndexBuffer(5,ExtRed5Buffer);//RED5
   SetIndexBuffer(6,ExtRed6Buffer);//RED6
   SetIndexBuffer(7,ExtRed7Buffer);//RED7
//Blue buffers//   
   SetIndexBuffer(8,ExtBlue1Buffer);//BLUE1
   SetIndexBuffer(9,ExtBlue2Buffer);//BLUE2
   SetIndexBuffer(10,ExtBlue3Buffer);//BLUE3
   SetIndexBuffer(11,ExtBlue4Buffer);//BLUE4
   SetIndexBuffer(12,ExtBlue5Buffer);//BLUE5
   SetIndexBuffer(13,ExtBlue6Buffer);//BLUE6
   SetIndexBuffer(14,ExtBlue7Buffer);//BLUE7
//200MA buffer//
   SetIndexBuffer(15,Ext200MABuffer);//200MA
   SetIndexBuffer(16,ExtIndexBuffer);//Index
   
//Drawing Settings//

//Price line//
   SetIndexStyle(0,DisplayMode2Price,0,LineWidth,MAC3D1PeriodColor);
   
//Red lines//   
   SetIndexStyle(1,DRAW_LINE,0,LineWidth,MAC3D2PeriodColor);
   SetIndexStyle(2,DRAW_LINE,0,LineWidth,MAC3D2PeriodColor);
   SetIndexStyle(3,DRAW_LINE,0,LineWidth,MAC3D2PeriodColor);
   SetIndexStyle(4,DRAW_LINE,0,LineWidth,MAC3D2PeriodColor);
   SetIndexStyle(5,DRAW_LINE,0,LineWidth,MAC3D2PeriodColor);
   SetIndexStyle(6,DRAW_LINE,0,LineWidth,MAC3D2PeriodColor);
   SetIndexStyle(7,DRAW_LINE,0,LineWidth,MAC3D2PeriodColor);
  
//Blue lines//
   SetIndexStyle(8,DRAW_LINE,0,LineWidth,MAC3D3PeriodColor);
   SetIndexStyle(9,DRAW_LINE,0,LineWidth,MAC3D3PeriodColor);
   SetIndexStyle(10,DRAW_LINE,0,LineWidth,MAC3D3PeriodColor);
   SetIndexStyle(11,DRAW_LINE,0,LineWidth,MAC3D3PeriodColor);
   SetIndexStyle(12,DRAW_LINE,0,LineWidth,MAC3D3PeriodColor);
   SetIndexStyle(13,DRAW_LINE,0,LineWidth,MAC3D3PeriodColor);
   SetIndexStyle(14,DRAW_LINE,0,LineWidth,MAC3D3PeriodColor);
   
//200MA line//   
   SetIndexStyle(15,DisplayMode3Trend,DisplayMode4Trend,LineWidth,MAC3D4PeriodColor);
   SetIndexStyle(16,DRAW_LINE,0,LineWidth,MAC3DIndexColor);

   SetIndexLabel(0,"Price Line");  
   SetIndexLabel(1,"D2-Period");
   SetIndexLabel(2,"D2-Period");
   SetIndexLabel(3,"D2-Period");
   SetIndexLabel(4,"D2-Period");
   SetIndexLabel(5,"D2-Period");
   SetIndexLabel(6,"D2-Period");
   SetIndexLabel(7,"D2-Period");
   
   SetIndexLabel(8,"D3-Period");
   SetIndexLabel(9,"D3-Period");
   SetIndexLabel(10,"D3-Period");
   SetIndexLabel(11,"D3-Period");
   SetIndexLabel(12,"D3-Period");
   SetIndexLabel(13,"D3-Period");
   SetIndexLabel(14,"D3-Period");
   
   SetIndexLabel(15,"D4-Period The Global Trend");
   
   SetIndexLabel(8,"Index Line");
   
   
  }
//+------------------------------------------------------------------+
//| Marco van der Heijden MAC3D                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int limit=rates_total-prev_calculated;
//LOOP//
   for(int i=0; i<limit; i++)
     {
       
//Green//      
      ExtGreenBuffer[i]=iMA(NULL,0,MAC3D1Period,0,MODE_EMA,PRICE_CLOSE,i);
//DONE//

//Red//      
      ExtRed1Buffer[i]=iMA(NULL,0,MAC3D2Period,0,MODE_EMA,PRICE_CLOSE,i);
      ExtRed2Buffer[i]=iMA(NULL,0,MAC3D2Period+1/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtRed3Buffer[i]=iMA(NULL,0,MAC3D2Period+2/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtRed4Buffer[i]=iMA(NULL,0,MAC3D2Period+3/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtRed5Buffer[i]=iMA(NULL,0,MAC3D2Period+4/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtRed6Buffer[i]=iMA(NULL,0,MAC3D2Period+5/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtRed7Buffer[i]=iMA(NULL,0,MAC3D2Period+6/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
//DONE//  
   
//Blue//
      ExtBlue1Buffer[i]=iMA(NULL,0,MAC3D3Period,0,MODE_EMA,PRICE_CLOSE,i);
      ExtBlue2Buffer[i]=iMA(NULL,0,MAC3D3Period-1/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtBlue3Buffer[i]=iMA(NULL,0,MAC3D3Period-2/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtBlue4Buffer[i]=iMA(NULL,0,MAC3D3Period-3/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtBlue5Buffer[i]=iMA(NULL,0,MAC3D3Period-4/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtBlue6Buffer[i]=iMA(NULL,0,MAC3D3Period-5/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      ExtBlue7Buffer[i]=iMA(NULL,0,MAC3D3Period-6/MAC3DShift,0,MODE_EMA,PRICE_CLOSE,i);
      
      Ext200MABuffer[i]=iMA(NULL,0,MAC3D4Period,0,MODE_SMA,PRICE_CLOSE,i);
      ExtIndexBuffer[i]=iMA(NULL,0,MAC3DIndexLine,0,MODE_SMA,PRICE_CLOSE,i);
//DONE//   
   
     }
     
if (Alerts==true)
{
Alerting();
}

   return(rates_total);
  }
       
/////////////////////////////////////////////////////////////////////////////////////////////////////////  
void Alerting()
{  
if (Condition1==0&iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,MAC3D4Period,0,MODE_SMA,PRICE_CLOSE,0))
{
Alert ("  Price has moved ABOVE MAC3D4 LEVEL !! possible global long term Uptrend ");
Condition1++;
      Condition2=0;
}  
if (Condition2==0&iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,MAC3D4Period,0,MODE_SMA,PRICE_CLOSE,0))
{
Alert ("  Price has moved BELOW MAC3D4 LEVEL !! possible global or long term Downtrend ");
Condition2++;
}
if (Condition3==0&iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,MAC3D2Period,0,MODE_EMA,PRICE_CLOSE,0))
   {
    if (iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,MAC3D3Period,0,MODE_EMA,PRICE_CLOSE,0))
     {
     Alert ("  Price has moved ABOVE MAC3D2&3 LEVELS !! possible Local or temporary Uptrend ");
Condition3++;
     Condition4=0;
     Condition5=0;
     Condition6=0;
     }     
   }
if (Condition4==0&iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,MAC3D2Period,0,MODE_EMA,PRICE_CLOSE,0))
   {
   if (iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,MAC3D3Period,0,MODE_EMA,PRICE_CLOSE,0))
    {
    Alert ("  Price has moved BELOW MAC3D2&3 LEVELS !! possible Local or temporary Downtrend ");
Condition4++;
    Condition3=0;
    Condition5=0;
    Condition6=0;
    }
   }
  
if (Condition5==0&iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,MAC3D4Period,0,MODE_SMA,PRICE_CLOSE,0))
   {
   if(iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,MAC3D2Period,0,MODE_EMA,PRICE_CLOSE,0))  
     { 
     if(iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,MAC3D3Period,0,MODE_EMA,PRICE_CLOSE,0))
      {
      Alert ("  Price has moved ABOVE MAC3D2&3 LEVELS AND ABOVE MAC3D4 LEVEL !! possible Global Uptrend and Local Uptrend ");
Condition5++;
      Condition3=0;
      Condition4=0;
      Condition6=0;
      }
     }
    }
    
if (Condition6==0&iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,MAC3D4Period,0,MODE_SMA,PRICE_CLOSE,0))
   {
   if(iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,MAC3D2Period,0,MODE_EMA,PRICE_CLOSE,0))  
     { 
     if(iMA(NULL,0,MAC3D1Period,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,MAC3D3Period,0,MODE_EMA,PRICE_CLOSE,0))
      {
      Alert ("  Price has moved BELOW MAC3D2&3 LEVELS AND BELOW MAC3D4 LEVEL !! possible Global Downtrend and Local Downtrend ");
Condition6++;
      Condition3=0;
      Condition4=0;
      Condition5=0;
      }
     }
    }
  
//New high and New low Alerts//

if (Alerts2==true&High[1]>Highest)
{
Alert("  WARNING !! NEW GLOBAL HIGH DETECTED !! ",Highest);
Highest=High[1];
}  

if(Alerts2==true&Low[1]<Lowest)
{
Alert(" WARNING !! NEW GLOBAL LOW DETECTED !! ",Lowest);
Lowest=Low[1];
}
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////   

/*
Credits to:

Mark Douglas
Ed Ponsi
Robert Prechter
Jim Dandy
Bilal Haider
Bill Williams
All members of the the MQL4 and 5 Team 
*/      