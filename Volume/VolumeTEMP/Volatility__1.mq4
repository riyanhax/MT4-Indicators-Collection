//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  DodgerBlue
#property indicator_color2  Blue
#property indicator_color3  DodgerBlue
#property indicator_width1  6
#property indicator_width2  6
#property indicator_width3  6
#property indicator_minimum -1

//
//
//
//
//

extern string ForSymbol             = "";
extern int    VolatilityPeriodWeeks = 10;
extern int    ShiftHours            =  0;
extern int    BarsPerHour           =  6;
extern string IndicatorUniqueID     = "Volatility";
extern color  TextColor             = Silver;

//
//
//
//
//

double volatilityd[];
double volatilitym[];
double volatilityu[];
double dummy[];
string shortName;

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,volatilityu); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,volatilitym); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,volatilityd); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,dummy);       SetIndexStyle(3,DRAW_LINE,EMPTY,EMPTY,clrNONE); 
      BarsPerHour = MathMax(BarsPerHour,3);
         if (ForSymbol=="") ForSymbol=Symbol();
            shortName = IndicatorUniqueID+": for "+ForSymbol+" - "+VolatilityPeriodWeeks+" weeks data ";
      IndicatorShortName(shortName);
   return(0);
}


//
//
//
//
//

int deinit()
{
   string lookFor = IndicatorUniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i); if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   double pipMultiplier = 1; if (MarketInfo(ForSymbol,MODE_DIGITS)==3 || MarketInfo(ForSymbol,MODE_DIGITS)==5) pipMultiplier=10;
   double intraDay[24][4];
   double point = MarketInfo(ForSymbol,MODE_POINT);
      ArrayInitialize(intraDay,0);
      
      //
      //
      //
      //
      //
      
         if (iMA(ForSymbol,PERIOD_H1,1,0,0,0,0)==0) return(0);
         if (iMA(ForSymbol,PERIOD_W1,1,0,0,0,0)==0) return(0);
            datetime startTime = iTime(ForSymbol,PERIOD_W1,VolatilityPeriodWeeks);
                     int limit = iBarShift(ForSymbol,PERIOD_H1,startTime); 
                     if (limit>VolatilityPeriodWeeks*7*24+24) return(0);
                  
            //
            //
            //    leaving last (incomplete) hour out
            //
            //
                  
            for(int i=limit; i>0; i--)
            {
               int hour = TimeHour(iTime(ForSymbol,PERIOD_H1,i))+ShiftHours;
                  if (hour>24) hour -= 24;
                  if (hour< 0) hour += 24;
                  intraDay[hour][0] += MathMin(iOpen(ForSymbol,PERIOD_H1,i),iClose(ForSymbol,PERIOD_H1,i))-iLow(ForSymbol,PERIOD_H1,i);
                  intraDay[hour][1] += MathAbs(iOpen(ForSymbol,PERIOD_H1,i)-iClose(ForSymbol,PERIOD_H1,i));
                  intraDay[hour][2] += iHigh(ForSymbol,PERIOD_H1,i)-MathMax(iOpen(ForSymbol,PERIOD_H1,i),iClose(ForSymbol,PERIOD_H1,i));
                  intraDay[hour][3] += 1;
            }
      
      //
      //
      //
      //
      //
      
         double max = 0;
         for (i=0; i<24; i++)
         {
            intraDay[i][0] /= (point*pipMultiplier*MathMax(intraDay[i][3],1));
            intraDay[i][1] /= (point*pipMultiplier*MathMax(intraDay[i][3],1));
            intraDay[i][2] /= (point*pipMultiplier*MathMax(intraDay[i][3],1));
         
            //
            //
            //
            //
            //
            
            for (int k=0; k<BarsPerHour; k++)
            {
               volatilityd[(23-i)*(BarsPerHour+1)+k] = intraDay[i][0];
               volatilitym[(23-i)*(BarsPerHour+1)+k] = intraDay[i][1]+intraDay[i][0];
               volatilityu[(23-i)*(BarsPerHour+1)+k] = intraDay[i][2]+intraDay[i][1]+intraDay[i][0];
                                                 max = MathMax(max,volatilityu[(23-i)*(BarsPerHour+1)+k]);
                                                 dummy[i] = max*1.40;                                                 
            }
            volatilityd[(23-i)*(BarsPerHour+1)-1] = EMPTY_VALUE;
            volatilitym[(23-i)*(BarsPerHour+1)-1] = EMPTY_VALUE;
            volatilityu[(23-i)*(BarsPerHour+1)-1] = EMPTY_VALUE;
         }

         //
         //
         //
         //
         //
      
         int window = WindowFind(shortName);
         for (i=0; i<24; i++)
         {
            string name = shortName+i;
            datetime time = Time[(int)((24-i)*(BarsPerHour+1))]+(BarsPerHour*_Period*60)/2.0;
                  if (ObjectFind(name) == -1)
                      ObjectCreate(name,OBJ_TEXT,window,0,0);
                         ObjectSet(name,OBJPROP_TIME1,time);
                         ObjectSet(name,OBJPROP_PRICE1,max*1.22);
                         ObjectSet(name,OBJPROP_COLOR,TextColor);
                         ObjectSetText(name,"  "+i,9,"Courier new");
         }
         
         time = Time[12*(BarsPerHour+1)];
         name = shortName+i;
                     if (ObjectFind(name) == -1)
                         ObjectCreate(name,OBJ_TEXT,window,0,0);
                            ObjectSet(name,OBJPROP_TIME1,time);
                            ObjectSet(name,OBJPROP_PRICE1,max*1.35);
                            ObjectSet(name,OBJPROP_COLOR,TextColor);
                            ObjectSetText(name,ForSymbol+" maximal : "+DoubleToStr(max,2)+" pips",10,"Courier new");
      
      //
      //
      //
      //
      //
      
      SetIndexDrawBegin(0,Bars-24*(BarsPerHour+1)+1);
      SetIndexDrawBegin(1,Bars-24*(BarsPerHour+1)+1);
      SetIndexDrawBegin(2,Bars-24*(BarsPerHour+1)+1);
   return(0);
}