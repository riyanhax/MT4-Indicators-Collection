//+------------------------------------------------------------------+
//|                                                  VOLUME TYPE.mq4 |
//|                                    Copyright © 2008, FOREXflash. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, FOREXflash Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 8

#property indicator_color4 DimGray
#property indicator_color6 Lime
#property indicator_color7 Red
#property indicator_color8 White

#property indicator_width4 1
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 2

extern int MA_Length     = 100;
extern int NumberOfBars  = 2500;

//---- buffers
double ExtMapBuffer1[];
double SPREADHL[];
double AvgSpread[];
double v4[];
double Vol[];
double GREEN[];
double RED[];
double WHITE[];

string  WindowName;
int     PipFactor = 1;

//+------------------------------------------------------------------+
int init()   {
//+------------------------------------------------------------------+
    SetIndexBuffer(0,ExtMapBuffer1);
    SetIndexStyle(0,DRAW_NONE);
    SetIndexBuffer(1,SPREADHL);
    SetIndexStyle(1,DRAW_NONE);
    SetIndexBuffer(2,AvgSpread);
    SetIndexStyle(2,DRAW_NONE);
    SetIndexBuffer(3,v4);
    SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
    SetIndexBuffer(4,Vol);
    SetIndexStyle(4,DRAW_NONE);
    
    SetIndexBuffer(5,GREEN);
    SetIndexStyle(5,DRAW_HISTOGRAM);
    SetIndexBuffer(6,RED);
    SetIndexStyle(6,DRAW_HISTOGRAM);
    SetIndexBuffer(7,WHITE);
    SetIndexStyle(7,DRAW_HISTOGRAM);
    
    string short_name = "VOLUME TYPE";
    IndicatorShortName(short_name);
    WindowName = short_name;
    IndicatorDigits(1);
    
    return(1);
}
//+------------------------------------------------------------------+
int deinit()   {
//+------------------------------------------------------------------+
    return(0);
}

//+------------------------------------------------------------------+
int start()   {
//+------------------------------------------------------------------+
    AVGSpread();
    AVGVolume();
    return(0);
}

//+------------------------------------------------------------------+
int AVGSpread()   {
//+------------------------------------------------------------------+
    int i, nLimit, nCountedBars;
    nCountedBars = IndicatorCounted();
    if(nCountedBars>0) nCountedBars--;
    nLimit=Bars-nCountedBars;
    for(i=0; i<nLimit; i++)
    SPREADHL[i] = ((iHigh(NULL, 0, i) - iLow(NULL, 0, i))/Point)/PipFactor;   // SPREAD
    
    for (i=0; i<nLimit; i++)   {
        AvgSpread[i] = iMAOnArray(SPREADHL,0,MA_Length,0,MODE_EMA,i);         // AVERAGE SPREAD
    }
    return(0);
}

//+------------------------------------------------------------------+
int AVGVolume()   {
//+------------------------------------------------------------------+
    double tempv;
    int limit;
    int counted_bars=IndicatorCounted();
    if (counted_bars>0) counted_bars--;
    if (NumberOfBars == 0)
        NumberOfBars = Bars-counted_bars;
    limit=NumberOfBars; //Bars-counted_bars;
    
    for (int i=0; i<limit; i++)    {
        tempv=0;
        for (int n=i; n<i+MA_Length; n++)   {
            tempv = Volume[n] + tempv;
        }
        v4[i]  = NormalizeDouble(tempv/MA_Length,0);                         // AVERAGE VOLUME
        Vol[i] = iVolume(NULL, 0, i);                                        // CURRENT VOLUME
        
        double MIDDLEOFBAR   = (High[i]+Low[i])/2;                           // EXACT MIDDLE
        double UPOFBAR       = (High[i]+Low[i])/2 + (High[i]-Low[i])/6;      // UP CLOSE
        double DOWNOFBAR     = (High[i]+Low[i])/2 - (High[i]-Low[i])/6;      // DOWN CLOSE

        RED[i]   = EMPTY_VALUE;
        GREEN[i] = EMPTY_VALUE;
        WHITE[i] = EMPTY_VALUE;
        
        if (Close[i] < DOWNOFBAR && Open[i] > Close[i] && Close[i] < Low[i+1])
            RED[i]= NormalizeDouble(Volume[i],0);
        else
        if (Close[i] > UPOFBAR && Open[i] < Close[i] && Close[i] > High[i+1])
            GREEN[i]= NormalizeDouble(Volume[i],0);
        else
            WHITE[i]= NormalizeDouble(Volume[i],0);
    }
    return(0);
}
//+------------------------------------------------------------------+