//+------------------------------------------------------------------+
//|                                  Elders's market thermometer.mq4 |
//|                                                  coded by mladen |
//|                                                                  |
//|                                                                  |
//| Original developed by Alexander Elder,                           |
//| "Come Into My Trading Room"                                      |
//|                                                                  |
//|                                                                  |
//| modes :                                                          |
//|   1 - original mode                                              |
//|   2 - change in colors:                                          |
//|       green -> up change                                         |
//|       red -> down change                                         |
//|   3 - Silberman's and Lynch modifications                        |
//|       if in trade already and red bar, then exit                 |
//|       get ready for explosive move if yellow bar                 |
//|       if not in trade, white bar suggests a move has started     |
//|       set profit target for next day                             |
//|         -- if Long, add value of today's Thermometer EMA to      |
//|            yesterday's high and place sell order there           |
//|         -- if Short, subtract value of today's Thermometer EMA   |
//|            from yesterday's low and place order to cover there   |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_minimum 0
#property indicator_color1  clrDimGray
#property indicator_color2  clrDimGray
#property indicator_color3  clrDimGray
#property indicator_color4  clrGreen
#property indicator_color5  clrRed
#property indicator_color6  clrLimeGreen
#property indicator_color7  clrYellow
#property indicator_color8  clrWhite
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2

//
//
//
//
//

enum enModes
{
   en_ori, // Original mode
   en_col, // Changed colors mode
   en_sil  // Silberman's and Lynch modifications
};
extern int     EMALength = 22;
extern int     EMAKoef1  = 2;
extern int     EMAKoef2  = 3;
extern int     BarsUnder = 5;
extern enModes Mode      = en_sil;

//
//
//
//
//

double avgTemperatureA[];
double avgTemperatureB[];
double avgTemperatureC[];
double temperature[];
double buffer5[];
double buffer6[];
double buffer7[];
double buffer8[];


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
   SetIndexBuffer(0,avgTemperatureA);
   SetIndexBuffer(1,avgTemperatureB);
   SetIndexBuffer(2,avgTemperatureC);
   SetIndexBuffer(3,temperature);
   SetIndexBuffer(4,buffer5);
   SetIndexBuffer(5,buffer6);
   SetIndexBuffer(6,buffer7);
   SetIndexBuffer(7,buffer8);

   for(int i=3; i<8; i++)
             SetIndexStyle(i,DRAW_HISTOGRAM);
             SetIndexEmptyValue(0,0.00);
             SetIndexEmptyValue(3,0.00);
   return(0);
}
int deinit()
{
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

int start()
{
   double alpha     = 2.0/(1.0+EMALength);
   int counted_bars = IndicatorCounted();
   int limit,i;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         limit = MathMin(limit,Bars-2);

   //
   //
   //
   //
   //
   
   for(i = limit; i >= 0; i--)
   {
      temperature[i] = 0.00;
         if ((High[i]-High[i+1])  > (Low[i+1]-Low[i])) temperature[i] = MathAbs(High[i]-High[i+1]);
         if ((High[i]-High[i+1])  < (Low[i+1]-Low[i])) temperature[i] = MathAbs(Low[i+1]-Low[i]);
         if ((High[i]<High[i+1]) && (Low[i]>Low[i+1])) temperature[i] = 0.00;
      avgTemperatureA[i] = avgTemperatureA[i+1]+alpha*(temperature[i]-avgTemperatureA[i+1]);
      
      //
      //
      //
      //
      //
         
      if (Mode!=en_sil)
         {
            avgTemperatureB[i] = avgTemperatureA[i]*EMAKoef1;
            avgTemperatureC[i] = avgTemperatureA[i]*EMAKoef2;
            buffer5[i]         = EMPTY_VALUE;
      
            if (Mode==en_col)
               if((High[i]-High[i+1]) < (Low[i+1]-Low[i]))
                  buffer5[i] = temperature[i];
         }
      else
         {
            avgTemperatureB[i] = avgTemperatureA[i]*EMAKoef2;
      
            //
            //
            //
            //
            //
      
            int whichBuffer = 1;
            
            if (temperature[i] < avgTemperatureA[i]) whichBuffer = 1;
               else if(temperature[i] < avgTemperatureB[i]) whichBuffer = 2;
                  else if(temperature[i] > avgTemperatureB[i]) whichBuffer = 3;
   
            //
            //
            //
            // 
            //

            int scoreC = 0;
            int scoreP = 0;
               for (int k=0;k<BarsUnder;k++)
               {
                  if(temperature[i+k]   < avgTemperatureA[i+k])   scoreC += 1;
                  if(temperature[i+k+1] < avgTemperatureA[i+k+1]) scoreP += 1;
               }            
               if(scoreC >= BarsUnder) whichBuffer = 4;
               if(scoreP >= BarsUnder && temperature[i] >= avgTemperatureA[i] && temperature[i] < avgTemperatureB[i]) whichBuffer = 5;

               buffer5[i] = EMPTY_VALUE;
               buffer6[i] = EMPTY_VALUE;
               buffer7[i] = EMPTY_VALUE;
               buffer8[i] = EMPTY_VALUE;
               switch (whichBuffer)
               {
                  case 2: { buffer6[i]=temperature[i]; break; }
                  case 3: { buffer5[i]=temperature[i]; break; }
                  case 4: { buffer7[i]=temperature[i]; break; }
                  case 5: { buffer8[i]=temperature[i]; break; }
               }
         }
   }
   return(0);
}