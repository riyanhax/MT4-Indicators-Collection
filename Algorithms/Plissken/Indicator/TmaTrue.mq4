//+------------------------------------------------------------------+
//|                                                      TmaTrue.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, zznbrm"
                          
//---- indicator settings
#property indicator_chart_window
#property  indicator_buffers 3 
#property  indicator_color1 DarkGray
#property  indicator_color2 DarkGray
#property  indicator_color3 DarkGray
#property  indicator_width1 1
#property  indicator_width2 1
#property  indicator_width3 1
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style2 STYLE_SOLID

//---- input parameters
extern int eintTimeframe = 0;
extern int eintHalfLength = 56;
extern double edblAtrMultiplier = 3.0;
extern int eintAtrPeriod = 100;
extern int eintBarsToProcess = 0;
extern bool eblnAlerts = false;

//---- indicator buffers
double gadblMid[];
double gadblUpper[];
double gadblLower[];

int gintTF = 0;
datetime gdtLastAlert = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{          
   if ( eintTimeframe == 0 )   gintTF = Period();
   else                        gintTF = eintTimeframe;
   
   gdtLastAlert = 0;
   
   IndicatorBuffers( 3 );
   IndicatorDigits( 5 );
   
   SetIndexBuffer( 0, gadblMid ); 
   SetIndexLabel( 0, "TMA Mid" );

   SetIndexBuffer( 1, gadblUpper );
   SetIndexLabel( 1, "TMA Upper" );
   
   SetIndexBuffer( 2, gadblLower );
   SetIndexLabel( 2, "TMA Lower" );   
       
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName( "TmaTrue(" + eintHalfLength + ",M" + gintTF + ")" );
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int intLimit = Bars - counted_bars;
   double dblTma, dblUpper, dblLower, dblRange;
   int intBarShift;
      
   if ( eintBarsToProcess > 0 && intLimit > eintBarsToProcess )     intLimit = eintBarsToProcess; 

   for( int inx = intLimit; inx >= 0; inx-- )
   {   
      if ( gintTF == Period() ) 
      {      
         dblRange = iATR( Symbol(), gintTF, eintAtrPeriod, inx+10 );
         dblTma = calcTma( eintHalfLength, inx );
      }
      else
      {
         intBarShift = iBarShift( Symbol(), gintTF, Time[inx] );
         dblRange = iATR( Symbol(), gintTF, eintAtrPeriod, intBarShift+10 );
         dblTma = calcTmaMtf( gintTF, eintHalfLength, intBarShift, Close[inx] );
      }
             
      gadblMid[inx] = dblTma;
      gadblUpper[inx] = dblTma + ( edblAtrMultiplier * dblRange );
      gadblLower[inx] = dblTma - ( edblAtrMultiplier * dblRange );
   }
   
   if ( eblnAlerts && gdtLastAlert < Time[1] )
   {
      if ( ( Close[1] > gadblUpper[1] ) && ( Close[2] < gadblUpper[2] ) )
      {
         Alert( Symbol(), " - M", Period(), " - ", TimeToStr( Time[1], TIME_DATE|TIME_MINUTES ), " closed above upper TMA." );
         gdtLastAlert = Time[1];
      }
      
      if ( ( Close[1] < gadblLower[1] ) && ( Close[2] > gadblLower[2] ) )
      {
         Alert( Symbol(), " - M", Period(), " - ", TimeToStr( Time[1], TIME_DATE|TIME_MINUTES ), " closed below lower TMA." );
         gdtLastAlert = Time[1];
      }
   }
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( int intHalfLength, int intShift )
{
   double dblResult, dblSum, dblSumW, dblRange;
   int inx, jnx, knx;
   
   dblSumW = intHalfLength + 1;
   dblSum = dblSumW * Close[intShift];
   jnx = intHalfLength;
   
   for ( inx = 1, jnx = intHalfLength; inx <= intHalfLength; inx++, jnx-- )
   {
      dblSumW += jnx;
      dblSum += ( jnx * Close[intShift+inx] );
   } 
   
   dblResult = dblSum / dblSumW;
   
   return( dblResult );
}

//+------------------------------------------------------------------+
//| calcTmaMtf()                                                     |
//+------------------------------------------------------------------+
double calcTmaMtf( int intTF, int intHalfLength, int intUpperTfShift, double dblClose )
{
   double dblResult, dblSum, dblSumW, dblRange;
   int inx, jnx, knx;
   
   // This is the current bar
   dblSumW = intHalfLength + 1;
   dblSum = dblSumW * dblClose;
   jnx = intHalfLength;
   
   for ( inx = 1, jnx = intHalfLength; inx <= intHalfLength; inx++, jnx-- )
   {
      dblSumW += jnx;
      dblSum += ( jnx * iClose( Symbol(), intTF, intUpperTfShift+inx ) );  
   } 
   
   dblResult = dblSum / dblSumW;
   
   return( dblResult );
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 



   


