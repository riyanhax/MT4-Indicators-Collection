//+------------------------------------------------------------------
//|
//|
//| volumeRev
//|
//|
//+------------------------------------------------------------------
#property copyright "alToronto"
#property link      "www.gmail.com"

#property indicator_chart_window
#property indicator_buffers    2
#property indicator_color1     DeepSkyBlue
#property indicator_color2     PaleVioletRed
#property indicator_width1     2
#property indicator_width2     2

//
//
//
//
//
extern double             Arrow_offset = 2;
extern bool               useMA        = false;
input int                 MA_Period    = 10;//MA Period
input int                 MA_Shift     = 0;//MA Shift
input ENUM_MA_METHOD      MA_Method    = 0;//MA Method

double signUp[];
double signDown[];
double volumeBuffer[];
double volumeMA[];

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(3);
      SetIndexBuffer(0,signUp);   SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,159);
      SetIndexBuffer(1,signDown); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159);
      SetIndexBuffer(2,volumeBuffer);
   return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--) volumeBuffer[i] = Volume[i];
   for(i=limit; i>=0; i--)
   {
                     
         signUp[i]   = EMPTY_VALUE;
         signDown[i] = EMPTY_VALUE;
         
         volumeMA[i] = iMAOnArray(volumeBuffer,0,MA_Period,MA_Shift,MA_Method,i);
         
         if ((!useMA && Volume[i+1]>Volume[i+2]) || (useMA && Volume[i+1])) {
                  
         if ( (Low[i]<=Low[i+2]) &&
						(Close[i]>=Close[i+1]) && (Close[i]>=Open[i]) &&
						(Close[i] > Low[i])) 
					{
						//Signal 1
						if (Low[i]<=Low[i+1]) signUp[i] = Low[i]-iATR(NULL,0,10,i)/Arrow_offset;
						// signal 2
						else if (Low[i]>=Low[i+1]) signUp[i] = Low[i]-iATR(NULL,0,10,i)/Arrow_offset;
 
					}
			
			else if((High[i]>=High[i+2]) && 
						(Close[i]<=Close[i+1]) && (Close[i]<=Open[i]) &&
						((Close[i])<(High[i])) )	
					{
						//signal 1
						if (High[i]>=High[i+1]) signDown[i] = High[i] +iATR(NULL,0,10,i)/Arrow_offset;					
						//  signal 2
						else if (High[i]<=High[i+1]) signDown[i] = High[i] +iATR(NULL,0,10,i)/Arrow_offset;		
							
					}

      }            
   }
   return(0);
}