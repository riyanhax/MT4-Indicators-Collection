//+------------------------------------------------------------------+
//|                                                      VSA_MTM.mq4 |
//|                                                          yijomza |
//|                                                yijomza@gmail.com |
//+------------------------------------------------------------------+
#property copyright "yijomza"
#property link      "yijomza@gmail.com"

#property indicator_chart_window
extern double vollbf = 1.0; 
extern double spdlbf = 1.0;
extern int lookbackbars = 500;
extern int Mode=1;
extern string Description1="Mode=1 : follow the theory";
extern string Description2="Mode=2 : using standard deviasion";
int min2bar_reversal_length = 0;
double v0,v1,v2, spread, closelow, avgspread, avgvol, stdvol, stspread; 
bool testmode = false;
int vperiod, speriod = 0;
int background, meter = 0;
double shift=0;
int closetype,upclose=1,midclose=2,dnclose=3;
int sptype,narrow=1,avg=2,wide=3;
int voltype,lowv=1,avgv=2,highv=3,exvol=4;
string objprefix="VSA_MTM";
int o;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetConstants();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
deletetext();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   //deletetext();
   int period;
   if (vperiod > speriod) { period = vperiod; }
   else {period = speriod;}
   if(Bars<=period) { return(0); }
   int counted_bars=IndicatorCounted(); 
   if(counted_bars > 0) { counted_bars--; } 
   int i;
   if(counted_bars>=period) { i=Bars-counted_bars-1; }
   else { i=Bars-period-1; }
   o=0;
   if (i>lookbackbars) {i=lookbackbars;}
   for(int bar=i;bar>0;bar--)
   {
      
      string ot=DoubleToStr(o,0);
      
      spread = MathAbs(High[bar]-Low[bar]);
      double spread1 = MathAbs(High[bar+1]-Low[bar+1]);
      if(spread==0)spread=Point;
      if(spread1==0)spread1=Point;
      closelow = Close[bar]-Low[bar];
      double closelow1 = Close[bar+1]-Low[bar+1];
   
      avgspread = CalculateAverageSpread(bar);
      stspread = CalculateSpdStdDev(avgspread,bar);
      double avgspread1 = CalculateAverageSpread(bar+1);
      double stspread1 = CalculateSpdStdDev(avgspread1,bar+1);
      
      avgvol = CalculateAverageVolume(bar);
      stdvol = CalculateVolStdDev(avgvol,bar);
      double avgvol1 = CalculateAverageVolume(bar+1);
      double stdvol1 = CalculateVolStdDev(avgvol1,bar+1);
      
      double v0 = Volume[bar];
      double v1 = Volume[bar+1];
      
      double mid=(High[bar]+Low[bar])/2;
      
      if(Mode==1)
      {
         if      (  spread<=0.8*avgspread ) 
         { sptype=narrow;}
         else if (  spread>=1.8*avgspread) 
         {sptype=wide;} 
         else 
         { sptype=avg;}
         
      }
      if(Mode==2)
      {
         if      (  spread < (avgspread-0.4*stspread) ) 
         { sptype=narrow;}
         else if (  spread< (avgspread+0.4*stspread) ) 
         { sptype=avg;}
         else if (  spread >= (avgspread+0.7*stspread) )
         {sptype=wide;} 
         else {sptype=0;}
      }
      
      if    ( (closelow/spread >=0.35) && (closelow/spread <= 0.65) )  { closetype=midclose; }
      else if (closelow/spread > 0.65)  { closetype=upclose; }
      else if (closelow/spread < 0.35)  { closetype=dnclose; }
   
      if      ( v0 < (avgvol-0.5*stdvol) ) { voltype=lowv;  }
      else if ( v0 < (avgvol+0.5*stdvol) ) { voltype=avgv; }
      else if ( v0 < (avgvol+1.0*stdvol) ) { voltype=highv; }
      else { voltype=exvol; }
   
    string time=TimeToStr(Time[bar],TIME_MINUTES);
   
    if((sptype==narrow || sptype==avg)
    && (closetype==midclose||closetype==upclose) 
    && voltype==lowv 
    && Volume[bar]<Volume[bar+1]
    && Volume[bar]<Volume[bar+1]
    && Volume[bar+1]<Volume[bar+2]
    && downbar(bar,1)
    )
    {
      sig(objprefix," No Selling Pressure "+time,bar,mid,82,Orange);
      o++;
    }
    if((sptype==narrow || sptype==avg)
    && closetype==upclose
    && voltype==exvol
    && LocalLow(bar,5)
    )
    {
     sig(objprefix," Selling Climax "+time,bar,mid-1*Point,83,YellowGreen);
     o++;
    }
    if(closetype==upclose
    && voltype==lowv
    )
    {
     sig(objprefix," Successful Test "+time,bar,mid-2*Point,89,SteelBlue);
     o++;
    }
    if((sptype==wide || sptype==avg)
    && closetype==upclose
    && upbar(bar,1)
    && Volume[bar]>Volume[bar+1]
    && Volume[bar]>Volume[bar+2]
    )
    {
     sig(objprefix," Bullish Signal "+time,bar,mid-3*Point,108,HotPink);
     o++;
    }
    if(closetype==upclose
    && (voltype==highv||voltype==exvol)
    && downbar(bar,1)
    )
    {
     sig(objprefix," Bullish Signal "+time,bar,mid-4*Point,110,Orchid);
     o++;
    }
    if(sptype==wide
    && closetype==upclose
    && LocalLow(bar,5)
    && (voltype==highv||voltype==exvol)
    )
    {
     sig(objprefix," Reverse Upthrust "+time,bar,mid-4.5*Point,88,OliveDrab);
    }
    if((( (closelow1/spread1 >=0.35) && (closelow1/spread1 <= 0.65) )||(closelow1/spread1 > 0.65)) 
    && downbar(bar+1,1)
    && v1 >= (avgvol1+1.0*stdvol1)
    && upbar(bar,1)
    )
    {
     sig(ot+objprefix," Professional Support "+time,bar,mid-5*Point,84,Sienna);
    }
    if(sptype==wide
    && closetype==dnclose
    )
    {
     sig(ot+objprefix," Shake-Out "+time,bar,mid-5.5*Point,122,MediumVioletRed);
    }
    if((sptype==narrow || sptype==avg)
    && upbar(bar,1)
    && voltype==lowv
    )
    {
     sig(objprefix," Weakness "+time,bar,mid+1*Point,116,Goldenrod);
     o++;
    }
    if(sptype==wide
    && downbar(bar,1)
    && closetype==dnclose
    && voltype==lowv
    )
    {
     sig(objprefix," Falling Pressure "+time,bar,mid+1.5*Point,112,FireBrick);
    }
    if((sptype==narrow || sptype==avg)
    && voltype==exvol
    && closetype==upclose
    && LocalHigh(bar,5)
    )
    {
     sig(objprefix," Buying Climax "+time,bar,mid+2*Point,124,Pink);
     o++;
    }
    if((sptype==narrow || sptype==avg)
    && upbar(bar,1)
    && voltype==lowv
    )
    {
     sig(objprefix," Lack Of Demand "+time,bar,mid+3*Point,181,LightBlue);
     o++;
    }
    if(upbar(bar+1,1)
    && (v1 >= (avgvol1+1.0*stdvol1))
    && LocalHigh(bar+1,5)
    && Close[bar]<=Close[bar+1]
    )
    {
     sig(objprefix," Selling Signal "+time,bar,mid+4*Point,169,Navy);
     o++;
    }
    if((sptype==wide || sptype==avg)
    && downbar(bar,1)
    && Volume[bar]>Volume[bar+1]
    && Volume[bar]>Volume[bar+2]
    && closetype==dnclose
    )
    {
     sig(ot+objprefix," Selling Signal "+time,bar,mid+5*Point,170,Green);
     o++;
    }
    if(v1 >= (avgvol1+1.0*stdvol1)
    && (((closelow1/spread1 >=0.35) && (closelow1/spread1 <= 0.65)) || (closelow1/spread1 < 0.35))
    && (downbar(bar,1) || (sptype==narrow&&upbar(bar,1)))
    )
    {
     sig(objprefix," Selling Signal "+time,bar,mid+6*Point,171,Crimson);
     o++;
    }
    if(sptype==wide
    && closetype==dnclose
    )
    {
     sig(objprefix," UpThrust "+time,bar,mid+6.5*Point,179,Purple);
    }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
/*void Text(string name,string txt,int time,double price,color cl)
{
ObjectCreate(name,OBJ_TEXT,0,time,price);
ObjectSetText(name,txt,8,"Comic Sans MS",cl);
ObjectSet(name, OBJPROP_ANGLE,90);
}*/
void sig(string pre,string text,int s,double dprice,int code,color icolor)
{
 ObjectCreate(objprefix+" "+text, OBJ_ARROW, 0, Time[s], dprice);
 ObjectSet(objprefix+" "+text, OBJPROP_ARROWCODE, code);     
 ObjectSet(objprefix+" "+text, OBJPROP_COLOR, icolor);
 SetIndexArrow(3,code);
}
void deletetext() 
{
  for(int i=ObjectsTotal();i >= 0;i--)
  {
    if(StringSubstr(ObjectName(i),0,StringLen(objprefix))==objprefix)
    { ObjectDelete(ObjectName(i)); }
  }
}
double CalculateAverageSpread(int cbar)
{
   double as, s = 0;
   for (int i=cbar+speriod; i>=cbar; i--)
   {
      s = High[i]-Low[i];
      as = as+s;
   }   
   return(as/speriod);
}

double CalculateSpdStdDev(double av, int cbar) 
{
   double s, sd, sumspd = 0;
   for (int i=cbar+speriod; i>=cbar; i--)
   {
      s = (High[cbar]-Low[cbar]) - av;
      sumspd = sumspd+MathPow(s,2);
   }   
   sd = MathSqrt(sumspd/speriod);
   return(sd);
}
void SetConstants()
{
   shift =(WindowPriceMax()-WindowPriceMin())/30;
   meter = 0;
   background = 0;
   switch (Period()) {
      case PERIOD_M1:
         vperiod = 40*vollbf;
         speriod = 40*spdlbf; 
         min2bar_reversal_length = 10;
         break;
      case PERIOD_M5:
         vperiod = 30*vollbf;
         speriod = 30*spdlbf; 
         min2bar_reversal_length = 10;
         break;
      case PERIOD_M15:
         vperiod = 25*vollbf;
         speriod = 25*spdlbf; 
         min2bar_reversal_length = 10;
         break;
      case PERIOD_M30:
         vperiod = 24*vollbf;
         speriod = 24*spdlbf; 
         min2bar_reversal_length = 15;
         break;      
      case PERIOD_H1:
         vperiod = 20*vollbf;
         speriod = 20*spdlbf;
         min2bar_reversal_length = 25;
         break;
      case PERIOD_H4:
         vperiod = 20*vollbf;
         speriod = 20*spdlbf;
         min2bar_reversal_length = 20;
         break;
      case PERIOD_D1:
         vperiod = 20*vollbf;
         speriod = 20*spdlbf;
         min2bar_reversal_length = 30;
         break;
      case PERIOD_W1:
         vperiod = 20*vollbf;
         speriod = 20*spdlbf;
         min2bar_reversal_length = 40;
         break;
      case PERIOD_MN1:
         vperiod = 20*vollbf;
         speriod = 20*spdlbf;
         min2bar_reversal_length = 50;
         break;
   }
   if (testmode)
      Comment("vl=",vperiod," sl=",speriod);
}
double CalculateAverageVolume(int cbar)
{
   double av, v = 0;
   for (int i=cbar+vperiod; i>=cbar; i--)
   {
      v = iVolume(NULL,Period(),i);
      av = av+v;
   }   
   return(av/vperiod);
}
double CalculateVolStdDev(double av, int cbar) 
{
   double v, sd, sumv2 = 0;
   for (int i=cbar+vperiod; i>=cbar; i--)
   {
      v = iVolume(NULL,Period(),i) - av;
      sumv2 = sumv2+MathPow(v,2);
   }   
   sd = MathSqrt(sumv2/vperiod);
   return(sd);
}
bool LocalHigh(int bar, int back)
{
   if (bar == iHighest(NULL,0, MODE_HIGH,back,bar))
   { return(true); }
   return(false);
}

bool LocalLow(int bar, int back)
{
   if (bar == iLowest(NULL,0, MODE_LOW,back,bar))
   {  return(true); }
   return(false);

}

bool upbar(int b, int n)
{
   if (Close[b] > Close[b+n])
   { return (true); }
   return (false);
}


bool downbar(int b, int n)
{
   if (Close[b] < Close[b+n])
   { return (true); }
   return (false);
}

