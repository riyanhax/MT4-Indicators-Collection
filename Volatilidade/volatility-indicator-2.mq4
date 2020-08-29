//+------------------------------------------------------------------+
//|                                   Copyright © 2010, Ivan Kornilov|
//|                                                    Volatility.mq4|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Ivan Kornilov"
#property link "excelf@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Gray
#property indicator_color2 RoyalBlue
extern int MaPriod = 34;
extern double value = 0.5;

double buffer1[];
double buffer2[];
double buffer3[];

double minVolume;
int init() {
    minVolume = Volume[iLowest(NULL, 0,MODE_VOLUME, WHOLE_ARRAY, 0)];
    IndicatorBuffers(3);
    SetIndexStyle(0,DRAW_HISTOGRAM, EMPTY, 3);
    SetIndexStyle(1,DRAW_HISTOGRAM, EMPTY, 3);
    
    SetIndexBuffer(0, buffer1);
    SetIndexBuffer(1, buffer2);
    SetIndexBuffer(2, buffer3);
    
      
    IndicatorShortName("Volatility("+MaPriod+ ")");
    SetIndexDrawBegin(0,MaPriod);
    
    
    SetIndexLabel(0, "ma");
    SetIndexLabel(1, "value");
    SetIndexLabel(2, "action");

    IndicatorDigits(Digits + 3);    
}


int start() {
    int i;
    int counted_bars=IndicatorCounted();
     if(counted_bars > 0) {
        counted_bars--;
    }
    int limit = Bars-counted_bars-1;
   
    for(i = limit - 1 ; i >= 0; i--) {
        buffer3[i] = (
            MathAbs(High[i+1] - Low[i]) + 
            MathAbs(High[i] - Low[i+1]) + 
            MathAbs(Close[i+1] - Close[i])
        )  
        * (Volume[i] - minVolume)
        ;
    }
    if(Bars - limit <  MaPriod*15) {
        limit = limit - MaPriod*15;
    }
    
    for(i = limit -1; i >= 0; i--) {
        buffer1[i] = iMAOnArray(buffer3, 0, MaPriod, 0, MODE_EMA, i);
    }
    
    double sum = 0;
    int count = 0;
    for(i = Bars; i >= 0; i--) {
        if(buffer1[i] != EMPTY_VALUE) { 
            sum += buffer1[i];
            count++;
        }
    }
    sum = sum / count;

    for(i = limit - 1 ; i >= 0; i--) {
        if(sum * value < buffer1[i]) {
            buffer2[i] = buffer1[i];
        } else {
            buffer2[i] = EMPTY_VALUE;
        }
    }
    
    return(0);
}