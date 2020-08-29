//+------------------------------------------------------------------+
//|mtf jurik STLM_hist.mq4 
//| 
//+------------------------------------------------------------------+

#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"


#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     LimeGreen
#property indicator_color2     LimeGreen
#property indicator_color3     Red
#property indicator_color4     Red
#property indicator_color5     Silver
#property indicator_width1     2
#property indicator_width3     2
#property indicator_width5     2
#property indicator_levelcolor MediumOrchid

//
//
//
//
//

extern string TimeFrame                 = "Current time frame";
extern int    StlmLength                = 5;
extern double StlmPhase                 = 0;
extern bool   StlmDouble                = true;
extern int    StlmPrice                 = 0;
extern int    AtrAverageMethod          = 16;
extern bool   divergenceVisible         = true;
extern bool   divergenceOnValuesVisible = true;
extern bool   divergenceOnChartVisible  = false;
extern color  divergenceBullishColor    = Navy;
extern color  divergenceBearishColor    = Magenta;
extern string divergenceUniqueID        = "jurik stlm diverge1";
extern bool   HistogramOnSlope          = true;
extern bool   Interpolate               = true;

extern bool   alertsOn                  = true;
extern bool   alertsOnSlope             = true;
extern bool   alertsOnCurrent           = false;
extern bool   alertsMessage             = true;
extern bool   alertsSound               = true;
extern bool   alertsEmail               = false;

extern bool   arrowsVisible             = true;
extern bool   arrowsOnSlope             = true;
extern string arrowsIdentifier          = "jurik stlm arrows1";
extern double arrowsDisplacement        = 1.0;
extern color  arrowsUpColor             = LimeGreen;
extern color  arrowsDnColor             = Red;
extern int    arrowsUpCode              = 241;
extern int    arrowsDnCode              = 242;

extern string __0                       = "SMA";
extern string __1                       = "EMA";
extern string __2                       = "Double smoothed EMA";
extern string __3                       = "Double EMA (DEMA)";
extern string __4                       = "Triple EMA (TEMA)";
extern string __5                       = "Smoothed MA";
extern string __6                       = "Linear weighted MA";
extern string __7                       = "Parabolic weighted MA";
extern string __8                       = "Alexander MA";
extern string __9                       = "Volume weighted MA";
extern string __10                      = "Hull MA";
extern string __11                      = "Triangular MA";
extern string __12                      = "Sine weighted MA";
extern string __13                      = "Linear regression";
extern string __14                      = "IE/2";
extern string __15                      = "NonLag MA";
extern string __16                      = "Zero lag EMA";
extern string __17                      = "Leader EMA";

//
//
//
//
//

double Upa[];
double Upb[];
double Dna[];
double Dnb[];
double stlm[];
double price[];
double atr[];
double work[];
double trend[];
double slope[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;
string shortName;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
// 
//
//
//
//

int init()
  {
   IndicatorBuffers(8);
   SetIndexBuffer(0,Upa);   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Upb);   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Dna);   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,Dnb);   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,stlm);
   SetIndexBuffer(5,price);
   SetIndexBuffer(6,atr);
   SetIndexBuffer(7,work);
   
   SetLevelValue(0,0);
   
      //
      //
      //
      //
      //
   
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      calculateValue    = (TimeFrame=="calculateValue");
      if (calculateValue)
      {
         int s = StringFind(divergenceUniqueID,":",0);
               shortName = divergenceUniqueID;
               divergenceUniqueID = StringSubstr(divergenceUniqueID,0,s);
               return(0);
      }            
      timeFrame = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
      
      shortName = divergenceUniqueID+": "+timeFrameToString(timeFrame)+ " atr of "+getAverageName(AtrAverageMethod)+" adaptive jurik stlm";
   IndicatorShortName(shortName);
return(0);
}

//
//
//
//
//
   
int deinit()
{
   
   int lookForLength = StringLen(divergenceUniqueID);
   
   for (int i=ObjectsTotal()-1; i>=0; i--) {
   
   string objectName = ObjectName(i);
   if (StringSubstr(objectName,0,lookForLength) == divergenceUniqueID) ObjectDelete(objectName);
   
   }
   
   if (!calculateValue && arrowsVisible) deleteArrows();
   
return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars)  { Upa[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {   

     if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);
     if (ArrayRange(slope,0)!=Bars) ArrayResize(slope,Bars);   
     for (i=limit, r=Bars-i-1; i >= 0; i--,r++)
     { 
        price[i] = getPrice(StlmPrice,i);
        work[i]  = iCustomMa(AtrAverageMethod,MathMax(High[i],Close[i+1])-MathMin(Low[i],Close[i+1]),StlmLength,i,2);
         double max = work[ArrayMaximum(work,StlmLength,i)];
         double min = work[ArrayMinimum(work,StlmLength,i)];
         if (min!=max)
               atr[i] = 1.0-(work[i]-min)/(max-min);
         else  atr[i] = 0.5;
         
        double   value1 =
  0.0982862174 * price[i+0]
+ 0.0975682269 * price[i+1]
+ 0.0961401078 * price[i+2]
+ 0.0940230544 * price[i+3]
+ 0.0912437090 * price[i+4]
+ 0.0878391006 * price[i+5]
+ 0.0838544303 * price[i+6]
+ 0.0793406350 * price[i+7]
+ 0.0743569346 * price[i+8]
+ 0.0689666682 * price[i+9]
+ 0.0632381578 * price[i+10]
+ 0.0572428925 * price[i+11]
+ 0.0510534242 * price[i+12]
+ 0.0447468229 * price[i+13]
+ 0.0383959950 * price[i+14]
+ 0.0320735368 * price[i+15]
+ 0.0258537721 * price[i+16]
+ 0.0198005183 * price[i+17]
+ 0.0139807863 * price[i+18]
+ 0.0084512448 * price[i+19]
+ 0.0032639979 * price[i+20]
- 0.0015350359 * price[i+21]
- 0.0059060082 * price[i+22]
- 0.0098190256 * price[i+23]
- 0.0132507215 * price[i+24]
- 0.0161875265 * price[i+25]
- 0.0186164872 * price[i+26]
- 0.0205446727 * price[i+27]
- 0.0219739146 * price[i+28]
- 0.0229204861 * price[i+29]
- 0.0234080863 * price[i+30]
- 0.0234566315 * price[i+31]
- 0.0231017777 * price[i+32]
- 0.0223796900 * price[i+33]
- 0.0213300463 * price[i+34]
- 0.0199924534 * price[i+35]
- 0.0184126992 * price[i+36]
- 0.0166377699 * price[i+37]
- 0.0147139428 * price[i+38]
- 0.0126796776 * price[i+39]
- 0.0105938331 * price[i+40]
- 0.0084736770 * price[i+41]
- 0.0063841850 * price[i+42]
- 0.0043466731 * price[i+43]
- 0.0023956944 * price[i+44]
- 0.0005535180 * price[i+45]
+ 0.0011421469 * price[i+46]
+ 0.0026845693 * price[i+47]
+ 0.0040471369 * price[i+48]
+ 0.0052380201 * price[i+49]
+ 0.0062194591 * price[i+50]
+ 0.0070340085 * price[i+51]
+ 0.0076266453 * price[i+52]
+ 0.0080376628 * price[i+53]
+ 0.0083037666 * price[i+54]
+ 0.0083694798 * price[i+55]
+ 0.0082901022 * price[i+56]
+ 0.0080741359 * price[i+57]
+ 0.0077543820 * price[i+58]
+ 0.0073260526 * price[i+59]
+ 0.0068163569 * price[i+60]
+ 0.0062325477 * price[i+61]
+ 0.0056078229 * price[i+62]
+ 0.0049516078 * price[i+63]
+ 0.0161380976 * price[i+64];
  
             double value2 =    
- 0.0074151919 * price[i+0]
- 0.0060698985 * price[i+1]
- 0.0044979052 * price[i+2]
- 0.0027054278 * price[i+3]
- 0.0007031702 * price[i+4]
+ 0.0014951741 * price[i+5]
+ 0.0038713513 * price[i+6]
+ 0.0064043271 * price[i+7]
+ 0.0090702334 * price[i+8]
+ 0.0118431116 * price[i+9]
+ 0.0146922652 * price[i+10]
+ 0.0175884606 * price[i+11]
+ 0.0204976517 * price[i+12]
+ 0.0233865835 * price[i+13]
+ 0.0262218588 * price[i+14]
+ 0.0289681736 * price[i+15]
+ 0.0315922931 * price[i+16]
+ 0.0340614696 * price[i+17]
+ 0.0363444061 * price[i+18]
+ 0.0384120882 * price[i+19]
+ 0.0402373884 * price[i+20]
+ 0.0417969735 * price[i+21]
+ 0.0430701377 * price[i+22]
+ 0.0440399188 * price[i+23]
+ 0.0446941124 * price[i+24]
+ 0.0450230100 * price[i+25]
+ 0.0450230100 * price[i+26]
+ 0.0446941124 * price[i+27]
+ 0.0440399188 * price[i+28]
+ 0.0430701377 * price[i+29]
+ 0.0417969735 * price[i+30]
+ 0.0402373884 * price[i+31]
+ 0.0384120882 * price[i+32]
+ 0.0363444061 * price[i+33]
+ 0.0340614696 * price[i+34]
+ 0.0315922931 * price[i+35]
+ 0.0289681736 * price[i+36]
+ 0.0262218588 * price[i+37]
+ 0.0233865835 * price[i+38]
+ 0.0204976517 * price[i+39]
+ 0.0175884606 * price[i+40]
+ 0.0146922652 * price[i+41]
+ 0.0118431116 * price[i+42]
+ 0.0090702334 * price[i+43]
+ 0.0064043271 * price[i+44]
+ 0.0038713513 * price[i+45]
+ 0.0014951741 * price[i+46]
- 0.0007031702 * price[i+47]
- 0.0027054278 * price[i+48]
- 0.0044979052 * price[i+49]
- 0.0060698985 * price[i+50]
- 0.0074151919 * price[i+51]
- 0.0085278517 * price[i+52]
- 0.0094111161 * price[i+53]
- 0.0100658241 * price[i+54]
- 0.0104994302 * price[i+55]
- 0.0107227904 * price[i+56]
- 0.0107450280 * price[i+57]
- 0.0105824763 * price[i+58]
- 0.0102517019 * price[i+59]
- 0.0097708805 * price[i+60]
- 0.0091581551 * price[i+61]
- 0.0084345004 * price[i+62]
- 0.0076214397 * price[i+63]
- 0.0067401718 * price[i+64]
- 0.0058083144 * price[i+65]
- 0.0048528295 * price[i+66]
- 0.0038816271 * price[i+67]
- 0.0029244713 * price[i+68]
- 0.0019911267 * price[i+69]
- 0.0010974211 * price[i+70]
- 0.0002535559 * price[i+71]
+ 0.0005231953 * price[i+72]
+ 0.0012297491 * price[i+73]
+ 0.0018539149 * price[i+74]
+ 0.0023994354 * price[i+75]
+ 0.0028490136 * price[i+76]
+ 0.0032221429 * price[i+77]
+ 0.0034936183 * price[i+78]
+ 0.0036818974 * price[i+79]
+ 0.0038037944 * price[i+80]
+ 0.0038338964 * price[i+81]
+ 0.0037975350 * price[i+82]
+ 0.0036986051 * price[i+83]
+ 0.0035521320 * price[i+84]
+ 0.0033559226 * price[i+85]
+ 0.0031224409 * price[i+86]
+ 0.0031224409 * price[i+87]
+ 0.0025688349 * price[i+88]
+ 0.0022682355 * price[i+89]
+ 0.0073925495 * price[i+90];

      stlm[i]  = iDSmooth(value1-value2,StlmLength*(atr[i]+ 1.0)/2.0,StlmPhase,StlmDouble,i); 
      Upa[i]   = EMPTY_VALUE;
      Upb[i]   = EMPTY_VALUE;
      Dna[i]   = EMPTY_VALUE;
      Dnb[i]   = EMPTY_VALUE;
      trend[r] = trend[r-1];
      slope[r] = slope[r-1];
      if (stlm[i] > 0)         trend[r] =  1;
      if (stlm[i] < 0)         trend[r] = -1;
      if (stlm[i] > stlm[i+1]) slope[r] =  1;
      if (stlm[i] < stlm[i+1]) slope[r] = -1;
                
      if (divergenceVisible)
      {
         CatchBullishDivergence(stlm,i);
         CatchBearishDivergence(stlm,i);
      }
                                     
      if (HistogramOnSlope)
      {
         if (trend[r]== 1 && slope[r] == 1) Upa[i] = stlm[i];
         if (trend[r]== 1 && slope[r] ==-1) Upb[i] = stlm[i];
         if (trend[r]==-1 && slope[r] ==-1) Dna[i] = stlm[i];
         if (trend[r]==-1 && slope[r] == 1) Dnb[i] = stlm[i];
      }
      else
      {                  
         if (trend[r]== 1) Upa[i] = stlm[i];
         if (trend[r]==-1) Dna[i] = stlm[i];
        
      }
      
      manageArrow(i,r);
               
  }
  manageAlerts();
  return(0);
  }   
  
  //
  //
  //
  //
  //

  limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
  if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);
  if (ArrayRange(slope,0)!=Bars) ArrayResize(slope,Bars);   
    for (i=limit, r=Bars-i-1; i>=0; i--,r++)
    { 
       int y = iBarShift(NULL,timeFrame,Time[i]);
          stlm[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",StlmLength,StlmPhase,StlmDouble,StlmPrice,AtrAverageMethod,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,Interpolate,4,y);
          Upa[i]  = EMPTY_VALUE;
          Upb[i]  = EMPTY_VALUE;
          Dna[i]  = EMPTY_VALUE;
          Dnb[i]  = EMPTY_VALUE;
          
          trend[r] = trend[r-1];
          slope[r] = slope[r-1];
          if (stlm[i] > 0)         trend[r] =  1;
          if (stlm[i] < 0)         trend[r] = -1;
          if (stlm[i] > stlm[i+1]) slope[r] =  1;
          if (stlm[i] < stlm[i+1]) slope[r] = -1;
                                     
          if (HistogramOnSlope)
          {
            if (trend[r]== 1 && slope[r] == 1) Upa[i] = stlm[i];
            if (trend[r]== 1 && slope[r] ==-1) Upb[i] = stlm[i];
            if (trend[r]==-1 && slope[r] ==-1) Dna[i] = stlm[i];
            if (trend[r]==-1 && slope[r] == 1) Dnb[i] = stlm[i];
          }
          else
          {                  
            if (trend[r]== 1) Upa[i] = stlm[i];
            if (trend[r]==-1) Dna[i] = stlm[i];
            
          }
          
          manageArrow(i,r);

          //
          //
          //
          //
          //
          //
                
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for (int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for (int k = 1; k < n; k++)
            {
               stlm[i+k] = stlm[i] + (stlm[i+n] - stlm[i]) * k/n;
                  if (Upa[i]!= EMPTY_VALUE) Upa[i+k] = stlm[i+k];
                  if (Upb[i]!= EMPTY_VALUE) Upb[i+k] = stlm[i+k];
                  if (Dna[i]!= EMPTY_VALUE) Dna[i+k] = stlm[i+k];
                  if (Dnb[i]!= EMPTY_VALUE) Dnb[i+k] = stlm[i+k];
            }
           
      }
  manageAlerts();
return(0);
} 

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double getPrice(int type, int i)
{
   switch (type)
   {
      case 7:     return((Open[i]+Close[i])/2.0);
      case 8:     return((Open[i]+High[i]+Low[i]+Close[i])/4.0);
      default :   return(iMA(NULL,0,1,0,MODE_SMA,type,i));
   }      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double wrk[][20];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0)
{
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

return(wrk[r][4+s]);
}

//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = Bars-iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar))-1;
      if (trend[whichBar] != trend[whichBar-1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
         
      //
      //
      //
      //
      //
      
      if (alertsOnSlope)
      {
         if (slope[whichBar] != slope[whichBar-1])
         {
            if (slope[whichBar] == 1) doAlert(whichBar,"slope changed to up");
            if (slope[whichBar] ==-1) doAlert(whichBar,"slope changed to down");
         }         
      }
      else
      {
         if (trend[whichBar] != trend[whichBar-1])
         {
            if (trend[whichBar] == 1) doAlert(whichBar,"crossed zero line up");
            if (trend[whichBar] ==-1) doAlert(whichBar,"crossed zero line down");
         }         
       }
       
      }         
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," stlm oscillator ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"stlm"),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageArrow(int i, int r)
{
   if (!calculateValue && arrowsVisible)
   {
      deleteArrow(Time[i]);
      if(arrowsOnSlope)
      {
      
         if (slope[r] != slope[r-1])
         {
            if (slope[r] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
            if (slope[r] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
         }         
      }
      else
      {
         if (trend[r] != trend[r-1])
         {
            if (trend[r] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
            if (trend[r] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
         }  
      }         
   }         
}       

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsDisplacement * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsDisplacement * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

void CatchBullishDivergence(double& values[], int i)
{
   i++;
            ObjectDelete(divergenceUniqueID+"l"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"l"+"os" + DoubleToStr(Time[i],0));            
   if (!IsIndicatorLow(values,i)) return;  

   //
   //
   //
   //
   //

   int currentLow = i;
   int lastLow    = GetIndicatorLastLow(values,i+1);
      if (values[currentLow] > values[lastLow] && Low[currentLow] < Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],divergenceBullishColor,STYLE_SOLID);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow],divergenceBullishColor,STYLE_SOLID);
      }
      if (values[currentLow] < values[lastLow] && Low[currentLow] > Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow], divergenceBullishColor, STYLE_DOT);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow], divergenceBullishColor, STYLE_DOT);
      }
}

//
//
//
//
//

void CatchBearishDivergence(double& values[], int i)
{
   i++; 
            ObjectDelete(divergenceUniqueID+"h"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"h"+"os" + DoubleToStr(Time[i],0));            
   if (IsIndicatorPeak(values,i) == false) return;

   //
   //
   //
   //
   //
      
   int currentPeak = i;
   int lastPeak = GetIndicatorLastPeak(values,i+1);
      if (values[currentPeak] < values[lastPeak] && High[currentPeak]>High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],divergenceBearishColor,STYLE_SOLID);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak],divergenceBearishColor,STYLE_SOLID);
      }
      if(values[currentPeak] > values[lastPeak] && High[currentPeak] < High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak], divergenceBearishColor, STYLE_DOT);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak], divergenceBearishColor, STYLE_DOT);
      }
}

//
//
//
//
//

bool IsIndicatorPeak(double& values[], int i) { return(values[i] >= values[i+1] && values[i] > values[i+2] && values[i] > values[i-1]); }
bool IsIndicatorLow( double& values[], int i) { return(values[i] <= values[i+1] && values[i] < values[i+2] && values[i] < values[i-1]); }

//
//
//
//
//

int GetIndicatorLastPeak(double& values[], int shift)
{
   for(int i = shift+5; i<Bars; i++)
         if (values[i] >= values[i+1] && values[i] > values[i+2] && values[i] >= values[i-1] && values[i] > values[i-2]) return(i);
   return(-1);
}

//
//
//
//
//

int GetIndicatorLastLow(double& values[], int shift)
{
   for(int i = shift+5; i<Bars; i++)
         if (values[i] <= values[i+1] && values[i] < values[i+2] && values[i] <= values[i-1] && values[i] < values[i-2]) return(i);
   return(-1);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string   label = divergenceUniqueID+first+"os"+DoubleToStr(t1,0);
   if (Interpolate) t2 += Period()*60-1;
    
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//
//
//
//
//

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = WindowFind(shortName);
   if (indicatorWindow < 0) return;
   if (Interpolate) t2 += Period()*60-1;
   
   string label = divergenceUniqueID+first+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs) {
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str) {
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--) {
      int char = StringGetChar(s, length);
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                     s = StringSetChar(s, length, char - 32);
         else if(char > -33 && char < 0)
                     s = StringSetChar(s, length, char + 224);
   }
   return(s);
}      
      
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

string methodNames[] = {"SMA","EMA","Double smoothed EMA","Double EMA","Triple EMA","Smoothed MA","Linear weighted MA","Parabolic weighted MA","Alexander MA","Volume weghted MA","Hull MA","Triangular MA","Sine weighted MA","Linear regression","IE/2","NonLag MA","Zero lag EMA","Leader EMA"};
string getAverageName(int& method)
{
   int max = ArraySize(methodNames)-1;
      method=MathMax(MathMin(method,max),0); return(methodNames[method]);
}

//
//
//
//
//

#define _maWorkBufferx1 3
#define _maWorkBufferx2 6
#define _maWorkBufferx3 9

double iCustomMa(int mode, double price, double length, int i, int instanceNo=0)
{
   int r = Bars-i-1;
   switch (mode)
   {
      case 0  : return(iSma(price,length,r,instanceNo));
      case 1  : return(iEma(price,length,r,instanceNo));
      case 2  : return(iDsema(price,length,r,instanceNo));
      case 3  : return(iDema(price,length,r,instanceNo));
      case 4  : return(iTema(price,length,r,instanceNo));
      case 5  : return(iSmma(price,length,r,instanceNo));
      case 6  : return(iLwma(price,length,r,instanceNo));
      case 7  : return(iLwmp(price,length,r,instanceNo));
      case 8  : return(iAlex(price,length,r,instanceNo));
      case 9  : return(iWwma(price,length,r,instanceNo));
      case 10 : return(iHull(price,length,r,instanceNo));
      case 11 : return(iTma(price,length,r,instanceNo));
      case 12 : return(iSineWMA(price,length,r,instanceNo));
      case 13 : return(iLinr(price,length,r,instanceNo));
      case 14 : return(iIe2(price,length,r,instanceNo));
      case 15 : return(iNonLagMa(price,length,r,instanceNo));
      case 16 : return(iZeroLag(price,length,r,instanceNo));
      case 17 : return(iLeader(price,length,r,instanceNo));
      default : return(0);
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= Bars) ArrayResize(workDsema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]);
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workDema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= Bars) ArrayResize(workDema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workDema[r][_ema1+instanceNo] = workDema[r-1][_ema1+instanceNo]+alpha*(price                        -workDema[r-1][_ema1+instanceNo]);
          workDema[r][_ema2+instanceNo] = workDema[r-1][_ema2+instanceNo]+alpha*(workDema[r][_ema1+instanceNo]-workDema[r-1][_ema2+instanceNo]);
   return(workDema[r][_ema1+instanceNo]*2.0-workDema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _ema1 0
#define _ema2 1
#define _ema3 2

double iTema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= Bars) ArrayResize(workTema,Bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workTema[r][_ema1+instanceNo] = workTema[r-1][_ema1+instanceNo]+alpha*(price                        -workTema[r-1][_ema1+instanceNo]);
          workTema[r][_ema2+instanceNo] = workTema[r-1][_ema2+instanceNo]+alpha*(workTema[r][_ema1+instanceNo]-workTema[r-1][_ema2+instanceNo]);
          workTema[r][_ema3+instanceNo] = workTema[r-1][_ema3+instanceNo]+alpha*(workTema[r][_ema2+instanceNo]-workTema[r-1][_ema3+instanceNo]);
   return(workTema[r][_ema3+instanceNo]+3.0*(workTema[r][_ema1+instanceNo]-workTema[r][_ema2+instanceNo]));
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workLwmp[][_maWorkBufferx1];
double iLwmp(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwmp,0)!= Bars) ArrayResize(workLwmp,Bars);
   
   //
   //
   //
   //
   //
   
   workLwmp[r][instanceNo] = price;
      double sumw = period*period;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (period-k)*(period-k);
                sumw  += weight;
                sum   += weight*workLwmp[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workAlex[][_maWorkBufferx1];
double iAlex(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workAlex,0)!= Bars) ArrayResize(workAlex,Bars);
   if (period<4) return(price);
   
   //
   //
   //
   //
   //

   workAlex[r][instanceNo] = price;
      double sumw = period-2;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k-2;
                sumw  += weight;
                sum   += weight*workAlex[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workTma[][_maWorkBufferx1];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTma,0)!= Bars) ArrayResize(workTma,Bars);
   
   //
   //
   //
   //
   //
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workSineWMA[][_maWorkBufferx1];
#define Pi 3.14159265358979323846264338327950288

double iSineWMA(double price, int period, int r, int instanceNo=0)
{
   if (period<1) return(price);
   if (ArrayRange(workSineWMA,0)!= Bars) ArrayResize(workSineWMA,Bars);
   
   //
   //
   //
   //
   //
   
   workSineWMA[r][instanceNo] = price;
      double sum  = 0;
      double sumw = 0;
  
      for(int k=0; k<period && (r-k)>=0; k++)
      { 
         double weight = MathSin(Pi*(k+1.0)/(period+1.0));
                sumw  += weight;
                sum   += weight*workSineWMA[r-k][instanceNo]; 
      }
      return(sum/sumw);
}

//
//
//
//
//

double workWwma[][_maWorkBufferx1];
double iWwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workWwma,0)!= Bars) ArrayResize(workWwma,Bars);
   
   //
   //
   //
   //
   //
   
   workWwma[r][instanceNo] = price;
      int    i    = Bars-r-1;
      double sumw = Volume[i];
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = Volume[i+k];
                sumw  += weight;
                sum   += weight*workWwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workHull[][_maWorkBufferx2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars);

   //
   //
   //
   //
   //

      int HmaPeriod  = MathMax(period,2);
      int HalfPeriod = MathFloor(HmaPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= Bars) ArrayResize(workLinr,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}

//
//
//
//
//

double workIe2[][_maWorkBufferx1];
double iIe2(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workIe2,0)!= Bars) ArrayResize(workIe2,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workIe2[r][instanceNo] = price;
         double sumx=0, sumxx=0, sumxy=0, sumy=0;
         for (int k=0; k<period; k++)
         {
            price = workIe2[r-k][instanceNo];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
         }
         double slope   = (period*sumxy - sumx*sumy)/(sumx*sumx-period*sumxx);
         double average = sumy/period;
   return(((average+slope)+(sumy+slope*sumx)/period)/2.0);
}

//
//
//
//
//

double workLeader[][_maWorkBufferx2];
double iLeader(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLeader,0)!= Bars) ArrayResize(workLeader,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      double alpha = 2.0/(period+1.0);
         workLeader[r][instanceNo  ] = workLeader[r-1][instanceNo  ]+alpha*(price                          -workLeader[r-1][instanceNo  ]);
         workLeader[r][instanceNo+1] = workLeader[r-1][instanceNo+1]+alpha*(price-workLeader[r][instanceNo]-workLeader[r-1][instanceNo+1]);

   return(workLeader[r][instanceNo]+workLeader[r][instanceNo+1]);
}

//
//
//
//
//

double workZl[][_maWorkBufferx2];
#define _price 0
#define _zlema 1

double iZeroLag(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workZl,0)!=Bars) ArrayResize(workZl,Bars); instanceNo *= 2;

   //
   //
   //
   //
   //

   double alpha = 2.0/(1.0+length); 
   int    per   = (length-1.0)/2.0; 

   workZl[r][_price+instanceNo] = price;
   if (r<per)
          workZl[r][_zlema+instanceNo] = price;
   else   workZl[r][_zlema+instanceNo] = workZl[r-1][_zlema+instanceNo]+alpha*(2.0*price-workZl[r-per][_price+instanceNo]-workZl[r-1][_zlema+instanceNo]);
   return(workZl[r][_zlema+instanceNo]);
}

//
//
//
//
//

#define Pi       3.14159265358979323846264338327950288
#define _length  0
#define _len     1
#define _weight  2

double  nlm.values[3][_maWorkBufferx1];
double  nlm.prices[ ][_maWorkBufferx1];
double  nlm.alphas[ ][_maWorkBufferx1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(nlm.prices,0) != Bars) ArrayResize(nlm.prices,Bars);
                               nlm.prices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlm.prices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlm.values[_length][instanceNo] != length)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlm.values[_length][instanceNo] = length;
         nlm.values[_len   ][instanceNo] = length*4 + Phase;  
         nlm.values[_weight][instanceNo] = 0;

         if (ArrayRange(nlm.alphas,0) < nlm.values[_len][instanceNo]) ArrayResize(nlm.alphas,nlm.values[_len][instanceNo]);
         for (int k=0; k<nlm.values[_len][instanceNo]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlm.alphas[k][instanceNo]        = g * beta;
            nlm.values[_weight][instanceNo] += nlm.alphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlm.values[_weight][instanceNo]>0)
   {
      double sum = 0;
           for (k=0; k < nlm.values[_len][instanceNo]; k++) sum += nlm.alphas[k][instanceNo]*nlm.prices[r-k][instanceNo];
           return( sum / nlm.values[_weight][instanceNo]);
   }
   else return(0);           
}      
   
      


