//+------------------------------------------------------------------+
//|                                                      CSSDiff.mq4 |
//|                      Copyright 2012, Deltabron - Paul Geirnaerdt |
//|                                          http://www.deltabron.nl |
//+------------------------------------------------------------------+
//
// TMA Calculations © 2012 by ZZNBRM
//
#property copyright "Copyright 2012, Deltabron - Paul Geirnaerdt"
#property link      "http://www.deltabron.nl"

#property description "Genry_05 09-JAN-2018 Добавлен выбор периода"
//----
#property indicator_separate_window
#property indicator_buffers      4

#property indicator_level1       0.8
#property indicator_level2       -0.8
#property indicator_levelcolor   Gold 

#define version            "v1.0.1"

//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+
// v1.0.0 (alpha), 6/8/12
// * Initial release
// v1.0.0, 6/15/12
// * Added option to disable so-called 'repainting', that is not to consider future bars for any calculation
// * Code optimization

#define EPSILON            0.00000001

#define CURRENCYCOUNT      8

//---- parameters
input    int               i_TmaTruePeriod = 21;
input ENUM_MA_METHOD       i_TmaTrueMode   = MODE_LWMA; 
input ENUM_APPLIED_PRICE   i_TmaTruePrice  = PRICE_CLOSE;


extern string  gen               = "----General inputs----";
extern bool    autoSymbols       = false;
extern string	symbolsToWeigh    = "GBPNZD,EURNZD,GBPAUD,GBPCAD,GBPJPY,GBPCHF,CADJPY,EURCAD,EURAUD,USDCHF,GBPUSD,EURJPY,NZDJPY,AUDCHF,AUDJPY,USDJPY,EURUSD,NZDCHF,CADCHF,AUDNZD,NZDUSD,CHFJPY,AUDCAD,USDCAD,NZDCAD,AUDUSD,EURCHF,EURGBP";
extern int     maxBars           = 0;
extern string  nonPropFont       = "Lucida Console";

extern string  ind               = "----Indicator inputs----";
extern bool    ignoreFuture      = false;

extern string  col               = "----Colo(u)r inputs----";
extern color   lineColor         = Gray;
extern color   lineColorOver8    = Lime;
extern color   lineColorUnder8   = Red;
extern color   labelColor        = Yellow;

// global indicator variables
string   indicatorName = "CSSDiff";
string   shortName;
string   almostUniqueIndex;

// indicator buffers
double   lineCSSDiff[];
double   lineRangingCSSDiff[];
double   lineOver8CSSDiff[];
double   lineUnder8CSSDiff[];

// symbol & currency variables
int      symbolCount;
string   symbolNames[];
string   currencyNames[CURRENCYCOUNT]        = { "USD", "EUR", "GBP", "CHF", "JPY", "AUD", "CAD", "NZD" };
double   currencyValues[CURRENCYCOUNT];      // Currency slope strength
double   currencyOccurrences[CURRENCYCOUNT]; // Holds the number of occurrences of each currency in symbols

// object parameters
int      verticalShift = 14;
int      verticalOffset = 30;
int      horizontalShift = 100;
int      horizontalOffset = 0;

//----

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   initSymbols();
 
//---- indicators
   shortName = indicatorName + "(Period="+IntegerToString(i_TmaTruePeriod)+") - " + version;
   IndicatorBuffers(4);
   IndicatorShortName(shortName);

   SetIndexBuffer(0, lineCSSDiff);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexLabel(0, NULL); 

   SetIndexBuffer(1, lineOver8CSSDiff);
   SetIndexLabel(1, "Over8CSSDiff"); 

   SetIndexBuffer(2, lineUnder8CSSDiff);
   SetIndexLabel(2, "Under8CSSDiff"); 

   SetIndexBuffer(3, lineRangingCSSDiff);
   SetIndexLabel(3, "CSSDiff"); 

   string now = TimeCurrent();
   almostUniqueIndex = StringSubstr(now, StringLen(now) - 3);

   return(0);
}

//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
void initSymbols()
{
   int i;
   
   // Get extra characters on this crimmal's symbol names
   string symbolExtraChars = StringSubstr(Symbol(), 6, 4);

   // Trim user input
   symbolsToWeigh = StringTrimLeft(symbolsToWeigh);
   symbolsToWeigh = StringTrimRight(symbolsToWeigh);

   // Add extra comma
   if (StringSubstr(symbolsToWeigh, StringLen(symbolsToWeigh) - 1) != ",")
   {
      symbolsToWeigh = StringConcatenate(symbolsToWeigh, ",");   
   }   

   // Build symbolNames array as the user likes it
   if ( autoSymbols )
   {
      createSymbolNamesArray();
   }
   else
   {
      // Split user input
      i = StringFind(symbolsToWeigh, ","); 
      while (i != -1)
      {
         int size = ArraySize(symbolNames);
         // Resize array
         ArrayResize(symbolNames, size + 1);
         // Set array
         symbolNames[size] = StringConcatenate(StringSubstr(symbolsToWeigh, 0, i), symbolExtraChars);
         // Trim symbols
         symbolsToWeigh = StringSubstr(symbolsToWeigh, i + 1);
         i = StringFind(symbolsToWeigh, ","); 
      }
   }   
   
   symbolCount = ArraySize(symbolNames);

   for ( i = 0; i < symbolCount; i++ )
   {
      // Increase currency occurrence
      int currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3));
      currencyOccurrences[currencyIndex]++;
      currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3));
      currencyOccurrences[currencyIndex]++;
   }   

}

//+------------------------------------------------------------------+
//| GetCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
int GetCurrencyIndex(string currency)
{
   for (int i = 0; i < CURRENCYCOUNT; i++)
   {
      if (currencyNames[i] == currency)
      {
         return(i);
      }   
   }   
   return (-1);
}

//+------------------------------------------------------------------+
//| createSymbolNamesArray()                                         |
//+------------------------------------------------------------------+
void createSymbolNamesArray()
{
   int hFileName = FileOpenHistory ("symbols.raw", FILE_BIN|FILE_READ );
   int recordCount = FileSize ( hFileName ) / 1936;
   int counter = 0;
   for ( int i = 0; i < recordCount; i++ )
   {
      string tempSymbol = StringTrimLeft ( StringTrimRight ( FileReadString ( hFileName, 12 ) ) );
      if ( MarketInfo ( tempSymbol, MODE_BID ) > 0 && MarketInfo ( tempSymbol, MODE_TRADEALLOWED ) )
      {
         ArrayResize( symbolNames, counter + 1 );
         symbolNames[counter] = tempSymbol;
         counter++;
      }
      FileSeek( hFileName, 1924, SEEK_CUR );
   }
   FileClose( hFileName );
   return;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   int windex = WindowFind ( shortName );
   if ( windex > 0 )
   {
      ObjectsDeleteAll ( windex );
   }   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars = IndicatorCounted();

   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)  counted_bars -= 10;

   limit = Bars - counted_bars;

   if ( maxBars > 0 )
   {
      limit = MathMin (maxBars, limit);   
   }   

   SetIndexStyle( 1, DRAW_HISTOGRAM, STYLE_SOLID, 2, lineColorOver8 );
   SetIndexStyle( 2, DRAW_HISTOGRAM, STYLE_SOLID, 2, lineColorUnder8 );
   SetIndexStyle( 3, DRAW_HISTOGRAM, STYLE_SOLID, 2, lineColor );

   int i;

   RefreshRates();
   
   for ( i = 0; i < limit; i++ )
   {
      int index;
      
      ArrayInitialize(currencyValues, 0.0);

      // Calc Slope into currencyValues[]  
      CalculateCurrencySlopeStrength(0, i);

      // Setup the base line      
      lineCSSDiff[i] = 0;
      for ( index = 0; index < CURRENCYCOUNT; index++ )
      {
         if ( index == GetCurrencyIndex(StringSubstr(Symbol(), 0, 3)) )
         {
            lineCSSDiff[i] += currencyValues[index];
         }   
         if ( index == GetCurrencyIndex(StringSubstr(Symbol(), 3, 3)) )
         {
            lineCSSDiff[i] -= currencyValues[index];
         }   
      }
      
      // Setup ranging line
      lineRangingCSSDiff[i] = MathMin(lineCSSDiff[i], 0.8);
      lineRangingCSSDiff[i] = MathMax(lineRangingCSSDiff[i], -0.8);

      // Setup over and under .8 lines
      lineUnder8CSSDiff[i] = 0;
      if ( lineCSSDiff[i] < -0.8 )
      {
         lineUnder8CSSDiff[i] = lineCSSDiff[i];
      }
      lineOver8CSSDiff[i] = 0;
      if ( lineCSSDiff[i] > 0.8 )
      {
         lineOver8CSSDiff[i] = lineCSSDiff[i];
      }

      if ( i == 0 )
      {
         // Show table
         ShowTable(lineCSSDiff[i]);
      }   

   }//end block for(int i=0; i<limit; i++)
   
   return(0);
}

//+------------------------------------------------------------------+
//| GetSlope()                                                       |
//+------------------------------------------------------------------+
double GetSlope(string symbol, int tf, int shift)
{
   double dblTma, dblPrev;
   double atr = iATR(symbol, tf, 100, shift + 10) / 10;
   double gadblSlope = 0.0;
   if ( atr != 0 )
   {
      if ( ignoreFuture )
      {
         dblTma = calcTmaTrue( symbol, tf, i_TmaTruePeriod, i_TmaTrueMode, i_TmaTruePrice, shift ); 
         dblPrev = calcPrevTrue( symbol, tf, i_TmaTruePeriod, shift );
      }
      else
      {   
         dblTma = calcTma( symbol, tf, i_TmaTruePeriod, shift );
         dblPrev = calcTma( symbol, tf, i_TmaTruePeriod, shift + 1 );
      }   
      gadblSlope = ( dblTma - dblPrev ) / atr;
   }
   
   return ( gadblSlope );

}//End double GetSlope(int tf, int shift)

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( string symbol, int tf,  int intHalfLength, int shift )
{
   double dblSumw = intHalfLength;
   double dblSum  = iClose(symbol, tf, shift) * intHalfLength;

   int jnx, knx;
           
   for ( jnx = 1, knx = intHalfLength-1; jnx <= intHalfLength-1; jnx++, knx-- )   
   {
      dblSum  += ( knx * iClose(symbol, tf, shift + jnx) );
      dblSumw += knx;

      if ( jnx <= shift )
      {
         dblSum  += ( knx * iClose(symbol, tf, shift - jnx) );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );

}// End calcTma()

//+------------------------------------------------------------------+
//| calcTmaTrue()                                                    |
//+------------------------------------------------------------------+
double calcTmaTrue( string symbol, int tf, int TmaTruePeriod, int TmaTrueMode, int TmaTruePrice, int inx )
{
   return ( iMA( symbol, tf, TmaTruePeriod, 0, TmaTrueMode, TmaTruePrice, inx ) );
}

//+------------------------------------------------------------------+
//| calcPrevTrue()                                                   |
//+------------------------------------------------------------------+
double calcPrevTrue( string symbol, int tf, int intHalfLength, int inx )
{
   double dblSumw = intHalfLength;
   double dblSum  = iClose(symbol, tf, inx) * intHalfLength;

   int jnx, knx;
   
   dblSumw += intHalfLength-1;   
   dblSum  += iClose( symbol, tf, inx ) * (intHalfLength-1);

         
   for ( jnx = 1, knx = intHalfLength-1; jnx <= intHalfLength-1; jnx++, knx-- )   
   {
      dblSum  += iClose( symbol, tf, inx + 1 + jnx ) * knx;
      dblSumw += knx;
   }
   
   return ( dblSum / dblSumw );
}
 
//+------------------------------------------------------------------+
//| CalculateCurrencySlopeStrength(int tf, int shift                 |
//+------------------------------------------------------------------+
void CalculateCurrencySlopeStrength(int tf, int shift)
{
   int i;
   // Get Slope for all symbols and totalize for all currencies   
   for ( i = 0; i < symbolCount; i++)
   {
      double slope = GetSlope(symbolNames[i], tf, shift);
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3))] += slope;
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3))] -= slope;
   }
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      // average
      currencyValues[i] /= currencyOccurrences[i];
   }
}

//+------------------------------------------------------------------+
//| ShowTable()                                                      |
//+------------------------------------------------------------------+
void ShowTable(double CSSDiff)
{
   int i = 0;
   string objectName;
   string showText;
   int windex = WindowFind ( shortName );
   
   objectName = almostUniqueIndex + "_css_obj_column_header_" + i;
   if ( ObjectFind ( objectName ) == -1 )
   {
      if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
      {
         ObjectSet ( objectName, OBJPROP_CORNER, 1 );
         ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 24 + 140 );
         ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18 );
      }
   }
   showText = "current";
   ObjectSetText ( objectName, showText, 7, nonPropFont, labelColor );

   objectName = almostUniqueIndex + "_css_obj_column_symbol_" + i;
   if ( ObjectFind ( objectName ) == -1 )
   {
      if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
      {
         ObjectSet ( objectName, OBJPROP_CORNER, 1 );
         ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 140 );
         ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18 + 8 );
      }
   }
   showText = Symbol();
   ObjectSetText ( objectName, showText, 12, nonPropFont, labelColor );

   objectName = almostUniqueIndex + "_css_obj_column_value_" + i;
   if ( ObjectFind ( objectName ) == -1 )
   {
      if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
      {
         ObjectSet ( objectName, OBJPROP_CORNER, 1 );
         ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 55 + 140 );
         ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18 + 8 );
      }
   }
   showText = RightAlign(DoubleToStr(CSSDiff, 2), 5);
   ObjectSetText ( objectName, showText, 12, nonPropFont, labelColor );
}

//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
string RightAlign ( string text, int length = 10, int trailing_spaces = 0 )
{
   string text_aligned = text;
   for ( int i = 0; i < length - StringLen ( text ) - trailing_spaces; i++ )
   {
      text_aligned = " " + text_aligned;
   }
   return ( text_aligned );
}


