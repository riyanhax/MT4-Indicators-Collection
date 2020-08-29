//+------------------------------------------------------------------+
//|                                     SmoothedAdaptiveMomentum.mq4 |
//|                                                                  |
//| Smoothed Adaptive Momentum                                       |
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
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

#property indicator_level1 0

double Momentum[];

extern double Alpha = 0.07;
extern int Cutoff = 8;
int buffers = 0;
int drawBegin = 0;

double tempReal, rad2Deg, deg2Rad, coef1, coef2, coef3, coef4;

int init() {
    drawBegin = 60;
    initBuffer(Momentum, "Momentum", DRAW_LINE);
    IndicatorBuffers(buffers);
    IndicatorShortName("Smoothed Adaptive Momentum [" + DoubleToStr(Alpha, 2) + ", " + Cutoff + "]");  
    tempReal = MathArctan(1.0);
    rad2Deg = 45.0 / tempReal;
    deg2Rad = 1.0 / rad2Deg;
    double pi = MathArctan(1.0) * 4.0;
    double a1 = MathExp(-pi / Cutoff);
    double b1 = 2 * a1 * MathCos(MathSqrt(3.0) * pi/ Cutoff);
    double c1 = a1 * a1;
    coef2 = b1 + c1;
    coef3 = -(c1 + b1 * c1);
    coef4 = c1 * c1;
    coef1 = 1.0 - coef2 - coef3 - coef4;   
    return (0);
}
  
int start() {
    if (Bars <= drawBegin) return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;
    for (s = limit; s >= 0; s--) {
        double period = iCustom(0, 0, "CyclePeriod", Alpha, 0, s);
        int intPeriod = MathFloor(period);
        double Value1 = P(s) - P(s + intPeriod - 1);
        Momentum[s] = coef1 * Value1 + coef2 * Momentum[s + 1] +
            coef3 * Momentum[s + 2] + coef4 * Momentum[s + 3];
        if (s > Bars - 8) {
            Momentum[s] = Value1;           
        }
    }
    return (0);
}

double P(int index) {
    return ((High[index] + Low[index]) / 2.0);
}

void initBuffer(double array[], string label = "", int type = DRAW_NONE, int arrow = 0, int style = EMPTY, int width = EMPTY, color clr = CLR_NONE) {
    SetIndexBuffer(buffers, array);
    SetIndexLabel(buffers, label);
    SetIndexEmptyValue(buffers, EMPTY_VALUE);
    SetIndexDrawBegin(buffers, drawBegin);
    SetIndexShift(buffers, 0);
    SetIndexStyle(buffers, type, style, width);
    SetIndexArrow(buffers, arrow);
    buffers++;
}