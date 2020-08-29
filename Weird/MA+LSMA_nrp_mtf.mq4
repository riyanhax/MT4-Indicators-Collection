//+------------------------------------------------------------------+
//|                                                     LSMA nrp.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
//mod mtf
#property  copyright "copyleft mladen"
#property  link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Orange
#property indicator_color5 Orange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

//
//
//
//
//

extern int    MAPeriod   = 14;
extern int    MAPrice    =  0;
extern int    MAmode\LSMA  =  4;

//
//
//
//
//
extern int TimeFrame = 0;

extern string note_timeFrames = "M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";
extern string note_price = "0C 1O 2H 3L 4Md 5Tp 6WghC: Md(HL/2)4,Tp(HLC/3)5,Wgh(HLCC/4)6";
extern string note_MAmode\LSMA = "lsma4 SMA0 EMA1 SMMA2 LWMA3";



double lsma[];
double lsmaua[];
double lsmaub[];
double lsmada[];
double lsmadb[];

string IndicatorFileName;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,lsma);
   SetIndexBuffer(1,lsmaua);
   SetIndexBuffer(2,lsmaub);
   SetIndexBuffer(3,lsmada);
   SetIndexBuffer(4,lsmadb);

   TimeFrame = MathMax(TimeFrame,Period());
   IndicatorFileName = WindowExpertName();

   return(0);
}

//
//
//
//
//

int start()
{ 
   int      counted_bars=IndicatorCounted();
   int      limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

      lsmaua[i] = EMPTY_VALUE;      lsmaub[i] = EMPTY_VALUE;
      lsmada[i] = EMPTY_VALUE;      lsmadb[i] = EMPTY_VALUE;


      if (TimeFrame != Period())
      {
         limit = MathMax(limit,TimeFrame/Period());
        
        for(i=limit; i>=0; i--)
         {
                int y = iBarShift(NULL,TimeFrame,Time[i]);
   
         lsma[i]      = iCustom(NULL,TimeFrame,IndicatorFileName,MAPeriod,MAPrice,MAmode\LSMA,0,y);
         
         if (lsma[i]>lsma[i+1]) { lsmaua[i]=lsma[i];     lsmaua[i+1]=lsma[i+1];}
         else
         if (lsma[i]<lsma[i+1]) { lsmada[i]=lsma[i];     lsmada[i+1]=lsma[i+1];}
         else                    
                                { lsmaua[i]=lsmaua[i+1]; lsmada[i]=lsmada[i+1];}
                                 
                                
                                 
         
         }

         return(0);         
      }





   //
   //
   //
   //
   //

   if (lsma[limit] > lsma[limit+1]) CleanPoint(limit,lsmaua,lsmaub);
   if (lsma[limit] < lsma[limit+1]) CleanPoint(limit,lsmada,lsmadb);
   for(i = limit; i >= 0; i--)
   {

      if (MAmode\LSMA<0) MAmode\LSMA=0;
      if (MAmode\LSMA<4)

      lsma[i]   = iMA(NULL,0,MAPeriod,0,MAmode\LSMA,MAPrice,i);

      if (MAmode\LSMA>3)
 
      lsma[i]   = 3.0*iMA(NULL,0,MAPeriod,0,MODE_LWMA,MAPrice,i)-2.0*iMA(NULL,0,MAPeriod,0,MODE_SMA,MAPrice,i);


         if (lsma[i] > lsma[i+1]) PlotPoint(i,lsmaua,lsmaub,lsma);
         if (lsma[i] < lsma[i+1]) PlotPoint(i,lsmada,lsmadb,lsma);
   }   
   return(0);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}