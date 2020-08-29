
#property copyright "Sciurus 2015"

#property indicator_separate_window
#property indicator_buffers 16

extern int MaxDrawBars = 2000;
double close[],open[],high[],low[];

static double Up_Body_Blue[];
static double Dn_Body_Red[];
static double EqBodyBuffer[];
static double Bg_Body_White[];
static double Up_Wick_Blue[];
static double Dn_Wick_Red[];
static double EqShadowBuffer[];
static double Bg_Wick_White[];
static double Dn_Body_Blue[];
static double Up_Body_Red[];
static double Dn_Wick_Blue[];
static double Up_Wick_Red[];

double Curr_Bid;
double Prev_Bid;
double Curr_Ask;
double Prev_Ask;
double Curr_Vol;
double Prev_Vol;
datetime timestamp;
bool firstTick=true;

int init() {
  
  SetIndexBuffer(0,close);          SetIndexEmptyValue(8,0);   SetIndexStyle(0,DRAW_NONE);
  SetIndexBuffer(1,open);           SetIndexEmptyValue(9,0);   SetIndexStyle(1,DRAW_NONE);
  SetIndexBuffer(2,high);           SetIndexEmptyValue(10,0);  SetIndexStyle(2,DRAW_NONE);
  SetIndexBuffer(3,low);            SetIndexEmptyValue(11,0);  SetIndexStyle(3,DRAW_NONE);
  SetIndexBuffer(4,Up_Body_Blue);  SetIndexEmptyValue(0,0);   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2,Blue);
  SetIndexBuffer(5,Dn_Body_Red);    SetIndexEmptyValue(1,0);   SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,2,Red);
  SetIndexBuffer(6,EqBodyBuffer);   SetIndexEmptyValue(2,0);   SetIndexStyle(6,DRAW_HISTOGRAM,STYLE_SOLID,2,White);
  SetIndexBuffer(7,Bg_Body_White);  SetIndexEmptyValue(3,0);   SetIndexStyle(7,DRAW_HISTOGRAM,STYLE_SOLID,2,White);
  SetIndexBuffer(8,Up_Wick_Blue);  SetIndexEmptyValue(4,0);   SetIndexStyle(8,DRAW_HISTOGRAM,STYLE_SOLID,1,Blue);
  SetIndexBuffer(9,Dn_Wick_Red);    SetIndexEmptyValue(5,0);   SetIndexStyle(9,DRAW_HISTOGRAM,STYLE_SOLID,1,Red);
  SetIndexBuffer(10,EqShadowBuffer);SetIndexEmptyValue(6,0);   SetIndexStyle(10,DRAW_HISTOGRAM,STYLE_SOLID,1,White);
  SetIndexBuffer(11,Bg_Wick_White);  SetIndexEmptyValue(7,0);   SetIndexStyle(11,DRAW_HISTOGRAM,STYLE_SOLID,1,White);
  SetIndexBuffer(12,Dn_Body_Blue); SetIndexEmptyValue(12,0);  SetIndexStyle(12,DRAW_HISTOGRAM,STYLE_SOLID,2,Blue);
  SetIndexBuffer(13,Up_Body_Red);   SetIndexEmptyValue(13,0);  SetIndexStyle(13,DRAW_HISTOGRAM,STYLE_SOLID,2,Red);
  SetIndexBuffer(14,Dn_Wick_Blue); SetIndexEmptyValue(14,0);  SetIndexStyle(14,DRAW_HISTOGRAM,STYLE_SOLID,1,Blue);
  SetIndexBuffer(15,Up_Wick_Red);   SetIndexEmptyValue(15,0);  SetIndexStyle(15,DRAW_HISTOGRAM,STYLE_SOLID,1,Red);
   
   close[1]=0;
   open[1]=0;
   high[1]=0;
   low[1]=0;
   close[0]=0;
   open[0]=0;
   high[0]=0;
   low[0]=0;
  
 
   return (0);
}

int deinit() {
   return (0);
}

int start() {

   Prev_Bid = Curr_Bid;
   Curr_Bid = Bid;
   Prev_Ask = Curr_Ask;
   Curr_Ask = Ask;
   Prev_Vol = Curr_Vol;
   Curr_Vol = iVolume(NULL,0,0);
   
   if (Time[0]!=timestamp) {
         close[0]=close[1];
         open[0]=close[1];
         high[0]=close[1];
         low[0]=close[1];
         Prev_Vol=0;
         timestamp=Time[0];      
   }

      
         if (Curr_Ask > Prev_Ask){
            close[0]=close[0]+(Curr_Vol-Prev_Vol);
            if(close[0]>high[0]){
               high[0]=close[0];
            }
            if(close[0]<low[0]){
               low[0]=close[0];
            }
            
         }   
         if (Curr_Bid < Prev_Bid){ 
            close[0]=close[0]-(Curr_Vol-Prev_Vol);
             if(close[0]>high[0]){
               high[0]=close[0];
            }
            if(close[0]<low[0]){
               low[0]=close[0];
            }                     
         }  
          
      
      if (close[0]>0 && open[0]>0 && low [0]>0 && high[0]>0){
      
            if (close[0]>open[0]){
                 Up_Body_Blue[0] = close[0];
                 Bg_Body_White[0] = open[0];
                 Up_Wick_Blue[0] = high[0];
                 Bg_Wick_White[0] = low[0];
                 
                 Up_Wick_Red[0]=0;
                 Up_Body_Red[0]=0;
                 Dn_Wick_Red[0]=0;
                 Dn_Body_Red[0]=0;
                
                 
                 
            }
            if (close[0]<open[0]){
                 Dn_Body_Red[0] = open[0];
                 Bg_Body_White[0] = close[0];
                 Dn_Wick_Red[0] = high[0];
                 Bg_Wick_White[0] = low[0];
                 
                 Up_Wick_Blue[0]=0;
                 Up_Body_Blue[0]=0;
                 Dn_Wick_Blue[0]=0;
                 Dn_Body_Blue[0]=0;
                 
            }  
              
       }
       if (close[0]>0 && open[0]>0 && low [0]<0 && high[0]>0){
      
            if (close[0]>open[0]){
                 Up_Body_Blue[0] = close[0];
                 Bg_Body_White[0] = open[0];
                 Up_Wick_Blue[0] = high[0];
                 Dn_Wick_Blue[0] = low[0];
                 
                 Up_Wick_Red[0]=0;
                 Up_Body_Red[0]=0;
                 Dn_Wick_Red[0]=0;
                 Dn_Body_Red[0]=0;

            }
            if (close[0]<open[0]){
                 Up_Body_Red[0] = open[0];
                 Bg_Body_White[0] = close[0];
                 Up_Wick_Red[0] = high[0];
                 Dn_Wick_Red[0] = low[0];
                 
                 Up_Wick_Blue[0]=0;
                 Up_Body_Blue[0]=0;
                 Dn_Wick_Blue[0]=0;
                 Dn_Body_Blue[0]=0;
                 
            }    
       }      
       if (close[0]>0 && open[0]<0){
      
            if (close[0]>open[0]){
                 Up_Body_Blue[0] = close[0];
                 Up_Wick_Blue[0] = high[0];
                 Dn_Body_Blue[0] = open[0];
                 Dn_Wick_Blue[0]= low[0];
                 
                 Up_Wick_Red[0]=0;
                 Up_Body_Red[0]=0;
                 Dn_Wick_Red[0]=0;
                 Dn_Body_Red[0]=0;
                 Bg_Body_White[0]=0;
                 Bg_Wick_White[0]=0;
                            
            }    
       }          
       
       if (close[0]<0 && open[0]<0 && low [0]<0 && high[0]<0){
      
            if (close[0]>open[0]){
                 Up_Body_Blue[0] = open[0];
                 Bg_Body_White[0] = close[0];
                 Up_Wick_Blue[0] = low[0];
                 Bg_Wick_White[0] = high[0];
                 
                 Up_Wick_Red[0]=0;
                 Up_Body_Red[0]=0;
                 Dn_Wick_Red[0]=0;
                 Dn_Body_Red[0]=0;
            }
            if (close[0]<open[0]){
                 Dn_Body_Red[0] = close[0];
                 Bg_Body_White[0] = open[0];
                 Dn_Wick_Red[0] = low[0];
                 Bg_Wick_White[0] = high[0];
                 
                 Up_Wick_Blue[0]=0;
                 Up_Body_Blue[0]=0;
                 Dn_Wick_Blue[0]=0;
                 Dn_Body_Blue[0]=0;
            }    
       }
       
       if (close[0]<0 && open[0]<0 && low [0]<0 && high[0]>0){
      
            if (close[0]>open[0]){
                 Dn_Body_Blue[0] = open[0];
                 Bg_Body_White[0] = close[0];
                 Up_Wick_Blue[0] = high[0];
                 Dn_Wick_Blue[0] = low[0];
                 
                 Up_Wick_Red[0]=0;
                 Up_Body_Red[0]=0;
                 Dn_Wick_Red[0]=0;
                 Dn_Body_Red[0]=0;
            }
            if (close[0]<open[0]){     
                 Dn_Body_Red[0] = close[0];
                 Bg_Body_White[0] = open[0];
                 Up_Wick_Red[0] = high[0];
                 Dn_Wick_Red[0] = low[0];
                   
                 Up_Wick_Blue[0]=0;
                 Up_Body_Blue[0]=0;
                 Dn_Wick_Blue[0]=0;
                 Dn_Body_Blue[0]=0;             
                 
            }    
       }

        if (close[0]<0 && open[0]>0){
      
            if (close[0]<open[0]){
                 Dn_Body_Red[0] = close[0];
                 Up_Wick_Red[0] = high[0];            
                 Up_Body_Red[0] = open[0];
                 Dn_Wick_Red[0] = low[0];
                  
                 Up_Wick_Blue[0]=0;
                 Up_Body_Blue[0]=0;
                 Dn_Wick_Blue[0]=0;
                 Dn_Body_Blue[0]=0; 
                 Bg_Body_White[0]=0;
                 Bg_Wick_White[0]=0;            
               
                 
            }    
       }    
      
   

   return (0);
}
