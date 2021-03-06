
//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_label1  "VWAO strong up"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLimeGreen
#property indicator_width1  3

#property indicator_label2  "VWAO weak up"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrMediumSeaGreen
#property indicator_width2  3

#property indicator_label3  "VWAO strong down"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrOrange
#property indicator_width3  3

#property indicator_label4  "VWAO weak down"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrOrangeRed
#property indicator_width4  3
#property strict



double aohuu[],aohud[],aohdd[],aohdu[],val[],valc[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
    IndicatorBuffers(6);
    SetIndexBuffer(0, aohuu,INDICATOR_DATA); 
    SetIndexBuffer(1, aohud,INDICATOR_DATA); 
    SetIndexBuffer(2, aohdd,INDICATOR_DATA);
    SetIndexBuffer(3, aohdu,INDICATOR_DATA);
    SetIndexBuffer(4, val,  INDICATOR_DATA);
    SetIndexBuffer(5, valc, INDICATOR_CALCULATIONS);
 
    IndicatorSetString(INDICATOR_SHORTNAME,"Volume weighted AO");
return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit=fmin(rates_total-prev_calculated+1,rates_total-1); 

   //
   //
   //
   //
   //
   
   for(int i=limit; i>=0; i--)
   {
      double _price  = (high[i]+low[i])*0.5;
      val[i]  = iVwma(_price,tick_volume[i],5,rates_total-i-1,rates_total,0)-iVwma(_price,tick_volume[i],34,rates_total-i-1,rates_total,1);
      valc[i] =  (i<rates_total-1) ? (val[i]>0) ? (val[i]>val[i+1]) ? 0 : 1 : (val[i]<val[i+1]) ? 2 : 3 : 0;
      aohuu[i] = (valc[i] == 0) ? val[i] : EMPTY_VALUE;
      aohud[i] = (valc[i] == 1) ? val[i] : EMPTY_VALUE;
      aohdd[i] = (valc[i] == 2) ? val[i] : EMPTY_VALUE;
      aohdu[i] = (valc[i] == 3) ? val[i] : EMPTY_VALUE;  
   }
return(rates_total);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iVwma(double price, double volume, int period, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 2
      struct sVwmaArrayStruct
         {
            double price;
            double volume;
            double sump;
            double sumv;
         };
      static sVwmaArrayStruct m_array[][_functionInstances];
      static int m_arraySize=0;
             if (m_arraySize<bars)
             {
                 int _res = ArrayResize(m_array,bars+500);
                 if (_res<=bars) return(0);
                     m_arraySize = _res;
             }

      //
      //---
      //
      
      if (volume==0) volume=1;
      m_array[i][¤].price =volume*price;
      m_array[i][¤].volume=volume;
      if (i>period)
            {
               m_array[i][¤].sump = m_array[i-1][¤].sump+m_array[i][¤].price-m_array[i-period][¤].price;
               m_array[i][¤].sumv = m_array[i-1][¤].sumv+volume             -m_array[i-period][¤].volume;
            }              
      else  {  m_array[i][¤].sump = m_array[i][¤].price; 
               m_array[i][¤].sumv = m_array[i][¤].volume; 
                  for(int k=1; k<period && i>=k; k++) 
                  {
                     m_array[i][¤].sump += m_array[i-k][¤].price;
                     m_array[i][¤].sumv += m_array[i-k][¤].volume; 
                  }         
            }                  
      return (m_array[i][¤].sump/m_array[i][¤].sumv);

   //
   //---
   //
            
   #undef ¤ #undef _functionInstances
}