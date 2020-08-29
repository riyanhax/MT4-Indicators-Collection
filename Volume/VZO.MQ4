//+------------------------------------------------------------------+
//|                                                          VZO.mq4 |
//|                                                      John Taylor |
//|                http://financialprogrammingservices.blogspot.com/ |
//|                                                                  |
//|                         Algorithm attributed to Waleed Aly Khalil|
//|   http://www.ifta.org/public/files/journal/d_ifta_journal_09.pdf |
//+------------------------------------------------------------------+
#property copyright "John Taylor."
#property link      "http://financialprogrammingservices.blogspot.com/"

#property  indicator_separate_window
#property  indicator_minimum -100
#property  indicator_maximum 100
#property  indicator_buffers 1
#property  indicator_width1  2
#property  indicator_color1  DodgerBlue

extern int VZOPeriod=14;

double VZOBuffer[];

int init() {
   string short_name="VZO("+VZOPeriod+")";
   IndicatorShortName(short_name);

   SetIndexBuffer(0,VZOBuffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,short_name);
   SetIndexDrawBegin(0,VZOPeriod+1);

   return(0);
}

int start() {
   double delta=2.0/(1.0+VZOPeriod);
   double TV=0.0,VP=0.0;
   
   for(int i=Bars-1;i>0;i--) {
      double R=Volume[i];
      if(Close[i]<Close[i+1]) R=-Volume[i];
      
      if(i==Bars-1) {
         VP=R;
         TV=Volume[i];
      }
      else {
         VP=delta*R+(1-delta)*VP;
         TV=delta*Volume[i]+(1-delta)*TV;
      }

      VZOBuffer[i]=100*VP/TV;
   }

   return(0);
}