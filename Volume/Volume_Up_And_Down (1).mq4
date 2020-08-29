//+------------------------------------------------------------------+
//|                                           Volume Up And Down.mq4 |
//|                                    Copyright 2019, Mattheus Lee  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Mattheus Lee"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot VolumeUp
#property indicator_label1  "VolumeUp"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
//#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot VolumeDown
#property indicator_label2  "VolumeDown"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
//#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int Period=14;

//--- indicator buffers
double VolumeUpBuffer[];
double VolumeDownBuffer[];

int OnInit(void) {
    if (Period < 2) {
        return INIT_PARAMETERS_INCORRECT;
    }
    SetIndexBuffer(0,VolumeUpBuffer);
    SetIndexBuffer(1,VolumeDownBuffer);
    return INIT_SUCCEEDED;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

    int limit;
    if (prev_calculated == 0) {
        limit = rates_total - Period;
    }
    else {
        limit = rates_total - prev_calculated;
    }

    for (int i = 0; i < limit; ++i) {

        // VolumeUp is the Period - the number of candles since the highest volume in an up candle in the Period
        int numberCandlesSinceHighestVolumeForUpCandle = Period - 1;
        int highestVolumeForUpCandle = 0;
        for (int j = i; j < i + Period; ++j) {
            if (close[j] > open[j]) {
                if (tick_volume[j] > highestVolumeForUpCandle) {
                    highestVolumeForUpCandle = (int)tick_volume[j];
                    numberCandlesSinceHighestVolumeForUpCandle = j - i;
                }
            }
        }
        VolumeUpBuffer[i] = Period - numberCandlesSinceHighestVolumeForUpCandle - 1;
        VolumeUpBuffer[i] = 1.0 * VolumeUpBuffer[i] / (Period - 1) * 100;

        // VolumeDown is the Period - the number of candles since the highest volume in a down candle in the Period
        int numberCandlesSinceHighestVolumeForDownCandle = Period - 1;
        int highestVolumeForDownCandle = 0;
        for (int j = i; j < i + Period; ++j) {
            if (close[j] < open[j]) {
                if (tick_volume[j] > highestVolumeForDownCandle) {
                    highestVolumeForDownCandle = (int)tick_volume[j];
                    numberCandlesSinceHighestVolumeForDownCandle = j - i;
                }
            }
        }
        VolumeDownBuffer[i] = Period - numberCandlesSinceHighestVolumeForDownCandle - 1;
        VolumeDownBuffer[i] = 1.0 * VolumeDownBuffer[i] / (Period - 1) * 100;
    }

    return rates_total;
}
