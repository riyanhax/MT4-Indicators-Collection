#property copyright "Personalized for HAMA PAD Approach - Copyright © 2009"
#property link      "http://www.forex-tsd.com"
// modified by keekkenen 2009-02-15
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 RoyalBlue
#property indicator_color3 Red
#property indicator_color4 RoyalBlue
#property indicator_color5 RoyalBlue
#property indicator_color6 Red

int MaPeriod = 20;
double buf0[], buf1[], buf2[], buf3[], buf4[], buf5[];
string Copyright = "";
//+------------------------------------------------------------------+
int init(){
   SetIndexStyle(0,DRAW_HISTOGRAM, 0, 3);
   SetIndexBuffer(0, buf0);
   SetIndexStyle(1,DRAW_HISTOGRAM, 0, 3);
   SetIndexBuffer(1, buf1);   
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(2, buf2);   
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 1);   
   SetIndexBuffer(3, buf3);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 0);
   SetIndexBuffer(4, buf4);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 0);
   SetIndexBuffer(5, buf5);

   setLabel(Copyright,Copyright,RoyalBlue,2,5,10,false,9,"Lucida Handwriting");
   return(0);
}
//+------------------------------------------------------------------+
int deinit(){ObjectDelete(Copyright);}
//+------------------------------------------------------------------+
int start()  {
   int ExtCountedBars = 0;
   double maOpen, maClose, maLow, maHigh;
   double haOpen, haHigh, haLow, haClose;
   if(Bars<=10) return(0);
   ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   int pos=Bars-ExtCountedBars-1;
   while(pos>=0){
      maOpen=iMA(NULL,0,MaPeriod,0,MODE_EMA,MODE_OPEN,pos);
      maClose=iMA(NULL,0,MaPeriod,0,MODE_EMA,MODE_CLOSE,pos);
      maLow=iMA(NULL,0,MaPeriod,0,MODE_EMA,MODE_LOW,pos);
      maHigh=iMA(NULL,0,MaPeriod,0,MODE_EMA,MODE_HIGH,pos);

      haOpen=(buf0[pos+1]+buf1[pos+1])/2.;
      haClose=(maOpen+maHigh+maLow+maClose)/4.;
      
      buf0[pos]=haOpen;
      buf1[pos]=haClose;
      
      if (buf0[pos] < buf1[pos]) {
         buf2[pos] = Low[pos];
         buf3[pos] = High[pos];
      }else{
         buf2[pos] = High[pos];
         buf3[pos] = Low[pos];
      }
 	   pos--;
   }
   for (int i = Bars-ExtCountedBars-1; i >= 0; i--) {
      buf4[i] = iMA(NULL, 0, MaPeriod, 0, MODE_EMA, PRICE_HIGH, i);
      buf5[i] = iMA(NULL, 0, MaPeriod, 0, MODE_EMA, PRICE_LOW, i);
   }
   return(0);
}
//+------------------------------------------------------------------+
void setLabel(string name, string text, color col, int corner,
            int x, int y, bool back = false, int fontsize = 9, 
            string fontname = "MS Sans Serif") {
   if (ObjectFind(name)==-1){
      // создание объекта, если не создавался или был удален
      ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(name, text, fontsize, fontname, col);
      ObjectSet(name, OBJPROP_CORNER, corner);
      ObjectSet(name, OBJPROP_BACK,back);
      ObjectSet(name, OBJPROP_XDISTANCE, x);
      ObjectSet(name, OBJPROP_YDISTANCE, y);          
   }else{
      ObjectSetText(name, text, fontsize, fontname, col);
      ObjectSet(name, OBJPROP_CORNER, corner);
      ObjectSet(name, OBJPROP_BACK,back);
      ObjectSet(name, OBJPROP_XDISTANCE, x);
      ObjectSet(name, OBJPROP_YDISTANCE, y); 
   }  
}

