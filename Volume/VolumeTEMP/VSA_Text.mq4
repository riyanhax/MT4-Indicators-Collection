//+------------------------------------------------------------------+
//|                                                      VSA_YJZ.mq4 |
//|                              Copyright © 2009, yijomza@gmail.com |
//|                                                yijomza@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, yijomza@gmail.com."
#property link      "yijomza@gmail.com"

#property indicator_chart_window
//----Input
extern int SpreadPeriod=20
          ,VolumePeriod=20;
extern color TextColor=Orange;

//---- buffers

int o;int c=0;
string updnbar,spreadtype,volumetype,closebar,VSAType,newVSA;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   ObjectsDeleteAll(0,OBJ_TEXT); 
   
   
   for(c=1000;c>=0;c--)
   {
   //--------
      if(Close[c+1]>Close[c+2])
      {
       updnbar="UP BAR";
      }
      if(Close[c+1]<Close[c+2])
      {
       updnbar="DOWN BAR";
      }
   //--------  
       if(Close[c+1]<=(((High[c+1]-Low[c+1])*0.3)+Low[c+1]))
       {
        closebar="DOWN CLOSE";
       }
       else if(Close[c+1]>=(High[c+1]-((High[c+1]-Low[c+1])*0.3)))
       {
        closebar="UP CLOSE";
       }
       else
       {
        closebar="MID CLOSE";
       }
   //--------
      if(sp(c)=="WIDE SPREAD BAR"
      && vt(c)=="HIGH VOLUME" 
      && closebar=="DOWN CLOSE" 
      && Close[c+2]>Close[c+3]
      && High[c+1]>High[c+2]
      )
      {
       VSAType="UPTHRUST";
      }
      else
      if(sp(c)=="NARROW SPREAD BAR" 
      && (vt(c)=="LOW VOLUME" || Volume[c+1]<Volume[c+2]) 
      && (closebar=="DOWN CLOSE" || closebar=="MID CLOSE") 
      && updnbar=="UP BAR"
      )
      {
       VSAType="No Demand Bar";
      }
      else
      if((vt(c)=="HIGH VOLUME") 
      && (closebar=="UP CLOSE") 
      && updnbar=="DOWN BAR"
      )
      {
       VSAType="Stopping Volume";
      }
      else
      if(sp(c)=="WIDE SPREAD BAR" 
      && vt(c)=="HIGH VOLUME" 
      && closebar=="UP CLOSE" 
      && updnbar=="UP BAR"
      && Low[c+1]<Low[c+2]
      )
      {
       VSAType="Reverse UPTHRUST";
      }
      else
      if(sp(c)=="NARROW SPREAD BAR" 
      && vt(c)=="LOW VOLUME" 
      && closebar=="DOWN CLOSE" 
      && updnbar=="DOWN BAR"
      )
      {
       VSAType="NO Supply Bar";
      }
      else
      if(sp(c)=="WIDE SPREAD BAR"
      && updnbar=="UP BAR"
      && closebar=="UP CLOSE"
      && (vt(c)=="HIGH VOLUME" || Volume[c+1]>Volume[c+2])
      )
      {
       VSAType="Effort To Move Up";
      }   
      else
      if(sp(c)=="WIDE SPREAD BAR"
      && updnbar=="DOWN BAR"
      && closebar=="DOWN CLOSE"
      && (vt(c)=="HIGH VOLUME" || Volume[c+1]>Volume[c+2])
      )
      {
       VSAType="Effort To Move Down";
      }   
      else VSAType="No Comment";
   //--------
      if(newVSA!=VSAType)
      {
         o++;  
         double mid=(High[c+1]+Low[c+1])/2;
         if(VSAType!="No Comment")
         {
            Text("t"+o,VSAType,Time[c+1],mid,TextColor);
         }
       newVSA=VSAType;  
      }
   }   
//----
   return(0);
  }
//+------------------------------------------------------------------+
void Text(string name,string txt,int time,double price,color cl)
{
ObjectCreate(name,OBJ_TEXT,0,time,price);
ObjectSetText(name,txt,8,"Comic Sans MS",cl);
ObjectSet(name, OBJPROP_ANGLE,90);
}
//--------
string sp(int s)
{
      int spread,avgspread,cnt,collectspread;
      for(int i=SpreadPeriod;i>=1;i--)
      {
       spread=(High[s+i]-Low[s+i])/Point;
       collectspread+=spread;
      }
      avgspread=collectspread/(SpreadPeriod-1);
      double curspread=(High[s+1]-Low[s+1])/Point;
      double HMtimespread=curspread/avgspread;
   
      if(HMtimespread>=1.8)
      {
       spreadtype="WIDE SPREAD BAR";
      }
      else if(HMtimespread<=0.8)
      {
       spreadtype="NARROW SPREAD BAR";
      }
      else spreadtype="";
return(spreadtype);
}
//--------
string vt(int s)
{
      double vol,collectvol,avgvol;
      for(int i=VolumePeriod;i>=1;i--)
      {
       vol=Volume[s+i];
       collectvol+=vol;
      }
      avgvol=collectvol/(VolumePeriod-1);
   
      if(Volume[s+1]>=avgvol)
      {
       volumetype="HIGH VOLUME";
      }
      else volumetype="LOW VOLUME";
return(volumetype);
}