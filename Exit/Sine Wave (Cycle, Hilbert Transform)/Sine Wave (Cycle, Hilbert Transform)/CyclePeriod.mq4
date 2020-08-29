//+------------------------------------------------------------------+
//|                                                  CyclePeriod.mq4 |
//|                                                                  |
//| Cycle Period                                                     |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
#property copyright "Coded by Witold Wozniak"
#property link      "www.mqlsoft.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red

#property indicator_minimum 0

double DeltaPhase[];
double CPeriod[];
double Smooth[];
double Cycle[];
double Q1[];
double I1[];
double InstPeriod[];

extern double Alpha = 0.07;

int buffers = 0;
int drawBegin = 8;
int median = 5;

int init() {
    initBuffer(CPeriod, "Cycle Period", DRAW_LINE);
    initBuffer(Smooth);
    initBuffer(Cycle);
    initBuffer(Q1);
    initBuffer(I1);
    initBuffer(DeltaPhase);
    initBuffer(InstPeriod);
    IndicatorBuffers(buffers);      
    IndicatorShortName("Cycle Period [" + DoubleToStr(Alpha, 2) + "]");
    return (0);
}
  
int start() {
    if (Bars <= drawBegin) return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;
    for (s = limit; s >= 0; s--) {
        Smooth[s] = (P(s) + 2.0 * P(s + 1) + 2.0 * P(s + 2) + P(s + 3)) / 6.0;
        Cycle[s] = (1.0 - 0.5 * Alpha) * (1.0 - 0.5 * Alpha) * (Smooth[s] - 2 * Smooth[s + 1] + Smooth[s + 2]) 
            + 2.0 * (1.0 - Alpha) * Cycle[s + 1]
            - (1.0 - Alpha) * (1.0 - Alpha) * Cycle[s + 2];
        if (s > Bars - 8) {
            Cycle[s] = (P(s) - 2.0 * P(s + 1) + P(s + 2)) / 4.0;           
        }
        Q1[s] = (0.0962 * Cycle[s] + 0.5769 * Cycle[s + 2] - 0.5769 * Cycle[s + 4] - 0.0962 * Cycle[s + 6])
            * (0.5 + 0.08 * InstPeriod[s + 1]);
        I1[s] = Cycle[s + 3];
        if (Q1[s] != 0.0 && Q1[s + 1] != 0.0) {
            DeltaPhase[s] = (I1[s] / Q1[s] - I1[s + 1] / Q1[s + 1]) 
                / (1.0 + I1[s] * I1[s + 1] / (Q1[s] * Q1[s + 1]));
        }
        DeltaPhase[s] = MathMax(0.1, DeltaPhase[s]);
        DeltaPhase[s] = MathMin(1.1, DeltaPhase[s]);
        double MedianDelta, DC;
        double M[];
        ArrayResize(M, median);
        ArrayCopy(M, DeltaPhase, 0, s, median);
        ArraySort(M);
        if (median % 2 == 0) {
            MedianDelta = (M[median / 2] + M[(median / 2) + 1]) / 2.0;
        } else {
            MedianDelta = M[median / 2];
        }
        if (MedianDelta == 0.0) {
            DC = 15.0;
        } else {
            DC = 6.28318 / MedianDelta + 0.5;
        }
        InstPeriod[s] = 0.33 * DC + 0.67 * InstPeriod[s + 1];
        CPeriod[s] = 0.15 * InstPeriod[s] + 0.85 * CPeriod[s + 1];
    }
    return (0);
}

double P(int index) {
    return ((High[index] + Low[index]) / 2.0);
}

void initBuffer(double array[], string label = "", int type = DRAW_NONE, int arrow = 0, int style = EMPTY, int width = EMPTY, color clr = CLR_NONE) {
    SetIndexBuffer(buffers, array);
    SetIndexLabel(buffers, label);    
    SetIndexEmptyValue(buffers, 0);
    SetIndexDrawBegin(buffers, drawBegin);
    SetIndexShift(buffers, 0);
    SetIndexStyle(buffers, type, style, width);
    SetIndexArrow(buffers, arrow);    
    buffers++;
}

