#property copyright "Copyright © 2012 BloodRabbit"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 OrangeRed
#property indicator_width1 3
#property indicator_color2 LimeGreen
#property indicator_width2 3
#property indicator_maximum 1
#property indicator_minimum 0

int TF = 0;
extern int CalcPeriod = 10;
extern int Smooth = 1;
extern int Filter = 5;
extern bool Mode = true;
extern bool GONG = true;
int Method = MODE_LWMA;

double gadblDown[];
double gadblUp[];
double gadblVQ[];
double gadblPrev[];
double gadblReal[];

datetime gdtLastAlertCheck;
string   gstrShortName;

int init()
{
   IndicatorBuffers( 5 ); 
   IndicatorDigits( Digits );
   
   gstrShortName = "BloodRabbit_2.2";
   
   if ( TF == 0 )     gstrShortName = gstrShortName + Period();
   else                   gstrShortName = gstrShortName + TF;
    
   IndicatorShortName( gstrShortName );
   gdtLastAlertCheck = 0;
   
   SetIndexBuffer( 0, gadblDown );   SetIndexStyle( 0, DRAW_HISTOGRAM );  SetIndexLabel( 0, NULL );
   SetIndexBuffer( 1, gadblUp );     SetIndexStyle( 1, DRAW_HISTOGRAM );  SetIndexLabel( 1, NULL ); 
   SetIndexBuffer( 2, gadblVQ );     SetIndexStyle( 2, DRAW_NONE );       SetIndexLabel( 2, gstrShortName ); 
   SetIndexBuffer( 3, gadblPrev );   SetIndexStyle( 3, DRAW_NONE );       SetIndexLabel( 3, NULL );
   SetIndexBuffer( 4, gadblReal );   SetIndexStyle( 4, DRAW_NONE );       SetIndexLabel( 4, "BR" );
   
   return( 0 );
}

int deinit()
{   
   return( 0 );
}

int start()
{
   int intReturn;
   
   if ( TF == 0 || TF == Period() )       intReturn = processCurr();
   else                                           
   {
      if ( Mode )                         intReturn = processTrue();
      else                                        intReturn = processOther();
   }
   
   if ( GONG )    doAlert();
      
   return( intReturn );
}
int processCurr()
{
   int intCountedBars = IndicatorCounted();

   if ( intCountedBars < 0 )   return( -1 );   
   if ( intCountedBars > 0 )   intCountedBars--;   
   if ( intCountedBars == 0 )  intCountedBars = ( CalcPeriod + 2 + Smooth );
   
   int intMax = Bars - intCountedBars;
   double dblCurr;
   
   for ( int inx = intMax; inx >= 0; inx-- )
   {
      dblCurr = calcUtfVQ( inx );
      gadblReal[inx] = dblCurr;
      
      if ( dblCurr == 0.0 )
      {
         if ( gadblVQ[inx+1] < 0.0 )     dblCurr = (-1) * Point;
         else                            dblCurr = Point;
      }
      
      if ( MathAbs( dblCurr ) < ( Filter * Point ) )      gadblVQ[inx] = gadblVQ[inx+1];
      else                                                    gadblVQ[inx] = dblCurr;
                                       
      gadblDown[inx] = 0.0;
      gadblUp[inx] = 0.0;
      
      if ( gadblVQ[inx] > 0.0 )         gadblUp[inx] = 1.0;
      else if ( gadblVQ[inx] < 0.0 )    gadblDown[inx] = 1.0;
   }
   
   return( 0 );
}

int processOther()
{
   int intCountedBars = IndicatorCounted();

   if ( intCountedBars < 0 )   return( -1 );   
   if ( intCountedBars > 0 )   intCountedBars--;   
   if ( intCountedBars == 0 )  intCountedBars = ( CalcPeriod + 2 + Smooth );
   
   double dblCurr;
   datetime dtU; 
   int intU, intL0;  
   int intMax = MathMax( Bars - intCountedBars, TF / Period() );
      
   for ( int inx = intMax; inx >= 0; inx-- )
   {
      intU = iBarShift( Symbol(), TF, Time[inx] ); 
      dtU = iTime( Symbol(), TF, intU ); 
      intL0 = calcUtfStart( dtU );
      gadblPrev[inx] = gadblVQ[intL0+1];    
      dblCurr = calcUtfVQ( intU );
      gadblReal[inx] = dblCurr;
      
      if ( dblCurr == 0.0 )
      {
         if ( gadblPrev[inx] < 0.0 )     dblCurr = (-1) * Point;
         else                            dblCurr = Point;
      }
      
      if ( MathAbs( dblCurr ) < ( Filter * Point ) )   gadblVQ[inx] = gadblPrev[inx];
      else                                                 gadblVQ[inx] = dblCurr;
                                       
      gadblDown[inx] = 0.0;
      gadblUp[inx] = 0.0;
      
      if ( gadblVQ[inx] > 0.0 )         gadblUp[inx] = 1.0;
      else if ( gadblVQ[inx] < 0.0 )    gadblDown[inx] = 1.0;
   }
   
   return( 0 );
}

int processTrue()
{
   int intCountedBars = IndicatorCounted();

   if ( intCountedBars < 0 )   return( -1 );   
   if ( intCountedBars > 0 )   intCountedBars--;   
   
   double dblCurr;
   datetime dtU; 
   int intU, intL0;  
   int intMax = Bars - intCountedBars;
   
   if ( intMax > 1000 )   intMax = 1000;
      
   for ( int inx = intMax; inx >= 0; inx-- )
   {
      intU = iBarShift( Symbol(), TF, Time[inx] ); 
      dtU = iTime( Symbol(), TF, intU ); 
      intL0 = calcUtfStart( dtU );
      gadblPrev[inx] = gadblVQ[intL0+1];   
      dblCurr = calcTrue( intU, inx, intL0 );
      gadblReal[inx] = dblCurr;
      
      if ( dblCurr == 0.0 )
      {
         if ( gadblPrev[inx] < 0.0 )     dblCurr = (-1) * Point;
         else                            dblCurr = Point;
      }
      
      if ( MathAbs( dblCurr ) < ( Filter * Point ) )   gadblVQ[inx] = gadblPrev[inx];
      else                                                 gadblVQ[inx] = dblCurr;
                                       
      gadblDown[inx] = 0.0;
      gadblUp[inx] = 0.0;
      
      if ( gadblVQ[inx] > 0.0 )         gadblUp[inx] = 1.0;
      else if ( gadblVQ[inx] < 0.0 )    gadblDown[inx] = 1.0;
   }
   
   return( 0 );
}

double calcUtfVQ( int inx )
{
   double dblHigh = iMA( Symbol(), TF, CalcPeriod, 0, Method, PRICE_HIGH, inx );
   double dblLow  = iMA( Symbol(), TF, CalcPeriod, 0, Method, PRICE_LOW, inx );
   double dblOpen = iMA( Symbol(), TF, CalcPeriod, 0, Method, PRICE_OPEN, inx );
   double dblClose = iMA( Symbol(), TF, CalcPeriod, 0, Method, PRICE_CLOSE, inx );
   double dblClose2 = iMA( Symbol(), TF, CalcPeriod, 0, Method, PRICE_CLOSE, inx+Smooth );

   if ( dblHigh == 0.0 || dblLow == 0.0 || dblOpen == 0.0 || dblClose == 0.0 || dblClose2 == 0.0 )
      return( 0.0 );
      
   return( calcVQ( dblHigh, dblLow, dblOpen, dblClose, dblClose2 ) );
}

double calcTrue( int utf, int ltf, int ltf0 )
{
   double dblOpen = iMA( Symbol(), TF, CalcPeriod, 0, Method, PRICE_OPEN, utf );
   double dblLow = calcMaAltLow( utf, ltf, ltf0 );
   double dblHigh = calcMaAltHigh( utf, ltf, ltf0 );
   double dblClose = calcMaAltClose( utf, ltf );
   double dblClose2;
   
   if ( Smooth > 0 )
      dblClose2 = iMA( Symbol(), TF, CalcPeriod, 0, Method, PRICE_CLOSE, utf+Smooth );
   else
      dblClose2 = dblClose;

   if ( dblHigh == 0.0 || dblLow == 0.0 || dblOpen == 0.0 || dblClose == 0.0 || dblClose2 == 0.0 )
      return( 0.0 );
      
   return( calcVQ( dblHigh, dblLow, dblOpen, dblClose, dblClose2 ) );
}

double calcVQ( double h, double l, double o, double c, double c2 )
{
   double dblMax = MathMax(h-l,MathMax(h-c2,c2-l));
   double dblVQ = MathAbs(((c - c2) / dblMax + (c - o) / (h - l)) * 0.5) * ((c - c2 + (c - o)) * 0.5);
   return( dblVQ );
}

double calcMaAltClose( int utf, int ltf )
{
   double adblTemp[], adblPrices[];
   
   ArraySetAsSeries( adblPrices, true );   
   ArrayCopySeries( adblTemp, MODE_CLOSE, Symbol(), TF );
   ArrayCopy( adblPrices, adblTemp );
   
   adblPrices[utf] = Close[ltf];
   return( iMAOnArray( adblPrices, 0, CalcPeriod, 0, Method, utf ) );
}
double calcMaAltHigh( int utf, int ltf, int ltf0 )
{
   double adblTemp[], adblPrices[];
   
   ArraySetAsSeries( adblPrices, true );   
   ArrayCopySeries( adblTemp, MODE_HIGH, Symbol(), TF );
   ArrayCopy( adblPrices, adblTemp );
   
   int intCount = ltf0 - ltf + 1;
            
   if ( intCount <= 1 )
   {
      adblPrices[utf] = High[ltf];
   }
   else
   {
      int intTmpShift = ArrayMaximum( High, intCount, ltf );
      adblPrices[utf] = High[intTmpShift];  
   }
   
   return( iMAOnArray( adblPrices, 0, CalcPeriod, 0, Method, utf ) );
}

double calcMaAltLow( int utf, int ltf, int ltf0 )
{
   double adblTemp[], adblPrices[];
   
   ArraySetAsSeries( adblPrices, true );   
   ArrayCopySeries( adblTemp, MODE_LOW, Symbol(), TF );
   ArrayCopy( adblPrices, adblTemp );
   
   int intCount = ltf0 - ltf + 1;
            
   if ( intCount <= 1 )
   {
      adblPrices[utf] = Low[ltf];
   }
   else
   {
      int intTmpShift = ArrayMinimum( Low, intCount, ltf );
      adblPrices[utf] = Low[intTmpShift];  
   }
   
   return( iMAOnArray( adblPrices, 0, CalcPeriod, 0, Method, utf ) );
}
  
int calcUtfStart( datetime dt )
{
   int intStart = iBarShift( Symbol(), Period(), dt, true );
   
   if ( intStart < 0 )    intStart = iBarShift( Symbol(), Period(), dt, false ) - 1; 
   
   return( intStart );
}

void doAlert()
{
   if ( gdtLastAlertCheck == 0 )
   {
      gdtLastAlertCheck = Time[0];
      return;
   }
    
   if ( Time[0] > gdtLastAlertCheck )
   {
      gdtLastAlertCheck = Time[0];
      string strMsg = "";
      
      if ( ( gadblUp[1] > 0.0 ) && ( gadblDown[2] > 0.0 ) )          strMsg = "Up";
      if ( ( gadblDown[1] > 0.0 ) && ( gadblUp[2] > 0.0 ) )          strMsg = "Down";
      
      if ( StringLen( strMsg ) > 0 )
      {
         Alert( TimeToStr( TimeCurrent(), TIME_DATE|TIME_SECONDS ), " - ", 
                Symbol(), Period(), " - ", gstrShortName, " - ", strMsg );
      }
   }
}