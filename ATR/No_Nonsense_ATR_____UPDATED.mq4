//+------------------------------------------------------------------+
//|                                              No Nonsense ATR.mq4 |
//|          Developed by rpsreal - PORTUGAL - 5/2019 - Version 3.20 |
//|                                        V3.20     PORTUGAL 5/2019 |
//+------------------------------------------------------------------+
#property strict
#property version   "3.20"
#property link      "https://nononsenseforex.com/"
#property copyright "Developed by rpsreal - PORTUGAL - 5/2019 - Version 3.20"
#property description "The ATR Indicator for the NNF Traders"

#property indicator_separate_window    // Indicator is drawn in the main window
#property indicator_buffers 2          // Number of buffers
#property indicator_color1 Red         // SL Color
#property indicator_color2 DeepSkyBlue // TP Color

//---- input parameters
input int        ATR_TP_PERIOD        = 14;         // TP ATR PERIOD       
input double     ATR_TP_MULTIPLIER    = 1;          // TP MULTIPLIER            
input int        ATR_SL_PERIOD        = 14;         // SL ATR PERIOD  
input double     ATR_SL_MULTIPLIER    = 1.5;        // SL MULTIPLIER 
input char       ATR_SHIFT            = 0;          // ATR SHIFT
input int        ATR_digits           = 0;          // Nº OF DIGITS TO THE RIGHT OF a DECIMAL POINT
input bool       SHOW_CORNER_TEXT     = True;       // SHOW CORNER TEXT?
input bool       HOLD_TEXT            = True;       // SHOW HISTORY VALUES IN CORNER TEXT?
input char       text_corner          = 0;          // TEXT CORNER 0-UL 1-UR 2-LL 3-LR
input int        text_size            = 12;         // FONT SIZE
input color      text_color           = Gold;       // TEXT COLOR
input bool       CLICK_TO_PAUSE       = True;       // MOUSE CLICK TO HOLD TEXT?
input bool       SHOW_LINES_ON_CLICK  = True;       // SHOW TP/SL LINES ON CLICK?
input int        tp_line_size         = 0;          // TP LINE SIZE
input color      tp_line_color        = DeepSkyBlue;// TP LINE COLOR
input int        sl_line_size         = 0;          // SL LINE SIZE
input color      sl_line_color        = Red;        // SL LINE COLOR
input bool       SHOW_HISTORY         = False;      // SHOW HISTORY?
input bool       histogram_mode       = True;       // HISTOGRAM MODE?
input int        n_of_bars            = 500;        // N OF HISTORY BARS



double NNF_SL[],NNF_TP[];
char user_mouseclick=0;
int barstocursor=0;
double SL, TP;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
   SetIndexBuffer(0,NNF_SL);         // Assigning an array to a buffer
   SetIndexLabel(0,"SL");
   if(histogram_mode==True){
      SetIndexStyle (0,DRAW_HISTOGRAM,STYLE_SOLID,2);// Line style
   }else{
      SetIndexStyle (0,DRAW_LINE,STYLE_SOLID,1);// Line style
   }
   SetIndexBuffer(1,NNF_TP);         // Assigning an array to a buffer
   SetIndexLabel(1,"TP");
   if(histogram_mode==True){
      SetIndexStyle (1,DRAW_HISTOGRAM,STYLE_SOLID,2);// Line style
   }else{
      SetIndexStyle (1,DRAW_LINE,STYLE_SOLID,1);// Line style
   }
   
   if(SHOW_CORNER_TEXT==True){
      ObjectCreate("NO_NONSENSE_ATR", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("NO_NONSENSE_ATR"," No Nonsense ATR",text_size, "Verdana", text_color);
      ObjectSet("NO_NONSENSE_ATR", OBJPROP_CORNER, text_corner);
      ObjectSet("NO_NONSENSE_ATR", OBJPROP_XDISTANCE, 0);
      ObjectSet("NO_NONSENSE_ATR", OBJPROP_YDISTANCE, 20);
      ObjectCreate("NO_NONSENSE_ATR_FIXED", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("NO_NONSENSE_ATR_FIXED","",text_size, "Verdana", text_color);
      ObjectSet("NO_NONSENSE_ATR_FIXED", OBJPROP_CORNER, text_corner);
      ObjectSet("NO_NONSENSE_ATR_FIXED", OBJPROP_XDISTANCE, 10);
      ObjectSet("NO_NONSENSE_ATR_FIXED", OBJPROP_YDISTANCE, 40);
   }
   
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1); // enable CHART_EVENT_MOUSE_MOVE messages
   
   return(INIT_SUCCEEDED);
}
 
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){
   ObjectDelete("NO_NONSENSE_ATR"); // apagar objetos
   ObjectDelete("NO_NONSENSE_ATR_FIXED");
   ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE");
   ObjectDelete("NO_NONSENSE_ATR_TP_LINE_BUY");
   ObjectDelete("NO_NONSENSE_ATR_TP_TEXT_BUY");
   ObjectDelete("NO_NONSENSE_ATR_TP_LINE_SELL");
   ObjectDelete("NO_NONSENSE_ATR_TP_TEXT_SELL");
   
   ObjectDelete("NO_NONSENSE_ATR_SL_LINE_BUY");
   ObjectDelete("NO_NONSENSE_ATR_SL_TEXT_BUY");
   ObjectDelete("NO_NONSENSE_ATR_SL_LINE_SELL");
   ObjectDelete("NO_NONSENSE_ATR_SL_TEXT_SELL");
   return(0);
}
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{

   if(SHOW_CORNER_TEXT==True && user_mouseclick==0 && barstocursor==0){
      string text;
      
      TP=((iATR(NULL,0,ATR_TP_PERIOD,ATR_SHIFT)/Point)/10)*ATR_TP_MULTIPLIER;
      SL=((iATR(NULL,0,ATR_SL_PERIOD,ATR_SHIFT)/Point)/10)*ATR_SL_MULTIPLIER;
       
      text=StringConcatenate("\n ATR = ", NormalizeDouble(SL,ATR_digits), " pips     TP = ",  NormalizeDouble(TP,ATR_digits), " pips");  
      ObjectSetText("NO_NONSENSE_ATR",text,text_size, "Verdana", text_color);
   }  
   
   if(SHOW_HISTORY==True){
      int i, Counted_bars;                // Number of counted bars
      Counted_bars=IndicatorCounted();    // Number of counted bars
      i=n_of_bars-Counted_bars-1;         // Index of the first uncounted
      while(i>=0){                        // Loop for uncounted bars
         NNF_TP[i]=NormalizeDouble(((iATR(NULL,0,ATR_TP_PERIOD,i+ATR_SHIFT)/Point)/10)*ATR_TP_MULTIPLIER,ATR_digits);             // Value of 0 buffer on i bar
         NNF_SL[i]=NormalizeDouble(((iATR(NULL,0,ATR_SL_PERIOD,i+ATR_SHIFT)/Point)/10)*ATR_SL_MULTIPLIER,ATR_digits);                 // Value of 1st buffer on i bar
         i--;                             // Calculating index of the next bar
      }
   }

   return(rates_total); //--- return value of prev_calculated for next call
  }
  
  
  
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){
   if(id==CHARTEVENT_MOUSE_MOVE && HOLD_TEXT==true && user_mouseclick==0){
      
      //--- Prepare variables
      int      x     =(int)lparam;
      int      y     =(int)dparam;
      datetime dt    =0;
      double   price =0;
      int      window=0;
      if(ChartXYToTimePrice(0,x,y,window,dt,price)){
         //PrintFormat("Window=%d X=%d  Y=%d  =>  Time=%s  Price=%G",window,x,y,TimeToString(dt),price);
         
         barstocursor=Bars(NULL, 0, dt, iTime(NULL, 0, 0))-1;
         //Print(barstocursor);
         
         if(SHOW_CORNER_TEXT==True){
            string text;
             
            TP=((iATR(NULL,0,ATR_TP_PERIOD,ATR_SHIFT+barstocursor)/Point)/10)*ATR_TP_MULTIPLIER;
            SL=((iATR(NULL,0,ATR_SL_PERIOD,ATR_SHIFT+barstocursor)/Point)/10)*ATR_SL_MULTIPLIER;
             
            text=StringConcatenate("\n SL = ", NormalizeDouble(SL,ATR_digits), " pips     TP = ",  NormalizeDouble(TP,ATR_digits), " pips");  
            ObjectSetText("NO_NONSENSE_ATR",text,text_size, "Verdana", text_color);
         }  
      //}else{
      //   Print("ChartXYToTimePrice return error code: ",GetLastError());
      }
   }
   if(id==CHARTEVENT_CLICK && CLICK_TO_PAUSE==True){
      if(user_mouseclick==0){
         user_mouseclick=1;
         ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED --",text_size, "Verdana", text_color);
         
         if(SHOW_LINES_ON_CLICK==True && CLICK_TO_PAUSE==True){// -- desenhar linhas
         
            ObjectCreate("NO_NONSENSE_ATR_ORDER_LINE", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor], Time[barstocursor], Close[barstocursor]);
            ObjectSet("NO_NONSENSE_ATR_ORDER_LINE", OBJPROP_WIDTH, 0);
            ObjectSet("NO_NONSENSE_ATR_ORDER_LINE", OBJPROP_COLOR, text_color);
            ObjectSet("NO_NONSENSE_ATR_ORDER_LINE", OBJPROP_RAY_RIGHT, 0);
            
            ObjectCreate("NO_NONSENSE_ATR_TP_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + TP * 10 * Point, Time[barstocursor], Close[barstocursor]+ TP *10 * Point);
            ObjectCreate("NO_NONSENSE_ATR_SL_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - SL * 10 * Point, Time[barstocursor], Close[barstocursor]- SL *10 * Point);
               
            ObjectCreate("NO_NONSENSE_ATR_TP_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - TP * 10 * Point, Time[barstocursor], Close[barstocursor]- TP *10 * Point);
            ObjectCreate("NO_NONSENSE_ATR_SL_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + SL * 10 * Point, Time[barstocursor], Close[barstocursor]+ SL *10 * Point);

            
            ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_WIDTH, tp_line_size);
            ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_COLOR, tp_line_color);
            ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_RAY_RIGHT, 1);
            ObjectCreate("NO_NONSENSE_ATR_TP_TEXT_BUY", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] + TP * 10 * Point);
            ObjectSetText("NO_NONSENSE_ATR_TP_TEXT_BUY","  BUY TP",10, "Verdana", tp_line_color);
            
            ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_WIDTH, tp_line_size);
            ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_COLOR, tp_line_color);
            ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_RAY_RIGHT, 1);
            ObjectCreate("NO_NONSENSE_ATR_TP_TEXT_SELL", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] - TP * 10 * Point);
            ObjectSetText("NO_NONSENSE_ATR_TP_TEXT_SELL","  SELL TP",10, "Verdana", tp_line_color);

            
            ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_WIDTH, sl_line_size);
            ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_COLOR, sl_line_color);
            ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_RAY_RIGHT, 1);
            ObjectCreate("NO_NONSENSE_ATR_SL_TEXT_BUY", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] - SL * 10 * Point);
            ObjectSetText("NO_NONSENSE_ATR_SL_TEXT_BUY","  BUY SL",10, "Verdana", sl_line_color);
            
            ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_WIDTH, sl_line_size);
            ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_COLOR, sl_line_color);
            ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_RAY_RIGHT, 1);
            ObjectCreate("NO_NONSENSE_ATR_SL_TEXT_SELL", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] + SL * 10 * Point);
            ObjectSetText("NO_NONSENSE_ATR_SL_TEXT_SELL","  SELL SL",10, "Verdana", sl_line_color);
            
         }
         
      }else{
         user_mouseclick=0;
         ObjectSetText("NO_NONSENSE_ATR_FIXED","",text_size, "Verdana", text_color);
         
         if(SHOW_LINES_ON_CLICK==True && CLICK_TO_PAUSE==True){   // -- apagar linhas
            ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE");
         
            ObjectDelete("NO_NONSENSE_ATR_TP_LINE_BUY");
            ObjectDelete("NO_NONSENSE_ATR_TP_TEXT_BUY");
            ObjectDelete("NO_NONSENSE_ATR_TP_LINE_SELL");
            ObjectDelete("NO_NONSENSE_ATR_TP_TEXT_SELL");
            
            ObjectDelete("NO_NONSENSE_ATR_SL_LINE_BUY");
            ObjectDelete("NO_NONSENSE_ATR_SL_TEXT_BUY");
            ObjectDelete("NO_NONSENSE_ATR_SL_LINE_SELL");
            ObjectDelete("NO_NONSENSE_ATR_SL_TEXT_SELL");
         }
         
      }
   }
   
   
}
//+------------------------------------------------------------------+
