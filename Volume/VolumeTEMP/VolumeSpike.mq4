//+------------------------------------------------------------------+
//|                                                  VolumeSpike.mq4 |
//|                                   Copyright © 2008, Antonuk Oleg |
//|                                            antonukoleg@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Antonuk Oleg"
#property link      "antonukoleg@gmail.com"

#property indicator_chart_window
//---- input parameters
extern string    emailSubject="Time to trade (VolumeSpike indicator)",
                 emailText="It is  signal from VolumeSpike indicator";
extern int       volumeValue=50;

int currentDay, lastDay;
bool emailSentToday;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   emailSentToday=false;
   currentDay=DayOfYear();
   lastDay=DayOfYear();

   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if(!emailSentToday)
   {
      if(Volume[0]>volumeValue)
         SendMail(emailSubject,emailText);
      
      emailSentToday=true;   
   }
   else
   {
      currentDay=DayOfYear();
      
      if(currentDay!=lastDay)
      {
         emailSentToday=false;
         lastDay=currentDay;
      }
   }   
   
   return(0);
}
//+------------------------------------------------------------------+