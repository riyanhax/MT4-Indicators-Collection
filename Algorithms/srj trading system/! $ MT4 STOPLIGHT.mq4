
// THIS CODE WAS WRITTEN BY XARD777 AND EXTENSIVELY REVISED BY TZUMAN (CapeCoddah)
// FEEL FREE TO RAPE AND PILLAGE ANY OR ALL OF THIS CODE AS YOU SEE FIT
// FOR THOSE OF YOU THAT IMPROVE UPON THIS HERE CODE I ASK YOU ONE THING
// PLEASE POST A COPY UP ON THE FOREX FORUMS FOR YOUR FELLOW TRADERS


#property indicator_chart_window
#property indicator_buffers 7

#property indicator_color1 Magenta
#property indicator_width1 5
#property indicator_color2 Lime
#property indicator_width2 5

#property indicator_color4 Red
#property indicator_width4 4
#property indicator_color5 Yellow
#property indicator_width5 4

#property indicator_color7 White
#property indicator_width7 2
 
 
double buf1[], buf2[], buf3[];
int PeriodX1 = 45., ModeX1 = 3, PriceX1 = 5;

double buf4[], buf5[], buf6[];
int PeriodX3 =  9., ModeX3 = 3, PriceX3 = 5;

double buf7[];
int PeriodX2 =  2., ModeX2 = 3, PriceX2 = 5;

double LWMA2, LWMA9, LWMA45, RSI13;


#define RedLight -1
#define OverBoughtLight 0
#define OverSoldLight 1
#define GreenLight 2
#define OrangeLight 3
#define PowerFailure -999

color  PanelBgd1          = DimGray;
color  PanelBgd2          = C'40,50,60';

int    Corner=0;
int    Window=0;
int    addx               = 0;
int    addy               = 0;
 


int init()
  {
  
   IndicatorBuffers(7);
   
   SetIndexBuffer(0,buf1);
   SetIndexBuffer(1,buf2);
   SetIndexBuffer(2,buf3);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 159);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 159);
   SetIndexStyle(2, DRAW_NONE);
   
   SetIndexBuffer(3, buf4);
   SetIndexBuffer(4, buf5);
   SetIndexBuffer(5, buf6);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexStyle(5, DRAW_NONE);
   
   SetIndexBuffer(6, buf7);
   SetIndexStyle(6, DRAW_LINE);

   return(0);
  }



int deinit()
{
   deleteObjects();
   return(0);
}



int start()
  {
 
   int i,limit,counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   //STOPLIGHT MA & RSI CODE
     LWMA2=iMA(NULL,0, 2,0,3,5,0);
     LWMA9=iMA(NULL,0, 9,0,3,5,0);
    LWMA45=iMA(NULL,0,45,0,3,5,0);
     RSI13=iRSI(NULL,0,13,PRICE_CLOSE,0);
   
   for(i=0; i<limit; i++){
           
         buf7[i]=iMA(NULL,0,PeriodX2, 0, ModeX2, PriceX2, i); 
      }
    
   for (int X1 = Bars - 10; X1 >= 0; X1--) buf3[X1] = iMA(NULL, 0, PeriodX1, 0, ModeX1, PriceX1, X1);
   for (int X2 = Bars - 10; X2 >= 0; X2--) {
      buf1[X2] = buf3[X2]; buf2[X2] = buf3[X2];
      if (buf3[X2] > buf3[X2 + 1]) {
         buf1[X2] = EMPTY_VALUE; buf2[X2 + 1] = buf3[X2 + 1];
      } else {
         if (buf3[X2] < buf3[X2 + 1]) {
            buf2[X2] = EMPTY_VALUE; buf1[X2 + 1] = buf3[X2 + 1];
         }}} 
         
         
   for (int X3 = Bars - 10; X3 >= 0; X3--) buf6[X3] = iMA(NULL, 0, PeriodX3, 0, ModeX3, PriceX3, X3);
   for (int X4 = Bars - 10; X4 >= 0; X4--) {
      buf4[X4] = buf5[X4]; buf5[X4] = buf6[X4];
      if (buf6[X4] > buf6[X4 + 1]) {
         buf4[X4] = EMPTY_VALUE; buf5[X4 + 1] = buf6[X4 + 1];
      } else {
         if (buf6[X4] < buf6[X4 + 1]) {
            buf5[X4] = EMPTY_VALUE; buf4[X4 + 1] = buf6[X4 + 1];
         }}}          
  
  
      
   int LightBulb=Determine_StopLight();
   Show_TrafficLights(LightBulb);         
   return(0);
   }
  
   //TRAFFIC LIGHT CONDITIONS
   int Determine_StopLight()
   {

   if(!IsConnected())                                 return(PowerFailure);
   //GREENLIGHT = BUY ZONE
   if(LWMA2 > LWMA9 && RSI13 >= 50 && RSI13 < 70)     return(GreenLight);
  
   //ORANGELIGHT = WAIT ZONE
   if(LWMA2 > LWMA9 && RSI13 >= 50 && RSI13 < 70)     return(OrangeLight);
   if(LWMA2 < LWMA9 && RSI13 >= 50 && RSI13 < 70)     return(OrangeLight);
 
   //OverBoughtLIGHT = OB ZONE
   if(RSI13 >= 70 && RSI13 < 100)                     return(OverBoughtLight);
   
   //OverSoldLIGHT = OS ZONE
   if(RSI13 <= 30 && RSI13 >   0)                     return(OverSoldLight);
 
   //REDLIGHT = SELL ZONE
   if(LWMA2 < LWMA9 && RSI13 <= 50 && RSI13 > 30)     return(RedLight);
   
   //ORANGELIGHT = WAIT ZONE
   if(LWMA2 < LWMA9 && RSI13 <= 50 && RSI13 > 30)     return(OrangeLight);
   if(LWMA2 > LWMA9 && RSI13 <= 50 && RSI13 > 30)     return(OrangeLight);
        
   //POWERFAILURE 
   return(PowerFailure);
   }



int Create.traffic.light.system( string buffer, int buffer.x, int buffer.y ) {
   ObjectCreate( buffer, OBJ_LABEL,Window, 0, 0 );
   ObjectSet( buffer, OBJPROP_CORNER, Corner );
   ObjectSet( buffer, OBJPROP_XDISTANCE,buffer.x+addx);
   ObjectSet( buffer, OBJPROP_YDISTANCE,buffer.y+addy);
   ObjectSet( buffer, OBJPROP_BACK, false );
   }
   
void deleteObjects(){
   for(int i=0;   i<10;i++) ObjectDelete("tls000"+ i);
   for(    i=0;   i<10;i++) ObjectDelete("tls00" + i);
   GetLastError();
   }
double Calculate_Profits()
  {
  double PL,total;

  for (int i = OrdersTotal()-1 ; i >= 0; i--) 
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
         { 
         if(OrderSymbol() != Symbol()) continue;
         if(OrderType() == OP_BUY)  
            {
            PL = (OrderClosePrice()-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT)/10;
            total = total + PL;
            }
         else if(OrderType() == OP_SELL)  
            {
            PL = (OrderOpenPrice()-OrderClosePrice())/MarketInfo(OrderSymbol(),MODE_POINT)/10;
            total = total + PL;
            }    
         } 
   return(total);
  } 
  
  
void  Show_TrafficLights(int TrafficLight)
    { 
 static int counter; 
         ObjectDelete("tls0010");         ObjectDelete("tls0011");
         double Pips=Calculate_Profits();
      if(Pips !=0)
         {
         color cPips=DeepSkyBlue;
         if(Pips<0)  cPips=Orange;
         ObjectDelete("tls0010");         ObjectDelete("tls0011");
         Create.traffic.light.system("tls0010",0, 0);  ObjectSetText("tls0010", "gggg", 17, "Webdings", PanelBgd2);
         Create.traffic.light.system("tls0011",1,1 );  ObjectSetText("tls0011", "Pips:  " + DoubleToStr(Pips,0), 12, "Arial Black", cPips);
         }
      color cStopLights[3];
      
      switch(TrafficLight)
         {
      case GreenLight:        cStopLights[0]=Lime;          cStopLights[1]=PanelBgd2;    cStopLights[2]=PanelBgd2;      break;
      case OrangeLight:       cStopLights[0]=PanelBgd2;     cStopLights[1]=DarkOrange;   cStopLights[2]=PanelBgd2;      break;
      case RedLight:          cStopLights[0]=PanelBgd2;     cStopLights[1]=PanelBgd2;    cStopLights[2]=Red;            break;
      case OverBoughtLight:   cStopLights[0]=Gold;          cStopLights[1]=PanelBgd2;    cStopLights[2]=PanelBgd2;      break;
      case OverSoldLight:     cStopLights[0]=PanelBgd2;     cStopLights[1]=PanelBgd2;    cStopLights[2]=Gold;           break;
      case PowerFailure:      cStopLights[0]=PanelBgd2;     cStopLights[1]=PanelBgd2;    cStopLights[2]=PanelBgd2;      break;
      default:                cStopLights[0]=PanelBgd2;     cStopLights[1]=PanelBgd2;    cStopLights[2]=PanelBgd2;      break;          
         }
         
      Create.traffic.light.system("tls0001",2,22);  ObjectSetText("tls0001", "g", 21, "Webdings", PanelBgd1);
      Create.traffic.light.system("tls0002",2,50);  ObjectSetText("tls0002", "g", 21, "Webdings", PanelBgd1);
      Create.traffic.light.system("tls0003",2,78);  ObjectSetText("tls0003", "g", 21, "Webdings", PanelBgd1);
      
      Create.traffic.light.system("tls001",4,25);   ObjectSetText("tls001",  "n", 18, "Webdings", PanelBgd2);
      Create.traffic.light.system("tls002",4,53);   ObjectSetText("tls002",  "n", 18, "Webdings", PanelBgd2);
      Create.traffic.light.system("tls003",4,81);   ObjectSetText("tls003",  "n", 18, "Webdings", PanelBgd2);
     
      for(int i=0;i<3;i++)
      {
      Create.traffic.light.system("tls00" +(i+4),6, 25+i*28);  ObjectSetText("tls00" +(i+4), "n", 15, "Webdings", cStopLights[i]);
      }
        
   }
// ==================================
// LET THERE BE ORDER........ XARD777
// AND THERE WILL BE ORDER.....TZUMAN
// I AM UP 1800 PIPS........ISMAEL360
//--------------------------------------------Xard@hotmail.co.uk-----+
/*                                                                   
                              ud$$$**$$$$$$$bc.                          
                          u@**"        4$$$$$$$Nu                       
                        J                ""#$$$$$$r                     
                       @                       $$$$b                    
                     .F                        ^*3$$$                   
                    :% 4                         J$$$N                  
                    $  :F                       :$$$$$                  
                   4F  9                       J$$$$$$$                 
                   4$   k             4$$$$bed$$$$$$$$$                 
                   $$r  'F            $$$$$$$$$$$$$$$$$r                
                   $$$   b.           $$$$$$$$$$$$$$$$$N                
                   $$$$$k 3eeed$$b    XARD777."$$$$$$$$$                
    .@$**N.        $$$$$" $$$$$$F'L $$$$$$$$$$$  $$$$$$$                
    :$$L  'L       $$$$$ 4$$$$$$  * $$$$$$$$$$F  $$$$$$F         edNc   
   @$$$$N  ^k      $$$$$  3$$$$*%   $F4$$$$$$$   $$$$$"        d"  z$N  
   $$$$$$   ^k     '$$$"   #$$$F   .$  $$$$$c.u@$$$          J"  @$$$$r 
   $$$$$$$b   *u    ^$L            $$  $$$$$$$$$$$$u@       $$  d$$$$$$ 
    ^$$$$$$.    "NL   "N. z@*     $$$  $$$$$$$$$$$$$P      $P  d$$$$$$$ 
       ^"*$$$$b   '*L   9$E      4$$$  d$$$$$$$$$$$"     d*   J$$$$$r   
            ^$$$$u  '$.  $$$L     "#" d$$$$$$".@$$    .@$"  z$$$$*"     
              ^$$$$. ^$N.3$$$       4u$$$$$$$ 4$$$  u$*" z$$$"          
                '*$$$$$$$$ *$b      J$$$$$$$b u$$P $"  d$$P             
                   #$$$$$$ 4$ 3*$"$*$ $"$'c@@$$$$ .u@$$$P               
                     "$$$$  ""F~$ $uNr$$$^&J$$$$F $$$$#                 
                       "$$    "$$$bd$.TZUMAN$$$$F $$"                   
                         ?k         ?$$$$$$$$$$$F'*                     
                          9$$bL     z$$$$$$$$$$$F                       
                           $$$$    $$$$$$$$$$$$$                        
                            '#$$c  '$$$$$$$$$"                          
                             .@"#$$$$$$$$$$$$b                          
                           z*      $$$$$$$$$$$$N.                       
                         e"      z$$"  #$$$k  '*$$.                     
                     .u*      u@$P"      '#$$c   "$$c                   
              u@$*"""       d$$"            "$$$u  ^*$$b.               
            :$F           J$P"                ^$$$c   '"$$$$$$bL        
           d$$  ..      @$#                      #$$b         '#$       
           #ISMAEL#   4$$                          ^$$k         '$      
            "$$6""$b u$$                             '$    d$$$$$P      
              '$F $$$$$"                              ^b  ^$$$$b$       
               '$W$$$$"                                'b@$$$$"         
                                                        ^$$$*  
*/     


