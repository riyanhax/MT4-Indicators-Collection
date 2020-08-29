//+------------------------------------------------------------------+
//|                                               LaguerreFilter.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property indicator_chart_window

#property indicator_color1 Yellow

//---- input parameters
extern double    gamma      = 0.7;
extern int       Price_Type = 0; 
//---- buffers
double Filter[];
double L0[];
double L1[];
double L2[];
double L3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(5);
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexDrawBegin(0, 1);
	SetIndexLabel(0, "LaguerreFilter");
	SetIndexBuffer(0, Filter);
   SetIndexBuffer(1, L0);
   SetIndexBuffer(2, L1);
   SetIndexBuffer(3, L2);
   SetIndexBuffer(4, L3);
//----
   string short_name="LaguerreFilter(" + DoubleToStr(gamma, 2) + ")";
   IndicatorShortName(short_name);
   return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
	int    limit;
	int    counted_bars = IndicatorCounted();
	double CU, CD;
	//---- last counted bar will be recounted
	if (counted_bars>0)
		counted_bars--;
	else
		counted_bars = 1;
	limit = Bars - counted_bars;
	//---- computations for RSI
	for (int i=limit; i>=0; i--)
	{
		double Price=iMA(NULL,0,1,0,0,Price_Type,i);
		
		L0[i] = (1.0 - gamma)*Price + gamma*L0[i+1];
		L1[i] = -gamma*L0[i] + L0[i+1] + gamma*L1[i+1];
		L2[i] = -gamma*L1[i] + L1[i+1] + gamma*L2[i+1];
		L3[i] = -gamma*L2[i] + L2[i+1] + gamma*L3[i+1];
		
		CU = 0;
		CD = 0;
		if (L0[i] >= L1[i])
			CU = L0[i] - L1[i];
		else
			CD = L1[i] - L0[i];
		if (L1[i] >= L2[i])
			CU = CU + L1[i] - L2[i];
		else
			CD = CD + L2[i] - L1[i];
		if (L2[i] >= L3[i])
			CU = CU + L2[i] - L3[i];
		else
			CD = CD + L3[i] - L2[i];

		if (CU + CD != 0)
			Filter[i] = (L0[i] + 2 * L1[i] + 2 * L2[i] + L3[i]) / 6.0;
	}
   return(0);
}
//+------------------------------------------------------------------+