//+------------------------------------------------------------------+
//|                                          FxVolumes_Highlight.mq4 |
//|                                               by FxVolumes  2016 |
//+------------------------------------------------------------------+
// indicator settings
#property  indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 13

// indicator buffers
double FxVolumesBuffer[];

double FxVolumesUpFxVBorder[];
double FxVolumesDownFxVBorder[];
double FxVolumesNeutralFxVBorder[];
double FxVolumesUpFxV[];
double FxVolumesDownFxV[];
double FxVolumesNeutralFxV[];

double FxVolumesUpFxVBorderLight[];
double FxVolumesDownFxVBorderLight[];
double FxVolumesNeutralFxVBorderLight[];
double FxVolumesUpFxVLight[];
double FxVolumesDownFxVLight[];
double FxVolumesNeutralFxVLight[];

// indicator parameters

enum INCREASE
{
	INCREASING_COLOR = 1,   // Higher VOL in Full Color
	NORMAL_COLOR = 0,   // Normal Bull Bear Color
};

int     BarWidthBorder       = 4;
int     BarWidth       = 2;

extern INCREASE Color_Mode = INCREASING_COLOR; // Increasing volume color

extern  color   BullColorBorder      = C'43,168,43';
extern  color   BearColorBorder      = C'230,0,0';
extern  color   NeutralColorBorder   = C'214,164,31';
extern  color   BullColor      = C'68,207,48';
extern  color   BearColor      = C'255,34,34';
extern  color   NeutralColor   = C'251,214,0';

extern  color   BullColorBorderLight      = C'177,243,177';
extern  color   BearColorBorderLight      = C'235,214,215';
extern  color   NeutralColorBorderLight   = Khaki;
extern  color   BullColorLight      = C'223,255,227';
extern  color   BearColorLight      = C'255,230,238';
extern  color   NeutralColorLight   = LightGoldenrod;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//indicator buffers mapping
   SetIndexBuffer(0,FxVolumesBuffer); 
         
   SetIndexBuffer(1,FxVolumesUpFxVBorder);
   SetIndexBuffer(2,FxVolumesDownFxVBorder);
   SetIndexBuffer(3,FxVolumesNeutralFxVBorder);       
   SetIndexBuffer(4,FxVolumesUpFxV);
   SetIndexBuffer(5,FxVolumesDownFxV);
   SetIndexBuffer(6,FxVolumesNeutralFxV);
          
   SetIndexBuffer(7,FxVolumesUpFxVBorderLight);
   SetIndexBuffer(8,FxVolumesDownFxVBorderLight);
   SetIndexBuffer(9,FxVolumesNeutralFxVBorderLight);       
   SetIndexBuffer(10,FxVolumesUpFxVLight);
   SetIndexBuffer(11,FxVolumesDownFxVLight);
   SetIndexBuffer(12,FxVolumesNeutralFxVLight);
   
//drawing settings
   SetIndexStyle(0,DRAW_NONE);
   
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,BarWidthBorder,BullColorBorder);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,BarWidthBorder,BearColorBorder);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,BarWidthBorder,NeutralColorBorder);
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth,BullColor);
   SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth,BearColor);
   SetIndexStyle(6,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth,NeutralColor);
   
   
   SetIndexStyle(7,DRAW_HISTOGRAM,STYLE_SOLID,BarWidthBorder,BullColorBorderLight);
   SetIndexStyle(8,DRAW_HISTOGRAM,STYLE_SOLID,BarWidthBorder,BearColorBorderLight);
   SetIndexStyle(9,DRAW_HISTOGRAM,STYLE_SOLID,BarWidthBorder,NeutralColorBorderLight);
   SetIndexStyle(10,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth,BullColorLight);
   SetIndexStyle(11,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth,BearColorLight);
   SetIndexStyle(12,DRAW_HISTOGRAM,STYLE_SOLID,BarWidth,NeutralColorLight);
   
//
   IndicatorDigits(0);   

   IndicatorShortName("FxVolumes");
   SetIndexLabel(0,"FxVolumes"); 
        
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);     
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);
   SetIndexLabel(6,NULL);
   
   SetIndexLabel(7,NULL);
   SetIndexLabel(8,NULL);
   SetIndexLabel(9,NULL);     
   SetIndexLabel(10,NULL);
   SetIndexLabel(11,NULL);
   SetIndexLabel(12,NULL);
   
//
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);       
   SetIndexEmptyValue(3,0.0);       
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);       
   SetIndexEmptyValue(6,0.0);  
      
   SetIndexEmptyValue(7,0.0);
   SetIndexEmptyValue(8,0.0);       
   SetIndexEmptyValue(9,0.0);       
   SetIndexEmptyValue(10,0.0);
   SetIndexEmptyValue(11,0.0);       
   SetIndexEmptyValue(12,0.0);       

   return(0);
  }
  
// Volumes
int start()
  {
   int    i,nLimit,FxV_Bars;
   
//bars count that does not changed after last indicator launch.
   FxV_Bars=IndicatorCounted();
   
//last counted bar will be recounted
   if(FxV_Bars>0) FxV_Bars--;
   nLimit=Bars-FxV_Bars;
   
//
   for(i=0; i<nLimit; i++)
     {
      double FxVolumes=Volume[i];
      // if(i==Bars-1 || FxVolumes>Volume[i+1])
        if      (Close[i] > Open[i] && Volume[i] >= Volume[i+Color_Mode])
        {
         FxVolumesBuffer[i]=FxVolumes;
         
         FxVolumesUpFxVBorder[i]=FxVolumes;
         FxVolumesDownFxVBorder[i]=0.0; 
         FxVolumesNeutralFxVBorder[i]=0.0;
         FxVolumesUpFxV[i]=FxVolumes;
         FxVolumesDownFxV[i]=0.0; 
         FxVolumesNeutralFxV[i]=0.0;
         
         FxVolumesUpFxVBorderLight[i]=0.0;
         FxVolumesDownFxVBorderLight[i]=0.0; 
         FxVolumesNeutralFxVBorderLight[i]=0.0;
         FxVolumesUpFxVLight[i]=0.0;
         FxVolumesDownFxVLight[i]=0.0; 
         FxVolumesNeutralFxVLight[i]=0.0;
        }
        
        else if (Close[i] > Open[i] && Volume[i] <= Volume[i+Color_Mode])
        {
         FxVolumesBuffer[i]=FxVolumes;
         
         FxVolumesUpFxVBorder[i]=0.0;
         FxVolumesDownFxVBorder[i]=0.0; 
         FxVolumesNeutralFxVBorder[i]=0.0;
         FxVolumesUpFxV[i]=0.0;
         FxVolumesDownFxV[i]=0.0; 
         FxVolumesNeutralFxV[i]=0.0;
         
         FxVolumesUpFxVBorderLight[i]=FxVolumes;
         FxVolumesDownFxVBorderLight[i]=0.0; 
         FxVolumesNeutralFxVBorderLight[i]=0.0;
         FxVolumesUpFxVLight[i]=FxVolumes;
         FxVolumesDownFxVLight[i]=0.0; 
         FxVolumesNeutralFxVLight[i]=0.0;
        }
      //else 
        else if (Close[i] < Open[i] && Volume[i] >= Volume[i+Color_Mode])
        {
         FxVolumesBuffer[i]=FxVolumes;
         
         FxVolumesUpFxVBorder[i]=0.0;
         FxVolumesDownFxVBorder[i]=FxVolumes;   
         FxVolumesNeutralFxVBorder[i]=0.0;
         FxVolumesUpFxV[i]=0.0;
         FxVolumesDownFxV[i]=FxVolumes;   
         FxVolumesNeutralFxV[i]=0.0;  
         
         FxVolumesUpFxVBorderLight[i]=0.0;
         FxVolumesDownFxVBorderLight[i]=0.0;   
         FxVolumesNeutralFxVBorderLight[i]=0.0;
         FxVolumesUpFxVLight[i]=0.0;
         FxVolumesDownFxVLight[i]=0.0;   
         FxVolumesNeutralFxVLight[i]=0.0;     
        } 
        else if (Close[i] < Open[i] && Volume[i] <= Volume[i+Color_Mode])
        {
         FxVolumesBuffer[i]=FxVolumes;
         
         FxVolumesUpFxVBorder[i]=0.0;
         FxVolumesDownFxVBorder[i]=0.0;   
         FxVolumesNeutralFxVBorder[i]=0.0;
         FxVolumesUpFxV[i]=0.0;
         FxVolumesDownFxV[i]=0.0;   
         FxVolumesNeutralFxV[i]=0.0;  
         
         FxVolumesUpFxVBorderLight[i]=0.0;
         FxVolumesDownFxVBorderLight[i]=FxVolumes;   
         FxVolumesNeutralFxVBorderLight[i]=0.0;
         FxVolumesUpFxVLight[i]=0.0;
         FxVolumesDownFxVLight[i]=FxVolumes;   
         FxVolumesNeutralFxVLight[i]=0.0;     
        } 
        else
        {
         FxVolumesBuffer[i]=FxVolumes;
         FxVolumesUpFxVBorder[i]=0.0;
         FxVolumesDownFxVBorder[i]=0.0;   
         FxVolumesNeutralFxVBorder[i]=FxVolumes; 
         FxVolumesUpFxV[i]=0.0;
         FxVolumesDownFxV[i]=0.0;   
         FxVolumesNeutralFxV[i]=FxVolumes; 
        }
      
      
     }        
// done
   return(0);
  }
//+---+

