//+------------------------------------------------------------------+
//|                          Instantaneous Trend Line by John Ehlers |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+------------------------------------------------------------------+
#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Red
#property indicator_color2  Blue

//
//
//
//
//

extern int  Len                 = 40;
extern bool DrawPriceTrendLines = true;

//
//
//
//
//

double SineWave[];
double LeadSine[];
double Value1[],Value5[2],Value11[2];
double Resistance[];
double Support[];
double trend[];
double Price[],InPhase[2],Quadrature[2],Phase[2],DeltaPhase[],InstPeriod[2];
double Pi = 3.14159265358979323846264338327950288;
datetime sTime, rTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int init()
{
   string short_name;
   IndicatorBuffers(8);
   SetIndexBuffer(0,SineWave);
   SetIndexBuffer(1,LeadSine);
   SetIndexBuffer(2,Value1);
   SetIndexBuffer(3,Price); 
   SetIndexBuffer(4,DeltaPhase);
   SetIndexBuffer(5,Resistance);
   SetIndexBuffer(6,Support); 
   SetIndexBuffer(7,trend);

   short_name="Sine Wave Indicator";
   IndicatorShortName(short_name);


return(0);
}

//
//
//
//
//

int deinit()
{
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
   {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 18) != "Support Resistance")
           continue;
       ObjectDelete(label);   
   }
return(0);
}  

//
//
//
//
//

int start()
{
   int    i,r,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
   //
   //
   //
   //
   //
   
   for (i=limit; i>=0; i--)
   {
      InPhase[1]    = InPhase[0]; 
      Quadrature[1] = Quadrature[0];
      Phase[1]      = Phase[0]; 
      InstPeriod[1] = InstPeriod[0];
      Value5[1]     = Value5[0];
      Value11[1]    = Value11[0];
      Price[i]  = (High[i+1]+Low[i+1])/2;
   
      //  {Compute InPhase and Quadrature components}
      //
      //
      //
      //
   
      Value1[i] = Price[i] - Price[i+6];
      double Value2 = Value1[i+3];
      double Value3 = 0.75*(Value1[i] - Value1[i+6]) + 0.25*(Value1[i+2] - Value1[i+4]);
      InPhase[0]    = 0.33*Value2 + 0.67 * InPhase[1];
      Quadrature[0] = 0.20*Value3 + 0.8  * Quadrature[1];
 
      //   {Use ArcTangent to compute the current phase}
      //
      //
      //
      //
   
      if (MathAbs(InPhase[0]+InPhase[1])>0) Phase[0]=MathArctan(MathAbs((Quadrature[0]+Quadrature[1])/(InPhase[0]+InPhase[1])));
   
      //   {Resolve the ArcTangent ambiguity}
      //
      //
      //
      //
   
      if (InPhase[0] < 0 && Quadrature[0] > 0)  Phase[0] = 180 - Phase[0];
      if (InPhase[0] < 0 && Quadrature[0] < 0)  Phase[0] = 180 + Phase[0];
      if (InPhase[0] > 0 && Quadrature[0] < 0)  Phase[0] = 360 - Phase[0];
   
      //   {Compute a differential    phase, resolve phase wraparound, and limit delta phase errors}
      //
      //
      //
      //
   
      DeltaPhase[i] = Phase[1] - Phase[0];
      if (Phase[1] < 90 &&  Phase[0] > 270) DeltaPhase[i] = 360 + Phase[1] - Phase[0];
      if (DeltaPhase[i] < 1)  DeltaPhase[i] = 1;
      if (DeltaPhase[i] > 60) DeltaPhase[i] = 60;
 
      //   {Sum DeltaPhases  to reach 360  degrees. The sum is the instantaneous period.}
      //
      //
      //
      //
   
      InstPeriod[0]  = 0;
      double Value4  = 0;
      for (int count = 0;count<=Len;count++) 
      {
         Value4 = Value4 + DeltaPhase[i+count];
         if  (Value4 > 360 && InstPeriod[0]  == 0) InstPeriod[0] = count;
      }
    
      //   {Resolve Instantaneous  Period    errors and  smooth}
      //
      //
      //
      //
   
      if (InstPeriod[0] == 0) InstPeriod[0] = InstPeriod[1];
        Value5[0] = 0.25*(InstPeriod[0]) + 0.75*Value5[1];
   
      //   {Compute Trendline as simple average over the measured dominant cycle period}
      //
      //
      //
      //
   
      double Period_   = MathCeil(Value5[0]); 
      double Trendline = 0;///Period_ = IntPortion(Value5)
      double RealPart  = 0.0;
      double ImagPart  = 0.0;
      double DCPhase;
      for(count = 0;count<=Period_ - 1;count++)
      { 
         RealPart = RealPart + Price[i+count]*MathSin(360*count/Period_*Pi/180);
         ImagPart = ImagPart + Price[i+count]*MathCos(360*count/Period_*Pi/180); 
      }
         
      if (MathAbs(ImagPart) > 0.001) DCPhase = 180/Pi*MathArctan(RealPart / ImagPart);
      if (MathAbs(ImagPart) <= 0.001)
      {
        if (ImagPart>0) DCPhase =  90*RealPart;
        else            DCPhase = -90*RealPart;
      }
   
        DCPhase = DCPhase+90;
   
      if (ImagPart < 0)   DCPhase = DCPhase + 180;
      if (DCPhase  > 315) DCPhase = DCPhase - 360;
      SineWave[i] = MathSin(DCPhase*Pi/180);
      LeadSine[i] = MathSin((DCPhase+45)*Pi/180);
      
      //
      //
      //
      //
      //
      
      if (DrawPriceTrendLines == true)
      {
        trend[i] = trend[i+1];
        if (SineWave[i] < LeadSine[i] && SineWave[i+1] > LeadSine[i+1]) trend[i] = 1;
        if (SineWave[i] > LeadSine[i] && SineWave[i+1] < LeadSine[i+1]) trend[i] =-1;
        
        if(trend[i]>0)
        {
          Support[i] = Support[i+1];
          if (trend[i] != trend[i+1]) { Support[i] = Low[i]; sTime = Time[i]; }
            DrawPriceTrendLines(sTime, Time[i],Support[i],Support[i],Green,STYLE_SOLID);
        }               
            
        if(trend[i]<0)
        {
          Resistance[i] = Resistance[i+1];
          if (trend[i] != trend[i+1]) { Resistance[i] = High[i]; rTime = Time[i]; }
            DrawPriceTrendLines(rTime, Time[i],Resistance[i],Resistance[i],Red,STYLE_DOT);
        }               
     }    
}
return(0);
}

//
//
//
//
//

void DrawPriceTrendLines(datetime x1, datetime x2, double y1, double y2, color lineColor, double style)
{
    string label = "Support Resistance" + DoubleToStr(x1, 0);
    ObjectDelete(label);
    ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
       ObjectSet(label, OBJPROP_RAY, 0);
       ObjectSet(label, OBJPROP_COLOR, lineColor);
       ObjectSet(label, OBJPROP_STYLE, style);
       ObjectSet(label, OBJPROP_WIDTH, 3);
}


