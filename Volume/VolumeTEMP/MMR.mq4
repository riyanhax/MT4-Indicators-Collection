//+------------------------------------------------------------------+
//|                                                          MMR.mq4 |
//|                                  Based on a strategy by cmillion |
//|             EMA5+LWMA85 crossover with MACD and RSI confirmation |
//+------------------------------------------------------------------+
#property copyright "Copyright @ 2011, downspin"
#property link      "mg@downspin.de"

int deinit(){return(0);}
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_level1 0
#property indicator_levelcolor DarkSlateGray

extern int mac_fast_ma=12,
           mac_slow_ma=26,
           mac_signal=9,
           rsi_period=14,
           ema_period=5,
           lwma_period=85;

double long1[],
       short1[],
       val[];

int init(){
  SetIndexStyle(0,DRAW_LINE); SetIndexBuffer(0,val);
  SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,5); SetIndexBuffer(1,long1);
  SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,5); SetIndexBuffer(2,short1);
  return(0);
}

int start(){
  double ema,lwma,rsi,mac;
  for(int i=0;i<Bars-IndicatorCounted();i++){
    ema=iMA(Symbol(),0,ema_period,0,1,0,i);
    lwma=iMA(Symbol(),0,lwma_period,0,3,0,i);
    rsi=iRSI(Symbol(),0,rsi_period,0,i);
    mac=iMACD(Symbol(),0,mac_fast_ma,mac_slow_ma,mac_signal,0,0,i);
    mac*=3000;
    rsi-=50;
    val[i]=(ema-lwma)/(Point*10)+mac+rsi;
    if((ema>lwma)&&(rsi>10)&&(mac>0)){
      long1[i]=val[i]-10;
    }
    if((ema<lwma)&&(rsi<-10)&&(mac<0)){
      short1[i]=val[i]+10;
    }
  }
  return(0);
}

