//+------------------------------------------------------------------+
//|                                                 Fine volumes.mq4 |
//|                                                         eevviill |
//|                                        itisallillusion@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 6

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 4
#property indicator_width5 4

#property indicator_color1 SkyBlue
#property indicator_color2 Maroon
#property indicator_color3 Yellow
#property indicator_color4 Blue
#property indicator_color5 Red



extern int BarsToCount = 400;

extern string pus1 = "";
extern string p_s = "Points settings";
extern bool use_points = true;
extern int distance_point = 80;
extern color color_point = Lime;
extern int size_point = 6;

extern string pus2 = "";
extern string s_w = "Way";
extern bool use_show_same_way = true;
extern bool use_show_daily_way = true;

extern string pus3 = "";
extern string al = "Alerts";
extern bool use_alerts = false;
extern string up_alert = "Up";
extern string down_alert = "Down";




double up[];
double down[];
double mid[];
double up2[];
double down2[];
double none[];

static int prevtime = 0;

///////////////////////////////////////
int init()
  {
SetIndexStyle(0,DRAW_HISTOGRAM);  
SetIndexBuffer(0,up);
SetIndexStyle(1,DRAW_HISTOGRAM);  
SetIndexBuffer(1,down);
SetIndexStyle(2,DRAW_HISTOGRAM);  
SetIndexBuffer(2,mid);
SetIndexStyle(3,DRAW_HISTOGRAM);  
SetIndexBuffer(3,up2);
SetIndexStyle(4,DRAW_HISTOGRAM);  
SetIndexBuffer(4,down2);
SetIndexStyle(5,DRAW_NONE);  
SetIndexBuffer(5,none);


IndicatorShortName("Aliev FX Volumes");


   return(0);
  }




//////////////////////////////////////////
int start()
  {
  ////////////
   up[0]=EMPTY_VALUE;
  down[0]=EMPTY_VALUE;
  mid[0]=EMPTY_VALUE;
if(Close[0]>Open[0]) up[0]=Volume[0];
if(Close[0]<Open[0]) down[0]=Volume[0];
if(Close[0]==Open[0]) mid[0]=Volume[0];

////////////////
  if(use_points)
  Ob_cre(0);

  if(!use_points)
  Ob_del(0);
////////
  if(use_show_daily_way)
  Ob_cre2();
  
  if(!use_show_daily_way)
  Ob_del2();
  

  ////////////
  if (Time[0] == prevtime) return(0);
   prevtime = Time[0];
  
  ///////////////////////////
  for(int c=BarsToCount;c>=1;c--)
  {
  ////////////
  if(use_points)
Ob_cre(c);

  if(!use_points)
  Ob_del(c);
  
 
  
  ////////////
  up[c]=EMPTY_VALUE;
  down[c]=EMPTY_VALUE;
  mid[c]=EMPTY_VALUE;
  up2[c]=EMPTY_VALUE;
  down2[c]=EMPTY_VALUE;




/////////////////  
if(Close[c]>Open[c]) up[c]=Volume[c];
if(Close[c]<Open[c]) down[c]=Volume[c];
if(Close[c]==Open[c]) mid[c]=Volume[c];
none[c]=Volume[c]+Volume[c]/6;


//////////////
if(use_show_same_way)
{

if(Close[c]>Open[c] && Close[c+1]>Open[c+1] && Close[c+2]>Open[c+2]) 
{
up2[c]=Volume[c]; up2[c+1]=Volume[c+1]; up2[c+2]=Volume[c+2];
up[c]=EMPTY_VALUE; up[c+1]=EMPTY_VALUE; up[c+2]=EMPTY_VALUE;
}

if(Close[c]<Open[c] && Close[c+1]<Open[c+1] && Close[c+2]<Open[c+2]) 
{
down2[c]=Volume[c]; down2[c+1]=Volume[c+1]; down2[c+2]=Volume[c+2];
down[c]=EMPTY_VALUE; down[c+1]=EMPTY_VALUE; down[c+2]=EMPTY_VALUE;
}

}


if(use_alerts)
{
if(up2[1]!=EMPTY_VALUE && up2[4]==EMPTY_VALUE) Alert(up_alert);
if(down2[1]!=EMPTY_VALUE && down2[4]==EMPTY_VALUE) Alert(down_alert);
}



  }
   return(0);
  }
  
  
  //func
//+------------------------------------------------------------------+///////////////////////////////
void Ob_cre(int num_of_bar)
{
int Num_of_win = WindowFind("Aliev FX Volumes");
string name="Vol_"+DoubleToStr(num_of_bar,0);

if(ObjectFind(name)==-1)
{
ObjectCreate(name,OBJ_TEXT,Num_of_win,0,0);
}
ObjectSet(name,OBJPROP_TIME1,Time[num_of_bar]);
ObjectSet(name,OBJPROP_PRICE1,Volume[num_of_bar]+distance_point);
ObjectSetText(name,DoubleToStr(Volume[num_of_bar],0),size_point,"Arrial",color_point);

}

/////////////////////////////////////////
void Ob_cre2()
{
int Num_of_win = WindowFind("Aliev FX Volumes");

if(ObjectFind("D_w")==-1)
{
ObjectCreate("D_w",OBJ_LABEL,Num_of_win,0,0);
ObjectSet("D_w",OBJPROP_CORNER,1);
ObjectSet("D_w",OBJPROP_XDISTANCE,20);
ObjectSet("D_w",OBJPROP_YDISTANCE,20);
ObjectSetText("D_w","Daily volume",10,"Arrial",White);
}


if(ObjectFind("D_w_v")==-1)
{
ObjectCreate("D_w_v",OBJ_LABEL,Num_of_win,0,0);
ObjectSet("D_w_v",OBJPROP_CORNER,1);
ObjectSet("D_w_v",OBJPROP_XDISTANCE,20);
ObjectSet("D_w_v",OBJPROP_YDISTANCE,45);
}
color vol_col;
if(iClose(Symbol(),PERIOD_D1,0)>iOpen(Symbol(),PERIOD_D1,0)) vol_col=Lime;
if(iClose(Symbol(),PERIOD_D1,0)<iOpen(Symbol(),PERIOD_D1,0)) vol_col=OrangeRed;

ObjectSetText("D_w_v",DoubleToStr(iVolume(Symbol(),PERIOD_D1,0),0),12,"Arrial",vol_col);


}

/////////////////////////////////////////////////////////////////
void Ob_del(int num_of_bar)
{
string name="Vol_"+DoubleToStr(num_of_bar,0);

if(ObjectFind(name)!=-1)
{
ObjectDelete(name);
}


}

/////////////////////////////////////////
void Ob_del2()
{
if(ObjectFind("D_w")!=-1)
ObjectDelete("D_w");


if(ObjectFind("D_w_v")!=-1)
ObjectDelete("D_w_v");



}