#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Magenta      
#property indicator_color2 Lime
#property indicator_color3 Green 
#property indicator_color4 Red

extern int     TimeFrame         = 0;
extern double  Smooth_Ratio      = 0.5;
extern int     Rperiod           = 34;
extern int     Draw4HowLong      = 1000;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double CrossUp[];
double CrossDown[];
int init()
  {
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(3,CrossDown);
   SetIndexBuffer(2,CrossUp);
   
   SetIndexStyle(2, DRAW_ARROW, EMPTY);
   SetIndexStyle(3, DRAW_ARROW, EMPTY);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   
   SetIndexArrow(3, 159);
   SetIndexArrow(2, 159);

   string short_name="Mtf SLSMA v1.0 |";
   IndicatorShortName(short_name);
   
   SetIndexLabel(0,"SLSMA ");
   SetIndexLabel(1,"SLSMA slope");
   SetIndexLabel(2,"SLSMA Signal up");
   SetIndexLabel(3,"SLSMA Signal down");

  }
   return(0);
 
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
 
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 

   limit=Bars-counted_bars;
   limit=MathMax(limit,TimeFrame/Period());
   limit=MathMin(limit,Draw4HowLong);  

   for(i=0,y=0;i<limit;i++)
   {
   if (TimeFrame<Period()) TimeFrame=Period();
   if (Time[i]<TimeArray[y]) y++;

 ExtMapBuffer1[i] =iCustom(NULL,TimeFrame,"SLSMA v1.1",Smooth_Ratio,Rperiod,Draw4HowLong,0,y);
 ExtMapBuffer2[i] =iCustom(NULL,TimeFrame,"SLSMA v1.1",Smooth_Ratio,Rperiod,Draw4HowLong,1,y);
 CrossUp[i]=iCustom(NULL,TimeFrame,"SLSMA v1.1",Smooth_Ratio,Rperiod,Draw4HowLong,2,y);
 CrossDown[i]=iCustom(NULL,TimeFrame,"SLSMA v1.1",Smooth_Ratio,Rperiod,Draw4HowLong,3,y);
   }  
   if (TimeFrame>Period())
   {
     int PerINT=TimeFrame/Period()+1;
     datetime TimeArr[]; ArrayResize(TimeArr,PerINT);
     ArrayCopySeries(TimeArr,MODE_TIME,Symbol(),Period()); 
     for(i=0;i<PerINT+1;i++) {if (TimeArr[i]>=TimeArray[0]) {

   ExtMapBuffer1[i]=ExtMapBuffer1[0];
   ExtMapBuffer2[i]=ExtMapBuffer2[0];
   CrossUp[i]=CrossUp[0];
   CrossDown[i]=CrossDown[0];
   } } }

   return(0);
  }

