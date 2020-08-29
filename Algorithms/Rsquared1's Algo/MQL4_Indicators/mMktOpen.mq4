//   mMktOpen.mq4

#property indicator_chart_window

extern bool NY=true;
extern bool London=true;
extern bool Auckland=false;
extern bool Sydney=false;
extern bool Tokyo=false;
extern bool HongKong=false;
extern bool t30MinAdvanceNotice=true;     //display dashed line 30 minutes before opening?

//Data provider times for openings
extern int NYOpenDataTime=15;       //Alpari = 14, FXDD = 15
extern int LondonOpenDataTime=10;
extern int AucklandOpenDataTime=23;
extern int SydneyOpenDataTime=1;
extern int TokyoOpenDataTime=2;
extern int HongKongOpenDataTime=3;

extern color NYColor=Sienna;
extern color LondonColor=SeaGreen;
extern color AucklandColor=Khaki;
extern color SydneyColor=Teal;
extern color TokyoColor=Aqua;
extern color HKColor=Yellow;

double val1,val2;

int deinit()
  {
   int bars_count=BarsPerWindow(), i;
   for (i=0;i<bars_count;i++)
      {
      ObjectDelete("MMt"+DoubleToStr(i,0));
      ObjectDelete("MMl"+DoubleToStr(i,0));
      }
   return(0);
  }
//----------------------------------------------------------------------------------------
int start()
   {
   int counted_bars=IndicatorCounted();
   int bars_count=BarsPerWindow(),i,h,m;
   bool drawvl;
   if (Period()>PERIOD_H1) 
      {
         return(0);    //If time > 1 hour clutters up screen
      }
   for (i=0;i<bars_count;i++)
      {
      ObjectDelete("MMt"+DoubleToStr(i,0));
      ObjectDelete("MMl"+DoubleToStr(i,0));
      }
   for (i=0;i<bars_count;i++)
      {
         drawvl=false;
         h=TimeHour(Time[i]);
         m=TimeMinute(Time[i]);
         if (London==true)
            {
               if ((h==LondonOpenDataTime) && (m==0)) {drawvl=true;VerticalLine("LO",i,STYLE_SOLID,LondonColor);}
               if ((h==TimeAdjust(LondonOpenDataTime,0)) && (m==0)) {drawvl=true;VerticalLine("LC",i,STYLE_DASH,LondonColor);}
               if (t30MinAdvanceNotice==true)
                  {
                     if ((h==TimeAdjust(LondonOpenDataTime,1)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,LondonColor);}
                     if ((h==TimeAdjust(LondonOpenDataTime,2)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,LondonColor);}
                  }
            }
         if (NY==true)
            {
               if ((h==NYOpenDataTime) && (m==0)) {drawvl=true;VerticalLine("NYO",i,STYLE_SOLID,NYColor);}
               if ((h==TimeAdjust(NYOpenDataTime,0)) && (m==0)) {drawvl=true;VerticalLine("NYC",i,STYLE_DASH,NYColor);}
               if (t30MinAdvanceNotice==true)
                  {
                     if ((h==TimeAdjust(NYOpenDataTime,1)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,NYColor);}
                     if ((h==TimeAdjust(NYOpenDataTime,2)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,NYColor);}
                  }

            }
         if (Auckland==true)
            {
               if ((h==AucklandOpenDataTime) && (m==0)) {drawvl=true;VerticalLine("Auck O",i,STYLE_SOLID,AucklandColor);}
               if ((h==TimeAdjust(AucklandOpenDataTime,0)) && (m==0)) {drawvl=true;VerticalLine("Auck C",i,STYLE_DASH,AucklandColor);}
               if (t30MinAdvanceNotice==true)
                  {
                     if ((h==TimeAdjust(AucklandOpenDataTime,1)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,AucklandColor);}
                     if ((h==TimeAdjust(AucklandOpenDataTime,2)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,AucklandColor);}
                  }
            }
         if (Sydney==true)
            {
               if ((h==SydneyOpenDataTime) && (m==0)) {drawvl=true;VerticalLine("Syd O",i,STYLE_SOLID,SydneyColor);}
               if ((h==TimeAdjust(SydneyOpenDataTime,0)) && (m==0)) {drawvl=true;VerticalLine("Syd C",i,STYLE_DASH,SydneyColor);}
               if (t30MinAdvanceNotice==true)
                  {
                     if ((h==TimeAdjust(SydneyOpenDataTime,1)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,SydneyColor);}
                     if ((h==TimeAdjust(SydneyOpenDataTime,2)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,SydneyColor);}
                  }
            }
         if (Tokyo==true)
            {
               if ((h==TokyoOpenDataTime) && (m==0)) {drawvl=true;VerticalLine("Tokyo O",i,STYLE_SOLID,TokyoColor);}
               if ((h==TimeAdjust(TokyoOpenDataTime,0)) && (m==0)) {drawvl=true;VerticalLine("Tokyo C",i,STYLE_DASH,TokyoColor);}
               if (t30MinAdvanceNotice==true)
                  {
                     if ((h==TimeAdjust(TokyoOpenDataTime,1)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,TokyoColor);}
                     if ((h==TimeAdjust(TokyoOpenDataTime,2)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,TokyoColor);}
                  }
            }
         if (HongKong==true)
            {
               if ((h==HongKongOpenDataTime) && (m==0)) {drawvl=true;VerticalLine("HK O",i,STYLE_SOLID,HKColor);}
               if ((h==TimeAdjust(HongKongOpenDataTime,0)) && (m==0)) {drawvl=true;VerticalLine("HK C",i,STYLE_DASH,HKColor);}
               if (t30MinAdvanceNotice==true)
                  {
                     if ((h==TimeAdjust(HongKongOpenDataTime,1)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,HKColor);}
                     if ((h==TimeAdjust(HongKongOpenDataTime,2)) && (m==30)) {drawvl=true;VerticalLine("",i,STYLE_DOT,HKColor);}
                  }
            }
      }
   return(0);
   }
//----------------------------------------------------------------------------------------------
int VerticalLine(string s,int i,int st,int Col)    //s=Text Label, i = bar, st=Line Style, Col = color
   {
   ObjectDelete("MMl"+DoubleToStr(i,0));
   val1=Low[Lowest(NULL,0,MODE_LOW,BarsPerWindow(),0)];
   val2=High[Highest(NULL,0,MODE_HIGH,BarsPerWindow(),0)];
   ObjectCreate("MMl"+DoubleToStr(i,0),OBJ_TREND,0,Time[i],0,Time[i],900);
   ObjectSet("MMl"+DoubleToStr(i,0),OBJPROP_COLOR,Col);
   ObjectSet("MMl"+DoubleToStr(i,0),OBJPROP_WIDTH,1);
   ObjectSet("MMl"+DoubleToStr(i,0),OBJPROP_STYLE,st);
   ObjectSet("MMl"+DoubleToStr(i,0),OBJPROP_RAY,0);
   ObjectDelete("MMt"+DoubleToStr(i,0));
   ObjectCreate("MMt"+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],val2+Point*3);
   ObjectSetText("MMt"+DoubleToStr(i,0),s,8,"Arial",Col);
   ObjectSet("MMt"+DoubleToStr(i,0), OBJPROP_ANGLE, 90);          //Rotates text 90 degrees
   ObjectsRedraw();
   return(0);
   }

int TimeAdjust(int TimeIn, int ProcessType)  
   {
      if (ProcessType==0)     //Calculate Closing Hour.  Open Hour + 9 hours
         {
            if ((TimeIn>=0) && (TimeIn<=14)){return(TimeIn+9);}
            return(TimeIn-15);
         }   
      if (ProcessType==1)     //Calculate 30MinAdvanceNotice for Opening Hour
         {
            if (TimeIn==0) {return(23);}
            return(TimeIn-1);
         }
      if (ProcessType==2)     //Calculate 30MinAdvanceNotice for Closing Hour
         {
            if ((TimeIn>=0) && (TimeIn<=15)) {return(TimeIn+8);}
            return(TimeIn-16);
         }
   }