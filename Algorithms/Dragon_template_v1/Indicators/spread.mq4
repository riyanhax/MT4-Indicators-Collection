// Code Modifications: FILE45 - 
#property indicator_chart_window

// User Inputes : Start
extern color Ask_Color = Lime;
extern color Bid_Color = Red;
extern color Spread_Color = Orange;
extern bool Show_Ask = false;
extern bool Show_Bid = false;
extern int  Font_Size = 17;
extern bool  Font_Bold = false;
extern int Move_Left_Right = 20;
extern int Move_Up_Down = 20;
extern int Corner = 1; 
// User Inputs : End

int ay, by, sy, The_Corner;

string The_Font;

int init()
{
   switch(Font_Bold)
  {
    case 0: The_Font = "Arial"; break;
    case 1: The_Font = "Arial Bold"; break;
  }
  
  switch(Corner)
   {
      case 0: The_Corner = 0; break;
      case 1: The_Corner = 1; break;
      case 2: The_Corner = 2; break;
      case 3: The_Corner = 3; break;
      default: The_Corner = 0;
   }
   
   if(Show_Ask == false && Show_Bid == false)
   {
       sy = Move_Up_Down; 
   }
   else if(Show_Ask == true && Show_Bid == true && (Corner == 0 || Corner == 1 || Corner > 3))
   {
      ay = Move_Up_Down;
      by = Move_Up_Down + (Font_Size-3)*2;
      sy = Move_Up_Down + (Font_Size-3)*4;   
   }
   else if(Show_Ask == true && Show_Bid == false && (Corner == 0 || Corner == 1|| Corner > 3))
   {
       ay = Move_Up_Down;
       sy = Move_Up_Down + (Font_Size-3)*2;     
   }
   else if(Show_Ask == false && Show_Bid == true && (Corner == 0 || Corner == 1 || Corner > 3))
   {
       by = Move_Up_Down;
       sy = Move_Up_Down + (Font_Size-3)*2;     
   }
   
   else if(Show_Ask == true && Show_Bid == true && (Corner == 2 || Corner == 3))
   {
      sy = Move_Up_Down; 
      by = Move_Up_Down + (Font_Size-3)*2;
      ay = Move_Up_Down + (Font_Size-3)*4;   
   }
   else if(Show_Ask == true && Show_Bid == false && (Corner == 2 || Corner == 3))
   {
       sy = Move_Up_Down;
       ay = Move_Up_Down + (Font_Size-3)*2;     
   }
   else if(Show_Ask == false && Show_Bid == true && (Corner == 2 || Corner == 3))
   {
       sy = Move_Up_Down;
       by = Move_Up_Down + (Font_Size-3)*2;     
   }
  
  return(0);
}

int deinit()
{
   ObjectDelete("Spread");  
   ObjectDelete("Market_Bid_Label");
   ObjectDelete("Market_Ask_Label"); 
  
   return(0);
}

int start()
{
   if(Show_Ask == true){
      string Market_Ask = DoubleToStr(Ask, Digits);
      ObjectCreate("Market_Ask_Label", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Market_Ask_Label", Market_Ask, Font_Size, The_Font, Ask_Color);
      ObjectSet("Market_Ask_Label", OBJPROP_CORNER, The_Corner);
      ObjectSet("Market_Ask_Label", OBJPROP_XDISTANCE, Move_Left_Right);
      ObjectSet("Market_Ask_Label", OBJPROP_YDISTANCE, ay);}
   else {
      ObjectSetText("Market_Ask_Label", "", 0, 0);}

   if(Show_Bid == true){
      string Market_Bid = DoubleToStr(Bid, Digits);  
      ObjectCreate("Market_Bid_Label", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("Market_Bid_Label", Market_Bid, Font_Size, The_Font, Bid_Color);
      ObjectSet("Market_Bid_Label", OBJPROP_CORNER, The_Corner);
      ObjectSet("Market_Bid_Label", OBJPROP_XDISTANCE, Move_Left_Right);
      ObjectSet("Market_Bid_Label", OBJPROP_YDISTANCE, by);}
   else {
      ObjectSetText("Market_Bid_Label", "", 0, 0);}
   
   double spread = (Ask - Bid) / Point;
   ObjectCreate("Spread",OBJ_LABEL,0,0,0);
   ObjectSetText("Spread", DoubleToStr(spread,0), Font_Size, The_Font, Spread_Color);
   ObjectSet("Spread", OBJPROP_CORNER, The_Corner);
   ObjectSet("Spread", OBJPROP_XDISTANCE, Move_Left_Right);
   ObjectSet("Spread", OBJPROP_YDISTANCE, sy);
      
return(0);

}  

