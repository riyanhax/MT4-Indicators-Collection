

#property indicator_chart_window
extern string  Ichimoku_Kinko_Hyo   = " 9 , 26 , 52 ";
extern int     X_Shift              = 0;
extern int     Y_Shift              = 40;
extern int     corner               = 3;

       int scaleX=40,// space between columns
           scaleY=20,
           offsetX=35,
           offsetY=20,
           fontSize=15,
           
           // buy arrows
            symbolCodeBuy=217, 
           symbolCodeSell=218, 
           symbolCodeNoSignal=110,
            // trade activation symbols
           symbolActivationGreat=217, 
           symbolActivationOk=218, 
           symbolNoActivation=218; 
   
        bool SoundON=true;
 double alertTag;          
       color signalBuyColor=Blue,
             signalSellColor=Red,
             noSignalColor=Gold,
             // trade activation colours
             symbolActivationGreatColor=Aqua,
             symbolActivationOkColor=Orange,
             symbolNoActivationColor=Gold,
             
             textColor=White;            
            
 
int period[]={43200,10080,1440,240,60,30,15,5,1}; 
//string periodString[]={"M1","M5","M15","M30","H1","H4","D1","W1","MN1"},
//string periodString[]={"M1","M5","M15","M30","H1","H4","D1"},
string periodString[]={"MN","W1","D1","H4","H1","M30","M15","M5","M1"},

       
       pairStringName[]={""};

//////////////////////////////////////////////////////////////////////
//
// init()          
//
//////////////////////////////////////////////////////////////////////
int init()
{
   // count number of elements in the pairStringName[]
   int numberOfPairsToScan = ArraySize(pairStringName);
   int numberOfTimeFramesToScan = ArraySize(periodString);
  
   // uses 2 cycles, the first with counter x draws one by one each column from 
   // left to right. the second cycle draws symbols of each column from top downward. At
   // each iteration of the cycle will create a mark. These two cycles create 9 columns (9 periods)
   // 3 marks each (3 signal types)
   for(int x=0;x<numberOfPairsToScan;x++) // columns for 'numberOfPairsToScan' currency pairs
     for(int y=0;y<numberOfTimeFramesToScan;y++) // rows for numberOfTimeFramesToScan time frames deep
     //  for(int y=6;y>=0;y--)
      {
         ObjectCreate("signal"+x+y,OBJ_LABEL,0,0,0,0,0);
         // create the next mark, Note the mark name
         // is created "on the fly" and depends on the x & y counters
         ObjectSet("signal"+x+y,OBJPROP_CORNER,corner);
         
         ObjectSet("signal"+x+y,OBJPROP_XDISTANCE, + X_Shift + x*scaleX+offsetX);
         ObjectSet("signal"+x+y,OBJPROP_YDISTANCE, + Y_Shift + y*scaleY+20);
         ObjectSetText("signal"+x+y,CharToStr(symbolCodeNoSignal),
                       fontSize,"Wingdings",noSignalColor);
      }
  
  // put the pair names across the bottom of the chart  
  for(x=0;x<numberOfPairsToScan;x++)
  {
      //ObjectCreate("pairName"+x,OBJ_LABEL,0,0,0,0,0);   
      // èçìåíÿåì óãîë ïðèâÿçêè      
      ObjectSet("pairName"+x,OBJPROP_CORNER,corner);
     // ObjectSet("pairName"+x,OBJPROP_XDISTANCE,x*scaleX+offsetX);
     // ObjectSet("pairName"+x,OBJPROP_YDISTANCE,offsetY-10);
        ObjectSet("pairName"+x,OBJPROP_XDISTANCE,x*scaleX+offsetX);
      ObjectSet("pairName"+x,OBJPROP_YDISTANCE, + Y_Shift + offsetY+160);
      
       ObjectSetText("pairName"+x,pairStringName[x],8.5,"Arial",textColor);   

  }

    // put in the trade activation symbols across the bottom of the chart  
  for(x=0;x<numberOfPairsToScan;x++)
  {
      ObjectCreate("activationSymbol"+x,OBJ_LABEL,0,0,0,0,0);   
      // èçìåíÿåì óãîë ïðèâÿçêè      
      ObjectSet("activationSymbol"+x,OBJPROP_CORNER,corner);

      ObjectSet("activationSymbol"+x,OBJPROP_XDISTANCE, + X_Shift +  20);
      ObjectSet("activationSymbol"+x,OBJPROP_YDISTANCE, + Y_Shift +  200);
      ObjectSetText("activationSymbol"+x,CharToStr(symbolNoActivation),24,"Wingdings",symbolNoActivationColor);   
 
  }

  // put in the time frame values into the chart
  for(y=0;y<numberOfTimeFramesToScan;y++)
  {
      ObjectCreate("periodValue"+y,OBJ_LABEL,0,0,0,0,0);   
      // èçìåíÿåì óãîë ïðèâÿçêè      
      ObjectSet("periodValue"+y,OBJPROP_CORNER,corner);
      ObjectSet("periodValue"+y,OBJPROP_XDISTANCE, + X_Shift + offsetX-25);
      ObjectSet("periodValue"+y,OBJPROP_YDISTANCE, + Y_Shift + y*(scaleY)+offsetY+8);
      ObjectSetText("periodValue"+y,periodString[y],8,"Arial",textColor);      
  }
  
 // put my indicator title at the top
   
      
  return(0);
}
////////////////////////////////////////////////////////////////////////////
int start()
{

// count the number of elements in array pairStringName
int numberOfPairsToScan = ArraySize(pairStringName);
int numberOfTimeFramesToScan = ArraySize(periodString);
   
//Print ("count=",count);
for (int i=0;i<numberOfPairsToScan;i++){

      // this counts to see if all time frames M1 through to D1 are all in alignment
      int kumoLongSetupCounter=0;
      int kumoShortSetupCounter=0;
      
      // PUTTING IN VALUES FOR PRICE RELATIVE TO KUMO
       for(int x=0;x<numberOfTimeFramesToScan;x++)
     
         
         {

            if(
            (iClose(Symbol (),period[x],0)>iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANA,0))&&
            (iClose(Symbol (),period[x],0)>iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANB,0))
            ){
               ObjectSetText("signal"+i+x,CharToStr(symbolCodeBuy),fontSize,"Wingdings",signalBuyColor);
               
                  if (x<6){ // don't include the M1 timeframe in the setup count
                  kumoLongSetupCounter++;
                  kumoShortSetupCounter--;
                  }
               }

            else if (
            (iClose(Symbol (),period[x],0)<iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANA,0))&&
            (iClose(Symbol (),period[x],0)<iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANB,0))
            ){
               ObjectSetText("signal"+i+x,CharToStr(symbolCodeSell),fontSize,"Wingdings",signalSellColor); 
               
                  if (x<6){ // don't include the M1 timeframe in the setup count
                  kumoLongSetupCounter--;
                  kumoShortSetupCounter++;
                  }
                 
            } else if (
            ((iClose(Symbol (),period[x],0)>iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANA,0))&&
            (iClose(Symbol (),period[x],0)<iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANB,0)))||
             ((iClose(Symbol (),period[x],0)<iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANA,0))&&
            (iClose(Symbol (),period[x],0)>iIchimoku(Symbol (),period[x],9,26,52,MODE_SENKOUSPANB,0)))
            ){
            ObjectSetText("signal"+i+x,CharToStr(symbolCodeNoSignal),fontSize,"Wingdings",noSignalColor);   
               
               if (x<4){ // don't include the M1 timeframe in the setup count
               kumoLongSetupCounter--;
               kumoShortSetupCounter--;
               }
         }
         
         string thisCurrencyPair=Symbol (); // get this particular currency pair to pass to function to detect Tenkan Kijun crossover
         //Print ("currency "+thisCurrencyPair);
         
          // if all timeframes are long with respect to the kumo
       // if all timeframes are long with respect to the kumo
      if (kumoShortSetupCounter>4){
            ObjectSetText("activationSymbol"+i,CharToStr(symbolActivationGreat),24,"Wingdings",symbolActivationGreatColor); 
          //  if (TenkanKijuncross(thisCurrencyPair)=="CrossDown"){ PlaySound("alertchinese1.wav");//Alert("Tenkan Kijun Sen Down Cross on " + Symbol() );}
      }
      
       if (kumoLongSetupCounter>4){
            ObjectSetText("activationSymbol"+i,CharToStr(symbolActivationGreat),24,"Wingdings",symbolActivationGreatColor);
         //   if (TenkanKijuncross(thisCurrencyPair)=="CrossUp"){ PlaySound("alertchinese1.wav");//Alert("Tenkan Kijun Sen Up Cross on " + Symbol() );}
       } 
       
            
   if ((kumoShortSetupCounter<4)&&(kumoLongSetupCounter<4)){ObjectSetText("activationSymbol"+i,CharToStr(symbolNoActivation),24,"Wingdings",symbolNoActivationColor);}} // end for(int x=0;x<7;x++)
      
     
   
} // end for (int i=0;i<numberOfPairsToScan;i++){

}

//////////////////////////////////////////////////////////////////////
//
//  deinit()                       
//
//////////////////////////////////////////////////////////////////////
int deinit()
{
   ObjectDelete ("activationSymbol0");
   ObjectDelete ("periodValue0");
   ObjectDelete ("periodValue1");
   ObjectDelete ("periodValue2");
   ObjectDelete ("periodValue3");
   ObjectDelete ("periodValue4");
   ObjectDelete ("periodValue5");
   ObjectDelete ("periodValue6");
   ObjectDelete ("periodValue7");
   ObjectDelete ("periodValue8");
   ObjectDelete ("signal00");
   ObjectDelete ("signal01");
   ObjectDelete ("signal02");
   ObjectDelete ("signal03");
   ObjectDelete ("signal04");
   ObjectDelete ("signal05");
   ObjectDelete ("signal06");
   ObjectDelete ("signal07");
   ObjectDelete ("signal08");
   
/*   
   // Add An Alert When 1H , 30M , 15M Become Trended Together :
   // Price Above Kuno Spans :
   
   double SpanA_15M = iIchimoku ( Symbol() , PERIOD_M15 , 9 , 26 , 52 , MODE_SENKOUSPANA , 1 );
   double SpanB_15M = iIchimoku ( Symbol() , PERIOD_M15 , 9 , 26 , 52 , MODE_SENKOUSPANB , 1 );
   //double Close_15M = iClose ( Symbol() , PERIOD_M15 , 1 );
   
   double SpanA_30M = iIchimoku ( Symbol() , PERIOD_M30 , 9 , 26 , 52 , MODE_SENKOUSPANA , 1 );
   double SpanB_30M = iIchimoku ( Symbol() , PERIOD_M30 , 9 , 26 , 52 , MODE_SENKOUSPANB , 1 );
   //double Close_30M = iClose ( Symbol() , PERIOD_M30 , 1 );
   
   double SpanA_H1 = iIchimoku ( Symbol() , PERIOD_H1  , 9 , 26 , 52 , MODE_SENKOUSPANA , 1 );
   double SpanB_H1 = iIchimoku ( Symbol() , PERIOD_H1  , 9 , 26 , 52 , MODE_SENKOUSPANB , 1 );
   //double Close_H1 = iClose ( Symbol() , PERIOD_H1 , 1 );
   
   if 
   (
      Bid  >= SpanA_15M && Bid >= SpanB_15M
   && Bid  >= SpanA_30M && Bid >= SpanB_30M
   && Bid  >= SpanA_H1  && Bid >= SpanB_H1
   )
   bool Bullish_Trend = TRUE;
   

   if 
   (
      Bid <= SpanA_15M && Bid <= SpanB_15M
   && Bid <= SpanA_30M && Bid <= SpanB_30M
   && Bid <= SpanA_H1  && Bid <= SpanB_H1
   )
   bool Bearish_Trend = TRUE;

                     static datetime lastAlertTime, BarTimeLastAlert;
                     int T;
                     
                     if(  T<1 )
                       {
                        if( iTime( NULL, 0, T )>BarTimeLastAlert )
                          {
                           BarTimeLastAlert=Time[0];
                           if( Bullish_Trend == TRUE )
                             {
                              Alert( Symbol() + " Price Now Above 15M , 30M and H1 KumoSpans " );
                             }
                          }
                       }


                     if(  T<1 )
                       {
                        if( iTime( NULL, 0, T )>BarTimeLastAlert )
                          {
                           BarTimeLastAlert=Time[0];
                           if( Bearish_Trend == TRUE )
                             {
                              Alert( Symbol() + " Price Now Below 15M , 30M and H1 KumoSpans " );
                             }
                          }
                       }   */


   return(0);
}





