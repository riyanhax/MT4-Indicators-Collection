//=============================================================================
//                                                              SynergyInd.mq4
//                                               Copyright © 2007, Derk Wehler
//
//=============================================================================
#property copyright "Copyright © 2007, Derk Wehler"
#property link      "http://www.ArrogantFxBastards.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Red

// buffers
double BuyEntryBuf[];
double SellEntryBuf[];
double BuyExitBuf[];
double SellExitBuf[];
double AddBuyBuf[];
double AddSellBuf[];

// HaikenAshi DM settings
//extern int RSI_Period 		= 13;	// 8-25
//extern int RSI_Price 			= 0;	// 0-6
//extern int Volatility_Band 	= 34;	// 20-40
//extern int RSI_Price_Line 	= 2;      
//extern int RSI_Price_Type 	= 0;	// 0-3
//extern int Trade_Signal_Line 	= 7;   
//extern int Trade_Signal_Type 	= 0;	// 0-3
extern bool			UseEntry68_32		= false;
extern bool			UseSmallerExit		= false;
extern double		DefineSmaller		= 0.08;
extern bool			ReqRedYellowCombo	= false;
extern bool			UseVolExpanding		= false;
extern bool			UseChaikin			= false;
extern bool			UseH4Trend			= false;
extern bool			IsEA_Calling		= false;
extern bool			UseAlert			= false;
extern color		LegendColor			= Yellow;
extern int			LegendCorner		= 3;
extern string		Comment9			= "Corner: 0=UL , 1=UR , 2=LL , 3=LR";


// Globals --------------------------------------

// Indicator values
double	HA_HiLo_2, HA_LoHi_2, HA_Open_1, HA_Close_1;
double	HA_DM0_2, HA_DM1_2, HA_Open_2, HA_Close_2;
double	TDI0_1, BlueH_1, Yellow_1, BlueL_1, Green_1;
double	Red_0, Red_1, Red_2, BlueH_0, BlueL_0;
double	MA_Hi_0, MA_Lo_0;
double	MA_Hi_1, MA_Lo_1;
double	MA_Hi_2, MA_Lo_2;
double	Chaikin;

// Other
int			TDI_Dir;
int			MA_Trend_Dir;
int			H4_Trend;
int			HA_Outside_MA_Dir;
bool		HA_Closed_Inside_MA;
int			CandleSmallerOrOpp;
string		ExitReason;
datetime 	PrevTime;


//=============================================================================
// Custom indicator initialization & deinitialization functions
//=============================================================================
int init()
{
	// Entry arrow
	SetIndexStyle(0,DRAW_ARROW);
	SetIndexArrow(0,233);
	SetIndexBuffer(0,BuyEntryBuf);
	SetIndexEmptyValue(0,0.0);
	SetIndexStyle(1,DRAW_ARROW);
	SetIndexArrow(1,234);
	SetIndexBuffer(1,SellEntryBuf);
	SetIndexEmptyValue(1,0.0);
	
	// Exit arrow
	SetIndexStyle(2,DRAW_ARROW);
	SetIndexArrow(2,251);
	SetIndexBuffer(2,BuyExitBuf);
	SetIndexEmptyValue(2,0.0);
	SetIndexStyle(3,DRAW_ARROW);
	SetIndexArrow(3,251);
	SetIndexBuffer(3,SellExitBuf);
	SetIndexEmptyValue(3,0.0);
	
	// Possible add-to-trade arrow
	SetIndexStyle(4,DRAW_ARROW);
	SetIndexArrow(4,241);
	SetIndexBuffer(4,AddBuyBuf);
	SetIndexEmptyValue(4,0.0);
	SetIndexStyle(5,DRAW_ARROW);
	SetIndexArrow(5,242);
	SetIndexBuffer(5,AddSellBuf);
	SetIndexEmptyValue(5,0.0);

	int y1 = 50, y2 = 40, y3 = 30, y4 = 20, y5 = 10;
	if (!IsEA_Calling)
	{
		if (LegendCorner == 0 || LegendCorner == 1)
		{
			y1 = 10; y2 = 20; y3 = 30; y4 = 40; y5 = 50;
		}
	
		string text;
		text = "Exit Codes:";
		ObjectCreate("Legend1", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Legend1", text, 8, "Arial Bold", LegendColor);
		ObjectSet("Legend1", OBJPROP_CORNER, LegendCorner);
		ObjectSet("Legend1", OBJPROP_XDISTANCE, 10);
		ObjectSet("Legend1", OBJPROP_YDISTANCE, y1);
	
		text = "OC:  HA Closed Opposite Color";
		ObjectCreate("Legend2", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Legend2", text, 8, "Arial Bold", LegendColor);
		ObjectSet("Legend2", OBJPROP_CORNER, LegendCorner);
		ObjectSet("Legend2", OBJPROP_XDISTANCE, 10);
		ObjectSet("Legend2", OBJPROP_YDISTANCE, y2);
	
		text = "CI:   HA Closed Inside Channel";
		ObjectCreate("Legend3", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Legend3", text, 8, "Arial Bold", LegendColor);
		ObjectSet("Legend3", OBJPROP_CORNER, LegendCorner);
		ObjectSet("Legend3", OBJPROP_XDISTANCE, 10);
		ObjectSet("Legend3", OBJPROP_YDISTANCE, y3);
	
		text = "SC:  HA Much Smaller Than Previous";
		ObjectCreate("Legend4", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Legend4", text, 8, "Arial Bold", LegendColor);
		ObjectSet("Legend4", OBJPROP_CORNER, LegendCorner);
		ObjectSet("Legend4", OBJPROP_XDISTANCE, 10);
		ObjectSet("Legend4", OBJPROP_YDISTANCE, y4);
	
		text = "TDI:  TDI Signaled Exit";
		ObjectCreate("Legend5", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("Legend5", text, 8, "Arial Bold", LegendColor);
		ObjectSet("Legend5", OBJPROP_CORNER, LegendCorner);
		ObjectSet("Legend5", OBJPROP_XDISTANCE, 10);
		ObjectSet("Legend5", OBJPROP_YDISTANCE, y5);
	}	
	return(0);
}


int deinit()
{
	if (!IsEA_Calling)
	{
		string name;
		for (int i = Bars; i >= 0; i--)
		{
			name = "SynIndBuy" + DoubleToStr(i ,0);
			ObjectDelete(name);
			name = "SynIndSell" + DoubleToStr(i ,0);
			ObjectDelete(name);
		}
		ObjectDelete("TotalPips");
		ObjectDelete("Legend1");
		ObjectDelete("Legend2");
		ObjectDelete("Legend3");
		ObjectDelete("Legend4");
		ObjectDelete("Legend5");
	}
	return(0);
}


//=============================================================================
//| Custom indicator iteration function                              |
//=============================================================================
int start()
{
	static int		RunningTotal = 0;
	static bool 	InBuy = false;
	static bool 	InSell = false;
	static double	OpenPriceB = 0;
	static double	OpenPriceS = 0;

	int 	i, limit;
	double	a, b, c, d, e, f, g;
	int		pipsMade;
	color	clr;
	string	name, text;
	double	upperPos, lowerPos, upperTextPos, lowerTextPos;
	double	spread;
	
	// Run only once per candle
	if (PrevTime == Time[0])
		return;
	PrevTime = Time[0];

	// Get already counted bars    
	int counted_bars = IndicatorCounted();

	// Check for possible errors
	if (counted_bars < 0) 
		return (-1);
		
	limit = Bars - counted_bars - 1;
	
	// Don't do ALL the way back to start, 
	// because we reference earlier candles
	if (limit > 100)
		limit -= 5;
	
	int sp = 3;
	switch (Period())
	{
		case PERIOD_M5:		sp = 5; 	break;
		case PERIOD_M15:	sp = 8; 	break;
		case PERIOD_M30:	sp = 10; 	break;
		case PERIOD_H1:		sp = 15; 	break;
		case PERIOD_H4:		sp = 35; 	break;
		case PERIOD_D1:		sp = 90; 	break;
		case PERIOD_W1:		sp = 120; 	break;
		case PERIOD_MN1:	sp = 170; 	break;
	}
	
	// Main loop
	for (i = limit; i >= 0; i--) 
	{
		AcquireIndicatorValues(i);
		
		// Check for open signals ---------------------------------------------
		MA_Trend_Dir = GetMA_Trend();
		HA_Outside_MA_Dir = GetHA_CloseDir(i);
		TDI_Dir = GetTDI_EntryDir();
		H4_Trend = GetH4Trend(i);
		
		// Calculate where to put arrows (and labels)
		upperPos = MathMax(High[i], MathMax(HA_HiLo_2, HA_LoHi_2)) + (sp*Point);
		upperTextPos = upperPos + ((sp)*Point);
		lowerPos = MathMin(Low[i], MathMin(HA_HiLo_2, HA_LoHi_2)) - (sp*Point);
		lowerTextPos = lowerPos - ((sp/4)*Point);
		spread = Ask - Bid;
		
		// If all in Long position, signal to BUY at this candle's open
		if (!InBuy && MA_Trend_Dir == OP_BUY && HA_Outside_MA_Dir == OP_BUY && 
			TDI_Dir == OP_BUY && (!UseVolExpanding || VolBandsExpanding()) && 
			(!UseChaikin || Chaikin > 0) && (!UseH4Trend || H4_Trend == OP_BUY))
		{
			BuyEntryBuf[i] = lowerPos;
			InBuy = true;
			OpenPriceB = Open[i] + spread;
			DoAlert(i, "Synergy: New Buy Signal, candle = " + i);
		}
		
		else if (InBuy && AddToBuyPosition())
		{
			AddBuyBuf[i] = lowerPos;
			DoAlert(i, "Synergy: Add to Buy Signal");
		}
		
		// If all in Short position, signal to SELL at this candle's open
		if (!InSell && MA_Trend_Dir == OP_SELL && HA_Outside_MA_Dir == OP_SELL && 
			TDI_Dir == OP_SELL && (!UseVolExpanding || VolBandsExpanding()) && 
			(!UseChaikin || Chaikin > 0) && (!UseH4Trend || H4_Trend == OP_SELL))
		{
			SellEntryBuf[i] = upperPos;
			InSell = true;
			OpenPriceS = Open[i] - spread;
			DoAlert(i, "Synergy: New Sell Signal");
		}

		else if (InSell && AddToSellPosition())
		{
			AddSellBuf[i] = upperPos;
			DoAlert(i, "Synergy: Add to Sell Signal");
		}
		

		// Check for close signals --------------------------------------------
		HA_Closed_Inside_MA = GetHA_ClosedInside();
		TDI_Dir = GetTDI_ExitDir();
		CandleSmallerOrOpp = GetCandleSmallerOrOpposite();
			
		// If all in Short position, signal to EXIT LONG at this candle's open
		if (InBuy && CandleSmallerOrOpp == OP_SELL || HA_Closed_Inside_MA || TDI_Dir == OP_SELL)
		{
			BuyExitBuf[i] = upperPos;
			InBuy = false;
			pipsMade = (Open[i] - OpenPriceB) / Point;
			RunningTotal += pipsMade;

			// Create label for pips made for this trade
			clr = Red;
			if (pipsMade >= 0)
				clr = Green;

			if (!IsEA_Calling)
			{
				name = "SynIndBuy" + DoubleToStr(i ,0);
				text = DoubleToStr(pipsMade ,0) + " - " + ExitReason;
				ObjectCreate(name, OBJ_TEXT, 0, Time[i], upperTextPos);
				ObjectSetText(name, text, 8, "Times New Roman", clr);
				DoAlert(i, "Synergy: Exit Buy Signal");
			}
		}
				
		// If all in Long position, signal to EXIT SHORT position at this candle's open
		if (InSell && CandleSmallerOrOpp == OP_BUY || HA_Closed_Inside_MA || TDI_Dir == OP_BUY)
		{
			SellExitBuf[i] = lowerPos;
			InSell = false;
			pipsMade = (OpenPriceS - Open[i]) / Point;
			RunningTotal += pipsMade;

			// Create label for pips made for this trade
			clr = Red;
			if (pipsMade >= 0)
				clr = Green;

			if (!IsEA_Calling)
			{
				name = "SynIndSell" + DoubleToStr(i ,0);
				text = DoubleToStr(pipsMade ,0) + " - " + ExitReason;
				ObjectCreate(name, OBJ_TEXT, 0, Time[i], lowerTextPos);
				ObjectSetText(name, text, 8, "Times New Roman", clr);
				DoAlert(i, "Synergy: Exit Sell Signal");
			}
		}
//		Print("i == " + i + "        InBuy == " + InBuy + "        InSell == " + InSell);
	}

	// On zero (most recent) candle, put up the total (only once)
	if (!IsEA_Calling)
	{
		ObjectDelete("TotalPips");
		text = DoubleToStr(RunningTotal ,0) + " pips: " + Bars + " Bars";
		ObjectCreate("TotalPips", OBJ_TEXT, 0, Time[0], upperTextPos + sp*Point);
		ObjectSetText("TotalPips", text, 10, "Times New Roman", Yellow);
	}

	return(0);
}


void DoAlert(int i, string str)
{
	if (UseAlert && i == 0 && !IsEA_Calling)
		Alert(str);
}


void AcquireIndicatorValues(int i) 
{
	// Get Haiken Ashi values (last closed candle)
	HA_HiLo_2  = iCustom(NULL, 0, "HeikenAshi_DM",   0, i+1); // Low  (if long, else High)
	HA_LoHi_2  = iCustom(NULL, 0, "HeikenAshi_DM",   1, i+1); // High (if long, else Low)
	HA_Open_1  = iCustom(NULL, 0, "HeikenAshi_DM",   2, i+1); // Open
	HA_Close_1 = iCustom(NULL, 0, "HeikenAshi_DM",   3, i+1); // Close
	
	// Get Haiken Ashi values (one prior to last closed candle)
	HA_Open_2 = iCustom(NULL, 0, "HeikenAshi_DM",   2, i+2); // Open
	HA_Close_2 = iCustom(NULL, 0, "HeikenAshi_DM",   3, i+2); // Close
	
	// Get Traders Dynamic Index values
	BlueH_1 	= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   1, i+1);	// Blue   (H. Vol Band)
	Yellow_1 	= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   2, i+1);	// Yellow (Market Base)
	BlueL_1 	= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   3, i+1);	// Blue   (L. Vol Band)
	Green_1 	= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   4, i+1);	// Green  (RSI Price)
	Red_1 		= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   5, i+1);	// Red    (Trade Signal)
	Red_0 		= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   5, i);		// Red    (Current Candle)
	Red_2 		= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   5, i+2);	// Red    (Prev Prev Candle)
	BlueH_0 	= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   1, i);		// Blue   (Current Candle)
	BlueL_0 	= iCustom(NULL, 0, "Traders_Dynamic_Index", 13, 0, 34, 2, 0, 7, 0,   3, i);		// Blue   (Current Candle)
	
	// Get Smoothed Moving Average values
	MA_Hi_0 = iMA(NULL, 0, 5, 0, MODE_SMMA, PRICE_HIGH, i);
	MA_Lo_0 = iMA(NULL, 0, 5, 0, MODE_SMMA, PRICE_LOW, i);
	MA_Hi_1 = iMA(NULL, 0, 5, 0, MODE_SMMA, PRICE_HIGH, i+1);
	MA_Lo_1 = iMA(NULL, 0, 5, 0, MODE_SMMA, PRICE_LOW, i+1);
	MA_Hi_2 = iMA(NULL, 0, 5, 0, MODE_SMMA, PRICE_HIGH, i+2);
	MA_Lo_2 = iMA(NULL, 0, 5, 0, MODE_SMMA, PRICE_LOW, i+2);
	
	// Get Chaikin's Volatility 
//	Chaikin	= iCustom(NULL, 0, "Chaikin\'s Volatility", 13, 13, 26,   0, i);	// Red line
	Chaikin	= iCustom(NULL, 0, "Chaikin\'s Volatility_Kalenzo", 13, 13, 2000,   0, i);	// Red line
}


int GetMA_Trend()
{
	int sum = 0;
	
	// We are looking for the general trend here, so check 
	// whether lines are headed up or down, comparing this 
	// candle with the prev and the prev prev
	if (MA_Hi_0 > MA_Hi_1)	sum++;
	if (MA_Lo_0 > MA_Lo_1)	sum++;
	if (MA_Hi_0 > MA_Hi_2)	sum++;
	if (MA_Lo_0 > MA_Lo_2)	sum++;
	if (MA_Hi_1 > MA_Hi_2)	sum++;
	if (MA_Lo_1 > MA_Lo_2)	sum++;
		
	if (MA_Hi_0 < MA_Hi_1)	sum--;
	if (MA_Lo_0 < MA_Lo_1)	sum--;
	if (MA_Hi_0 < MA_Hi_2)	sum--;
	if (MA_Lo_0 < MA_Lo_2)	sum--;
	if (MA_Hi_1 < MA_Hi_2)	sum--;
	if (MA_Lo_1 < MA_Lo_2)	sum--;

	// If we have 3 (or 4??) out of 6, consider it to have a direction
	if (sum >= 3)
		return(OP_BUY);
	else if (sum <= -3)
		return(OP_SELL);
	else
		return(-1);
}


int GetH4Trend(int i)
{
	double 	extr0, extr1, open, close;
	int		dir0 = -1;
	int		dir1 = -1;
	int		dir2 = -1;
	
	// We already have the values of the previous HA candle
	// and the previous previous candle.  Get values for 
	// current candle
	open = iCustom(NULL, 0, "HeikenAshi_DM",   2, i); // Open
	if (i == 0)
	{
		extr0 = iCustom(NULL, 0, "HeikenAshi_DM",   0, i);
		extr1 = iCustom(NULL, 0, "HeikenAshi_DM",   1, i);
		if (extr0 <= open && extr1 > open)			dir0 = OP_BUY;
		else if (extr0 >= open && extr1 < open)		dir0 = OP_SELL;
	}
	else 
	{
		close = iCustom(NULL, 0, "HeikenAshi_DM",   3, i); // Close
		if (open < close)							dir0 = OP_BUY;
		else if (open > close)						dir0 = OP_SELL;
	}
	
			
	if (HA_Open_1 < HA_Close_1) 					dir1 = OP_BUY;
	else if (HA_Open_1 > HA_Close_1)				dir1 = OP_SELL;
		
	if (HA_Open_2 < HA_Close_2) 					dir2 = OP_BUY;
	else if (HA_Open_2 > HA_Close_2)				dir2 = OP_SELL;
	
	if (dir0 == OP_BUY && dir1 == OP_BUY && dir2 == OP_BUY)				return(OP_BUY);
	else if (dir0 == OP_SELL && dir1 == OP_SELL && dir2 == OP_SELL)		return(OP_SELL);

	return(-1);
}


int GetHA_CloseDir(int i)
{
	if (HA_Close_1 > HA_Open_1 && HA_Close_1 > MA_Hi_1)
	{
		return(OP_BUY);
	}
	else 
	if (HA_Close_1 < HA_Open_1 && HA_Close_1 < MA_Lo_1)
	{
//		if (i < 10 )
//			Print("          i = " + i + "      GetHA_CloseDir: HA_Close = " + HA_Close_1 + "     Low MA = " + MA_Lo_1);
		return(OP_SELL);
	}
	return(-1);
}


bool VolBandsExpanding()
{
	if (BlueH_0 - BlueL_0 > BlueH_1 - BlueL_1)
		return(true);
	return(false);
}


int GetTDI_EntryDir()
{
	if (Green_1 > 50.0 && 
		(Green_1 < 68.0  || !UseEntry68_32) && 
		(Green_1 > Yellow_1 && Green_1 > Red_1) && 
		(Red_0 > Red_1 && Red_1 > Red_2) && 
		(Red_1 > Yellow_1 || !ReqRedYellowCombo))
		return(OP_BUY);
	else 
	if (Green_1 < 50.0 && 
		(Green_1 > 32.0 || !UseEntry68_32) && 
		(Green_1 < Yellow_1 && Green_1 < Red_1) && 
		(Red_0 < Red_1 && Red_1 < Red_2) && 
		(Red_1 < Yellow_1 || !ReqRedYellowCombo))
		return(OP_SELL);
	return(-1);
}


int GetTDI_ExitDir()
{
	// Check for exiting Buy position
	if (Green_1 > 68.0 && Green_1 < BlueH_1 && Green_1 < Red_1)
	{
		ExitReason = "TDI";
		return(OP_SELL);
	}
	else 
	// Check for exiting sell position
	if (Green_1 < 32.0 && Green_1 > BlueL_1 && Green_1 > Red_1)
	{
		ExitReason = "TDI";
		return(OP_BUY);
	}
	return(-1);
}


bool GetHA_ClosedInside()
{
	// HA_Close_1 is close price
	if (HA_Close_1 > MA_Lo_1 && HA_Close_1 < MA_Hi_1)
	{
		ExitReason = "CI";
		return(true);
	}
	else 
		return(false);
}


int GetCandleSmallerOrOpposite()
{
	if (HA_Close_2 > HA_Open_2)		// 2 candles back was long
	{
		// If prev candle was short, return OP_SELL signal to exit buy
		if (HA_Close_1 < HA_Open_1)
		{
			ExitReason = "OC";
			return(OP_SELL);
		}
			
		// If prev candle was "much smaller" than prev prev, then exit buy
		if (UseSmallerExit)
		{
			if (HA_Close_1 - HA_Open_1 < (HA_Close_2 - HA_Open_2) * DefineSmaller)
			{
				ExitReason = "SC";
				return(OP_SELL);
			}
		}
	}
	else if (HA_Close_2 < HA_Open_2)	// 2 candles back was short
	{
		// If prev candle was long, return OP_BUY signal to exit sell
		if (HA_Close_1 > HA_Open_1)
		{
			ExitReason = "OC";
			return(OP_BUY);
		}
					
		// If prev candle was "much smaller" than prev prev, then exit buy
		if (UseSmallerExit)
		{
			if (HA_Open_1 - HA_Close_1 < (HA_Open_2 - HA_Close_2) * DefineSmaller)
			{
				ExitReason = "SC";
				return(OP_BUY);
			}
		}
	}
	return(-1);
}


bool AddToBuyPosition()
{
	if (Green_1 > 50.0 && Green_1 < 68.0 && Green_1 > BlueH_1)
		return(true);
	return(false);
}


int AddToSellPosition()
{
	if (Green_1 < 50.0 && Green_1 > 32.0 && Green_1 < BlueL_1)
		return(true);
	return(false);
}


