//+------------------------------------------------------------------+
//|                                                    AvgSpread.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, zznbrm"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_width1 3
#property indicator_color1 DimGray

//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
double gadblSpread[];

//*********************************************************************************************
//* STANDARD FUNCTIONS BELOW                                                                  *
//*********************************************************************************************
//+------------------------------------------------------------------+
//| init()                                                           |
//+------------------------------------------------------------------+
int init()
{  
   IndicatorBuffers( 1 );
   IndicatorDigits( 3 );
   IndicatorShortName( "AvgSpread" ); 
   
   SetIndexBuffer( 0, gadblSpread );   SetIndexLabel( 0, "Avg Spread" );      SetIndexStyle( 0, DRAW_HISTOGRAM );
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| deinit()                                                         |
//+------------------------------------------------------------------+
int deinit()
{
   return( 0 );
}

//+------------------------------------------------------------------+
//| start()                                                          |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   
   if (counted_bars < 0) return (-1);
   if (counted_bars == 0 )   counted_bars++;
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   double dblVolume, dblTemp, dblSpreadTotal;
   
   for ( int inx = limit; inx >= 0; inx-- )
   {
      dblVolume = MathFloor( Volume[inx] );
      
      if ( dblVolume <= 0.0 )
      {
         gadblSpread[inx] = 0.0;
      }
      else
      {
         dblTemp = MathRound( ( Volume[inx] - dblVolume) / 0.00000001 );
         dblSpreadTotal = MathMax( dblTemp / 10.0, 0.0 );
         gadblSpread[inx] = dblSpreadTotal / dblVolume;
      }
   }  
       
   return( 0 );
}