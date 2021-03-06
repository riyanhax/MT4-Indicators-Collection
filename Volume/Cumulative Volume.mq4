//+------------------------------------------------------------------+
//|                                            Volume Cumulative.mq4 |
//+------------------------------------------------------------------+
#property copyright   "Copyright © Indalico 07/05/2020"
#property link        "http://www.mql4.com"
#property description "Volume indicator with a volume simple moving average, bull and bear climax bars and cumulative volume starting on the current day."
#property description "Blue bars  = rising up volume / Red bars   = falling down volume."
#property description "White bars = bull climax volume / Black bars = bear climax volume."
#property indicator_separate_window
#property indicator_minimum 0

#property indicator_buffers 5
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property indicator_color3 clrWhite
#property indicator_color4 clrBlack
#property indicator_color5 clrYellow
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 3

extern int    DisplayBars        = 200;
extern int    VolumeMaPeriod     = 30;
extern color  BullishVolumeColor = clrDarkGreen;
extern color  BearishVolumeColor = clrRed;
extern color  ButtonBorderColor  = C'77,77,77';
extern color  ButtonBackColor    = clrDarkGray;

string FontType = "Calibri Bold";
int    FontSize = 12;
int    LabelChartWindow = 1;
int    Corner = 1;
int    Xpos,Ypos,iBarBegin,Trend,lastTrend;
double Buf1[],Buf2[],Buf3[],Buf4[],VolMa[];
double Range,Range2,Value,HiValue,tempv1,tempv2;
double UpVolume,DnVolume;
datetime opentime;

//+------------------------------------------------------------------+

int init()
{
   IndicatorDigits(0);
   SetIndexBuffer(0,Buf1);  SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"Rising Up Volume");
   SetIndexBuffer(1,Buf2);  SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"Falling Down Volume");
   SetIndexBuffer(2,Buf3);  SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexLabel(2,"Bullish Climax");
   SetIndexBuffer(3,Buf4);  SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexLabel(3,"Bearish Climax");
   SetIndexBuffer(4,VolMa); SetIndexStyle(4,DRAW_LINE);      SetIndexLabel(4,"Volume SMA");
   IndicatorShortName(timeFrameToString(Period())+" Cumulative Volume ("+(string)VolumeMaPeriod+")");
   
   int ButtonWide=80; int ButtonHeight=20; int ButtonXpos=ButtonWide+1; int ButtonYpos=1; 
   ButtonCreate(0,"TrendButo",LabelChartWindow,ButtonXpos,ButtonYpos,ButtonWide,ButtonHeight,1,"",FontType,FontSize,BullishVolumeColor,ButtonBackColor,ButtonBorderColor); ButtonYpos +=ButtonHeight+1;
   ButtonCreate(0,"BullLabel",LabelChartWindow,ButtonXpos,ButtonYpos,ButtonWide,ButtonHeight,1,"",FontType,FontSize,BullishVolumeColor,ButtonBackColor,ButtonBorderColor);  ButtonYpos +=ButtonHeight+1;
   ButtonCreate(0,"BearLabel",LabelChartWindow,ButtonXpos,ButtonYpos,ButtonWide,ButtonHeight,1,"",FontType,FontSize,BearishVolumeColor,ButtonBackColor,ButtonBorderColor);
   Trend=1; ToggleTrading();
   return(0);
}

//+------------------------------------------------------------------+
int deinit() {DeleteAll(); return(0);}
//+------------------------------------------------------------------+

int start()
{
   int i,n,limit,counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=MathMin(Bars-counted_bars,Bars-1);
   if(limit > DisplayBars) limit=DisplayBars;
   
   UpVolume=0; DnVolume=0;
   opentime=iTime(NULL,PERIOD_D1,0);
   iBarBegin=iBarShift(NULL,0,opentime);
	
	for(i=0; i<limit; i++)
   	{
         Value=0; HiValue=0; tempv1=0; tempv2=0;
         Range = (High[i]-Low[i]);
         Range2= (High[i]+Low[i])/2;
         Value = Volume[i]*Range;
         
         for(n=i; n<i+VolumeMaPeriod; n++) {tempv1 = Volume[n] + tempv1;} 
         VolMa[i]=NormalizeDouble(tempv1/VolumeMaPeriod,0);
         
         for(n=i; n<i+20; n++) {tempv2=Volume[n]*((High[n]-Low[n])); if(tempv2 >= HiValue) HiValue=tempv2;}
         if(Volume[i] >= Volume[i+1]) {Buf1[i]=Volume[i]; Buf2[i]=EMPTY_VALUE;} else {Buf2[i]=Volume[i]; Buf1[i]=EMPTY_VALUE;}
         if(Value == HiValue)
            {
               if(Close[i] <= Range2){Buf4[i]=Volume[i]; Buf1[i]=EMPTY_VALUE; Buf2[i]=EMPTY_VALUE;}
               else {Buf3[i]=Volume[i]; Buf1[i]=EMPTY_VALUE; Buf2[i]=EMPTY_VALUE;}
            }
      } 

   for(i=0; i<iBarBegin; i++)
      {
         if (Close[i] > Open[i]) {UpVolume += Volume[i];}
         if (Close[i] < Open[i]) {DnVolume += Volume[i];}
      }
   
   if(UpVolume >= DnVolume) {Trend=1;} else {Trend=-1;} if(lastTrend != Trend) ToggleTrading();
   ObjectSetString(0,"BullLabel",OBJPROP_TEXT,DoubleToStr(UpVolume,0));
   ObjectSetString(0,"BearLabel",OBJPROP_TEXT,DoubleToStr(DnVolume,0));

   return(0);
}

//+------------------------------------------------------------------+

void ToggleTrading()
{
   if(Trend > 0)
     {
      lastTrend=1;
      ObjectSetInteger(0,"TrendButo",OBJPROP_COLOR,C'77,77,77');
      ObjectSetInteger(0,"TrendButo",OBJPROP_BGCOLOR,clrPaleGreen);
      ObjectSetString(0,"TrendButo",OBJPROP_TEXT,"BULLISH");
     }
   else if(Trend <0)
     {
      lastTrend=-1;
      ObjectSetInteger(0,"TrendButo",OBJPROP_COLOR,clrYellow);
      ObjectSetInteger(0,"TrendButo",OBJPROP_BGCOLOR,clrSalmon);
      ObjectSetString(0,"TrendButo",OBJPROP_TEXT,"BEARISH");
     }
}

//+------------------------------------------------------------------+

void ButtonCreate(const long chartID=0,const string name="Trend",const int subwindow=0,const int x=0,const int y=0,const int width=500,
                  const int height=18,int corner=1,const string text="REFRESH",const string font="Calibri Bold",
                  const int fontsize=10,const color clr=C'57,62,78',const color backclr=C'170,170,170',const color borderclr=clrNONE,
                  const bool state=false,const bool back=false,const bool selection=false,const bool hidden=true,const long zorder=0)
{
   ResetLastError();
   ObjectCreate(chartID,name,OBJ_BUTTON,subwindow,0,0);
   ObjectSetInteger(chartID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chartID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chartID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chartID,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_BGCOLOR,backclr);
   ObjectSetInteger(chartID,name,OBJPROP_BORDER_COLOR,borderclr);
   ObjectSetInteger(chartID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chartID,name,OBJPROP_STATE,state);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chartID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chartID,name,OBJPROP_ZORDER,zorder);
   ObjectSetString(chartID,name,OBJPROP_TEXT,text);
   ObjectSetString(chartID,name,OBJPROP_FONT,font);
}

//+------------------------------------------------------------------+

void DeleteAll()
{
   ObjectDelete("TrendButo"); ObjectDelete("BearLabel"); ObjectDelete("BullLabel");
}

//+------------------------------------------------------------------+

string sTfTable[] = {"M1","M2","M3","M4","M5","M10","M15","M20","M30","M40","H1","M200","H4","D1","W1","MN"};
int    iTfTable[] = {1,2,3,4,5,10,15,20,30,40,60,200,240,1440,10080,43200};

string timeFrameToString(int tf)
   {
      for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
            if (tf==iTfTable[i]) return(sTfTable[i]);
                                 return("");
   }

//+------------------------------------------------------------------+