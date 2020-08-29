//+------------------------------------------------------------------+
//|                                                     COGSTOCH.mq4 |
//| Original Code from NG3110@latchess.com                           |                                    
//| Linuxser 2007 for TSD    http://www.forex-tsd.com/               |
//| Stoch Modified Brooky    http://www.brooky-indicators.com        |
//+------------------------------------------------------------------+
#property  copyright "ANG3110@latchess.com"
//---------ang_pr (Din)--------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Gray
#property indicator_color2 IndianRed
#property indicator_color3 CadetBlue
#property indicator_color4 Pink
#property indicator_color5 PowderBlue
#property indicator_color6 Blue
#property indicator_color7 Red


#property indicator_level1 80
#property indicator_level2 50
#property indicator_level3 20
#property indicator_level4 100
#property indicator_level5 00

#property indicator_style1 1
#property indicator_style7 2

#property indicator_width2 2
#property indicator_width3 2


//-----------------------------------
extern int bars_back=192;
extern int stoch_k = 14;
extern int stoch_d = 5;
extern int stoch_s = 3;


extern int m = 5;
extern int i = 1;
extern double kstd=1.618;
extern double kstd_internal=0.8;
extern int sName=2;
//-----------------------
double fx[],sqh[],sql[],stdh[],stdl[],stochdata[],stochsdata[];
double ai[10,10],b[10],x[10],sx[20];
double sum;
int    ip,p,n,f;
double qq,mm,tt;
int    ii,jj,kk,ll,nn;
double sq,std;

bool ready_flag=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Prepare_Object()
  {
   if(ready_flag==true) return;

   p=MathRound(bars_back);

   nn=m+1;
   ObjectCreate("sstart"+sName,22,0,Time[p],fx[p]);
   ObjectSet("sstart"+sName,14,159);

   ready_flag=true;
  }
//*******************************************
int init()
  {
   IndicatorShortName("COGSTOCH: Mod by Brooky-Indicators.com");

   SetIndexBuffer(0,fx);SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,sqh);
   SetIndexBuffer(2,sql);
   SetIndexBuffer(3,stdh);
   SetIndexBuffer(4,stdl);
   SetIndexBuffer(5,stochdata);SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,stochsdata);SetIndexStyle(6,DRAW_LINE);
   
   ready_flag=false;
   return(0);
  }
//----------------------------------------------------------
int deinit()
  {
   ObjectDelete("sstart"+sName);
   return(0);
  }
//**********************************************************************************************
int start()
  {
   int mi;
   
   if (ready_flag==false) Prepare_Object();
   
//-------------------------------------------------------------------------------------------
   ip= iBarShift(Symbol(),Period(),ObjectGet("sstart"+sName,OBJPROP_TIME1));
   p = bars_back;
   sx[1]=p+1;
   SetIndexDrawBegin(0,Bars-p-1);
   SetIndexDrawBegin(1,Bars-p-1);
   SetIndexDrawBegin(2,Bars-p-1);
   SetIndexDrawBegin(3,Bars-p-1);
   SetIndexDrawBegin(4,Bars-p-1);
//----------------------sx-------------------------------------------------------------------

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int rlimit = Bars - counted_bars;
   if(counted_bars==0) rlimit-=1;
   
//---- main loop
   for(int ri=0; ri<rlimit; ri++)
     {

      stochdata[ri]=iStochastic(NULL,0,stoch_k,stoch_d,stoch_s,MODE_SMA,0,MODE_MAIN,ri);
      stochsdata[ri]=iStochastic(NULL,0,stoch_k,stoch_d,stoch_s,MODE_SMA,0,MODE_SIGNAL,ri);
     }

   for(mi=1; mi<=nn*2-2; mi++)
     {
      sum=0;
      for(n=i; n<=i+p; n++)
        {
         sum+=MathPow(n,mi);
        }
      sx[mi+1]=sum;
     }
//----------------------syx-----------
   for(mi=1; mi<=nn; mi++)
     {

      sum=0.00000;
      for(n=i; n<=i+p; n++)
        {
         if(mi==1)
            sum+=iStochastic(NULL,0,stoch_k,stoch_d,stoch_s,MODE_SMA,0,MODE_MAIN,n);//rsi_period  iRSI(NULL,0,rsi_period,prICE_CLOSE,n)
         else
            sum+=iStochastic(NULL,0,stoch_k,stoch_d,stoch_s,MODE_SMA,0,MODE_MAIN,n)*MathPow(n,mi-1);
        }
      b[mi]=sum;
     }
//===============Matrix=======================================================================================================
   for(jj=1; jj<=nn; jj++)
     {
      for(ii=1; ii<=nn; ii++)
        {
         kk=ii+jj-1;
         ai[ii,jj]=sx[kk];
        }
     }
//===============Gauss========================================================================================================
   for(kk=1; kk<=nn-1; kk++)
     {
      ll=0; mm=0;
      for(ii=kk; ii<=nn; ii++)
        {
         if(MathAbs(ai[ii,kk])>mm)
           {
            mm = MathAbs(ai[ii, kk]);
            ll = ii;
           }
        }
      if(ll==0)
         return(0);

      if(ll!=kk)
        {
         for(jj=1; jj<=nn; jj++)
           {
            tt=ai[kk,jj];
            ai[kk, jj] = ai[ll, jj];
            ai[ll, jj] = tt;
           }
         tt=b[kk]; b[kk]=b[ll]; b[ll]=tt;
        }
      for(ii=kk+1; ii<=nn; ii++)
        {
         qq=ai[ii,kk]/ai[kk,kk];
         for(jj=1; jj<=nn; jj++)
           {
            if(jj==kk)
               ai[ii,jj]=0;
            else
               ai[ii,jj]=ai[ii,jj]-qq*ai[kk,jj];
           }
         b[ii]=b[ii]-qq*b[kk];
        }
     }
   x[nn]=b[nn]/ai[nn,nn];
   for(ii=nn-1; ii>=1; ii--)
     {
      tt=0;
      for(jj=1; jj<=nn-ii; jj++)
        {
         tt=tt+ai[ii,ii+jj]*x[ii+jj];
         x[ii]=(1/ai[ii,ii]) *(b[ii]-tt);
        }
     }
//===========================================================================================================================
   for(n=i; n<=i+p; n++)
     {
      sum=0;
      for(kk=1; kk<=m; kk++)
        {
         sum+=x[kk+1]*MathPow(n,kk);
        }
      fx[n]=x[1]+sum;
     }
//-----------------------------------Std-----------------------------------------------------------------------------------
   sq=0.0;
   for(n=i; n<=i+p; n++)
     {
      sq+=MathPow(iStochastic(NULL,0,stoch_k,stoch_d,stoch_s,MODE_SMA,0,MODE_MAIN,n)-fx[n],2);
     }
   sq=MathSqrt(sq/(p+1))*kstd;
   std=iStdDevOnArray(stochdata,0,p,0,MODE_SMA,i) *kstd_internal;
   for(n=i; n<=i+p; n++)
     {
      sqh[n] = fx[n] + sq;
      sql[n] = fx[n] - sq;
      stdh[n] = fx[n] + std;
      stdl[n] = fx[n] - std;
     }
//-------------------------------------------------------------------------------
   ObjectMove("sstart"+sName,0,Time[p],fx[p]);
//----------------------------------------------------------------------------------------------------------------------------
   return(0);
  }
//==========================================================================================================================   
