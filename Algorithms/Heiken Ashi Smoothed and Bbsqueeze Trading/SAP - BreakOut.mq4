
//+------------------------------------------------------------------+
//|                                               SAP - BreakOut.mq4 |
//|                                                                  |
//| This system (SAP System Basic I) is still under development,     |
//| there will be SAP Basic II, SAP Basic III and SAP Advance.       |
//| All systems are for sale but you can pay as much as              |
//| you feel like it or download it for free.                        |
//| If you find "SAP System Basic I" is useful for your trading,     |
//| care to donate to one of my accounts below.                      |
//| So that I can continue to develop this system.                   |                      
//|                                                                  |
//| 1. Liberty Reserve                                               |
//|    account U4821741 - Adhi Nugroho                               |
//| 2. C-Gold                                                        |
//|    account 38058 - Adhi Nugroho                                  | 
//| 3. Standard Chartered Bank Indonesia - SCB Semarang              |
//|    acc : 02105169524 - Adhi Nugroho                              |
//|    local : bisa lewat atm / internet banking , any bank          |
//|    international :                                               |
//|    swift - SCBLIDJX ; iban - AE950440002602105169524             |
//|------------------------------------------------------------------|    
//| Kalau system SAP bermanfaat, silahkan membayar selayaknya        |
//| ke salah satu rekening di atas atau menggunakannya secara gratis.|
//|                                                                  |            
//| Terima kasih . May the pips be with you .                        |
//| email : odessa.xyz.2005@gmail.com                                |
//|                                                                  |
//| (Special thank you to the original creator of this indicator)    |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2

extern    string  S1="";
extern    int     lookback=3; 
extern    string  S2=""; 
extern    int     TrendEMAPeriod=1; 


extern    string  S3="Alarm Settings: Default M30 timeframe."; 
extern    bool    EnableAlerts=false;
extern    bool    EnableBreakOutVoice=false; 
extern    bool    EnableTrendChangeVoice=false; 
extern    string  S3a="Alarms at this pip distance beyond line"; 
extern    int     OutsideBoundry=10; 
extern    string  DefaultSoundFile="alert.wav"; 
extern    string  S3b="Lines too far apart don't alarm";
extern    int     MaximumSeparationToAlarm=80; // lines too far apart will not alarm at breakout 
extern    string  S3c="Must jump more than this to alarm.";
extern    int     MinimumSeparationAtJump=100; // min size of line separation to give trend change alarm at jump
extern   color    LineColor=DarkSlateGray; 
extern   int      LineSize=0; 

double  HighLine[];
double  LowLine[];
double  stochastic[]; 

bool    SoundHasFired=true; 

int init()
{
    IndicatorBuffers(3);
    
    SetIndexBuffer(0, HighLine);
    SetIndexStyle(0,DRAW_LINE, STYLE_SOLID, 1, LineColor ) ;
    SetIndexBuffer(1, LowLine);
    SetIndexStyle(1,DRAW_LINE, STYLE_SOLID, 1, LineColor ) ;
    SetIndexBuffer(2, stochastic);
    SetIndexStyle(2,DRAW_NONE ) ;
    
    IndicatorShortName("SAP - BreakOut"); 
    SAPSystem();
    return(0);
}


int deinit()
{
   return(0);
}


int start()
{
   int    buysell;  
   int    trendchange;

   
   int    counted_bars=IndicatorCounted();

   int limit = Bars-counted_bars;

   if ( limit < 0 ) limit = 0; 

   SetIndexBuffer(0, HighLine);
   SetIndexStyle(0,DRAW_LINE, STYLE_SOLID, LineSize, LineColor ) ;
   SetIndexBuffer(1, LowLine);
   SetIndexStyle(1,DRAW_LINE, STYLE_SOLID, LineSize, LineColor ) ;
   SetIndexBuffer(2, stochastic);
   SetIndexStyle(2,DRAW_NONE ) ;
    
   for ( int i=limit; i>=0; i-- )
   {
      
      double diff =  iMA(NULL, 0, TrendEMAPeriod, 0, MODE_SMMA, PRICE_CLOSE, i)  
                   - iMA(NULL, 0, TrendEMAPeriod, 0, MODE_SMMA, PRICE_OPEN, i);
                   
      double diff2 =  iMA(NULL, 0, TrendEMAPeriod, 0, MODE_SMMA, PRICE_CLOSE, i+1)  
                   - iMA(NULL, 0, TrendEMAPeriod, 0, MODE_SMMA, PRICE_OPEN, i+1);
      
      
      if ( diff >= 0.0 && diff2 < 0.0  ) 
      {
         int lo = ArrayMinimum(Low,lookback,i+1); 
         LowLine[i] = Low[lo]; 
         HighLine[i] = HighLine[i+1]; 
      }
      else if ( diff <= 0.0  && diff2 > 0.0 )
      {
         int hi = ArrayMaximum(High,lookback,i+1); 
         HighLine[i] = High[hi];
         LowLine[i] = LowLine[i+1];  
      }
      else
      {
         HighLine[i] = HighLine[i+1]; 
         LowLine[i] = LowLine[i+1]; 
      }
      
      bool newbar=false; 
      buysell = 0; 
      trendchange = 0;
     // if ( i == 0 ) Comment("Boo"); 
      
      if ( i== 0  )   // should only occur during the last bar
      {
         if ( NewBar() )
         {
            SoundHasFired = false; 
            newbar = true; 
         }
         
         if (     ( newbar && Open[i]    > HighLine[i+1]     // at new bar after a bar has closed outside for first time
              &&    Close[i+1] >= HighLine[i+1]
              &&    Open[i+1]  <= HighLine[i+1] 
                  )
              ||
                  (
                   newbar &&   Close[i]   > HighLine[i] + OutsideBoundry*Point 
                  && Open[i]  <= HighLine[i] 
                  )
              
            )
         {  
            buysell = 1; 
         } 
         else if ( 
                     (  newbar &&  Open[i]   < LowLine[i+1]  
                     && Close[i+1] <= LowLine[i+1] 
                     && Open[i+1]  >= LowLine[i+1] 
                     )
                 ||
                     (
                        newbar &&   Close[i]   <  LowLine[i] - OutsideBoundry*Point 
                      && Open[i]   >= LowLine[i]  
                     )
                     
               
               
                
                 )
         {  buysell = -1; }    
         else
            buysell = 0;    

              


         if(  newbar &&   HighLine[i+1] >  HighLine[i+2]  // line has jumped
           &&   HighLine[i+1] >  LowLine[i+1] + MinimumSeparationAtJump*Point  // lines far apart
           )
         {
            trendchange = -1; 
         }
         else if ( newbar && LowLine[i+1] < LowLine[i+2]  
               &&  LowLine[i+1] <  HighLine[i+1] - MinimumSeparationAtJump*Point  // lines far apart
                  )
         {
            trendchange = 1; 
         }
         else
            trendchange = 0; 
      
      
          

      }  // end of i== 0 condition                                          
      
      
      datetime t; 
   
      if ( EnableAlerts  )
      {
         

         if ( buysell != 0 && ((HighLine[i] - LowLine[i])/Point <  MaximumSeparationToAlarm ) )
         {
            if ( EnableBreakOutVoice )
               PlaySound( SymbolToSound(1) ); 
            else
               PlaySound(DefaultSoundFile);
               
            SoundHasFired = true;
            
         }

         if ( trendchange != 0  ) 
         {
            if ( EnableTrendChangeVoice )
               PlaySound( SymbolToSound(2) ); 
            else
               PlaySound(DefaultSoundFile);
            
            SoundHasFired = true;
         }
          
      
         if ( buysell == 1 )
            Print("Breakout: Going UP - " + Symbol() ); 
         else if ( buysell == -1 )
            Print("Breakout: Going DOWN - " + Symbol() );
             
         if ( trendchange == 1 )
            Print("Breakout: Trend Going UP - " + Symbol() ); 
         else if ( trendchange == -1 )
            Print("Breakout: Trend Going DOWN - " + Symbol() ); 
      
      } // end Enable Alerts      
              
      
   } // end of i loop 
   
   return(0);
}



bool NewBar()
{
   static datetime lastbar = 0;
   datetime curbar = Time[0];
   if(lastbar!=curbar)
   {
      lastbar=curbar;
      return (true);
   }
   else
   {
      return(false);
   }
}  
//+------------------------------------------------------------------+
//|                                               SAP - BreakOut.mq4 |
//|                                                                  |
//| This system (SAP System Basic I) is still under development,     |
//| there will be SAP Basic II, SAP Basic III and SAP Advance.       |
//| All systems are for sale but you can pay as much as              |
//| you feel like it or download it for free.                        |
//| If you find "SAP System Basic I" is useful for your trading,     |
//| care to donate to one of my accounts below.                      |
//| So that I can continue to develop this system.                   |                      
//|                                                                  |
//| 1. Liberty Reserve                                               |
//|    account U4821741 - Adhi Nugroho                               |
//| 2. C-Gold                                                        |
//|    account 38058 - Adhi Nugroho                                  | 
//| 3. Standard Chartered Bank Indonesia - SCB Semarang              |
//|    acc : 02105169524 - Adhi Nugroho                              |
//|    local : bisa lewat atm / internet banking , any bank          |
//|    international :                                               |
//|    swift - SCBLIDJX ; iban - AE950440002602105169524             |
//|------------------------------------------------------------------|    
//| Kalau system SAP bermanfaat, silahkan membayar selayaknya        |
//| ke salah satu rekening di atas atau menggunakannya secara gratis.|
//|                                                                  |            
//| Terima kasih . May the pips be with you .                        |
//| email : odessa.xyz.2005@gmail.com                                |
//|                                                                  |
//| (Special thank you to the original creator of this indicator)    |
//+------------------------------------------------------------------+

string GetPeriodName()
{

    int peri = Period();
    string perstr; 
    switch(peri) {
        case PERIOD_M1: { perstr="M1"  ; break;}
        case PERIOD_M5: { perstr="M5"  ; break;}
        case PERIOD_M15: {perstr="M15" ; break;}
        case PERIOD_M30: {perstr="M30" ; break;}
        case PERIOD_H1:  {perstr="H1"  ; break;}
        case PERIOD_H4:  {perstr="H4"  ; break;}
        case PERIOD_D1:  {perstr="D1"  ; break;}
        case PERIOD_W1:  {perstr="W1"  ; break;}
        case PERIOD_MN1: {perstr="MN1";}
     } 
     return (perstr);
}

string SymbolToSound(int  soundtype )
{
    string  pairs[]={"EURUSD","GBPUSD","AUDUSD","USDCHF","USDJPY",
                     "EURAUD","GBPCHF","GBPJPY","EURJPY","USDCAD",
                     "USDCHF","CHFJPY","EURGBP","EURCAD"};

    string asound;
    int  k; 
    string  sym = Symbol();
    for ( int i=0; i<ArraySize(pairs); i++ )
    {
        if ( StringFind( sym , pairs[i] , 0) >= 0 )
            k= i; 
    }
    
    switch(k) {
       case 0:  asound="EUR_USD.wav"; break;
       case 1:  asound="GBP_USD.wav"; break;
       case 2: asound="AUD_USD.wav"; break;
       case 3: asound="USD_CHF.wav"; break;
       case 4:  asound="USD_JPY.wav"; break;
       case 5:  asound="EUR_AUD.wav"; break;
       case 6:  asound="GBP_CHF.wav"; break;
       case 7:  asound="GBP_JPY.wav"; break;
       case 8: asound="EUR_JPY.wav";  break;
       case 9: asound="USD_CAD.wav";  break;
       default: asound="alert.wav"; 
    }
    
    if ( soundtype == 1)
    {
      asound = "BreakOut_" + asound; 
    }
    else if ( soundtype == 2 )
    {
      asound = "TrendChange_" + asound;
    }
    else
    {
      asound = "alert.wav"; 
    }
      
    return(asound);
}





string PeriodToSound()
{
   string sound;
   switch(Period()) {
      case PERIOD_M1:  sound="M1.wav"  ; break;
      case PERIOD_M5:  sound="M5.wav"  ; break;
      case PERIOD_M15: sound="M15.wav" ; break;
      case PERIOD_M30: sound="M30.wav" ; break;
      case PERIOD_H1:  sound="H1.wav"  ; break;
      case PERIOD_H4:  sound="H4.wav"  ; break;
      case PERIOD_D1:  sound="DAILY.wav"  ; break;
      case PERIOD_W1:  sound="WEEKLY.wav"  ; break;
      case PERIOD_MN1: sound="MONTHLY.wav";
   }
   
   return ( sound); 
}
void SAPSystem() {
   ObjectCreate("SAP System Basic I", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("SAP System Basic I", "SAP System", 12, "Arial", White);
   ObjectSet("SAP System Basic I", OBJPROP_CORNER, 2);
   ObjectSet("SAP System Basic I", OBJPROP_XDISTANCE, 5);
   ObjectSet("SAP System Basic I", OBJPROP_YDISTANCE, 10);
}

//+------------------------------------------------------------------+
//|                                               SAP - BreakOut.mq4 |
//|                                                                  |
//| This system (SAP System Basic I) is still under development,     |
//| there will be SAP Basic II, SAP Basic III and SAP Advance.       |
//| All systems are for sale but you can pay as much as              |
//| you feel like it or download it for free.                        |
//| If you find "SAP System Basic I" is useful for your trading,     |
//| care to donate to one of my accounts below.                      |
//| So that I can continue to develop this system.                   |                      
//|                                                                  |
//| 1. Liberty Reserve                                               |
//|    account U4821741 - Adhi Nugroho                               |
//| 2. C-Gold                                                        |
//|    account 38058 - Adhi Nugroho                                  | 
//| 3. Standard Chartered Bank Indonesia - SCB Semarang              |
//|    acc : 02105169524 - Adhi Nugroho                              |
//|    local : bisa lewat atm / internet banking , any bank          |
//|    international :                                               |
//|    swift - SCBLIDJX ; iban - AE950440002602105169524             |
//|------------------------------------------------------------------|    
//| Kalau system SAP bermanfaat, silahkan membayar selayaknya        |
//| ke salah satu rekening di atas atau menggunakannya secara gratis.|
//|                                                                  |            
//| Terima kasih . May the pips be with you .                        |
//| email : odessa.xyz.2005@gmail.com                                |
//|                                                                  |
//| (Special thank you to the original creator of this indicator)    |
//+------------------------------------------------------------------+