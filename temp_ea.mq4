//+------------------------------------------------------------------+
//|                                             Auto Executor EA.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//#include "StarterEA_FunctionsFreeC.mqh"

//[Scope]//

input string nEAInfo = " ****************** Indicator Signals ****************** " ;//Signals
input int Buy_Arrow_Index = 5;
input int Sell_Arrow_Index = 6;
input int Allow_Buy= true;
input int Allow_Sell = true;
input string nEAInfo1 = " ****************** EA Settings ****************** " ;//Settings
input int MagicNumber = 20230902;
input double Lot=.1, TakeProfit=100, StopLoss=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(NewBar())
     {
      int sig = read_ind_signal();
      if(sig>-1)
        {
         if(!Allow_Buy && sig==OP_BUY)
            return;
         if(!Allow_Sell && sig==OP_SELL)
            return;
         open(_Symbol, MagicNumber, sig, Lot, TakeProfit, StopLoss);
        }
     }
//---
  }
//+------------------------------------------------------------------+
int read_ind_signal()
  {
   double b= ReadInd(Buy_Arrow_Index, 1);
   double s= ReadInd(Sell_Arrow_Index, 1);
   if(b>0 && b!=EMPTY_VALUE)
      return OP_BUY;
   if(s>0 && s!=EMPTY_VALUE)
      return OP_SELL;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double ReadInd(int t, int yy) {return 0;}
//[FUNC]//

//+------------------------------------------------------------------+
bool NewBar(bool reset = false)
  {
   static datetime time;
   if(reset)
     {
      time = 0;
      return false;
     }
   if(Time[0] > time)
     {
      time = Time[0];
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int open(string sym, int nMagic, int ty, double lot, double pof, double sll, string cmnt = "", string typesl = "Point", double priceinPending = 0, double sslippage = 30000)
  {
   if(lot == 0)
      return 0;
   lot = NormalizeDouble(lot, 2);
   double nsl = 0, ntp = 0;
   double pr = 0;
   color clr = White;
   bool modi;
   string T;
   int tik = 0;
// Ctf tfs(sym, 0);
   double pt;
   int j ;
   if(((int)MarketInfo(sym, MODE_DIGITS) % 2) == 1)
     {
      pt    = MarketInfo(sym, MODE_POINT) * 10;
      j=10;
     }
   else
     {
      pt    = MarketInfo(sym, MODE_POINT);
      j=1;
     }
   string com = (StringLen(cmnt) > 0 ? cmnt : WindowExpertName());
   if(ty == OP_BUY || ty == OP_BUYSTOP || ty == OP_BUYLIMIT)
     {
      pr = NormalizeDouble(MarketInfo(sym, MODE_ASK), (int)MarketInfo(sym, MODE_DIGITS));
      if(ty == OP_BUYSTOP || ty == OP_BUYLIMIT)
         pr = NormalizeDouble(priceinPending, (int)MarketInfo(sym, MODE_DIGITS));
      if(typesl == "Point")
        {
         if(sll > 0)
           {
            nsl = pr - (sll * pt);
           }
         else
           {
            nsl = 0;
           }
         if(pof > 0)
           {
            ntp = pr + (pof * pt);
           }
         else
           {
            ntp = 0;
           }
        }
      else
         if(typesl == "Price")
           {
            if(sll > 0)
              {
               nsl = (sll);
              }
            else
              {
               nsl = 0;
              }
            if(pof > 0)
              {
               ntp = (pof);
              }
            else
              {
               ntp = 0;
              }
           }
      clr = Green;
      T = "Ask ";
     }
   if(ty == OP_SELL || ty == OP_SELLSTOP || ty == OP_SELLLIMIT)
     {
      pr = NormalizeDouble(MarketInfo(sym, MODE_BID), (int)MarketInfo(sym, MODE_DIGITS));
      if(ty == OP_SELLSTOP || ty == OP_SELLLIMIT)
         pr = NormalizeDouble(priceinPending, (int)MarketInfo(sym, MODE_DIGITS));
      if(typesl == "Point")
        {
         if(sll > 0)
           {
            nsl = pr + (sll * pt);
           }
         else
           {
            nsl = 0;
           }
         if(pof > 0)
           {
            ntp = pr - (pof * pt);
           }
         else
           {
            ntp = 0;
           }
        }
      else
         if(typesl == "Price")
           {
            if(sll > 0)
              {
               nsl = (sll);
              }
            else
              {
               nsl = 0;
              }
            if(pof > 0)
              {
               ntp = (pof);
              }
            else
              {
               ntp = 0;
              }
           }
      clr = Red;
      T = "Bid";
     }
   tik = OrderSend(sym
                   , ty
                   , lot
                   , NormalizeDouble(pr, (int)MarketInfo(sym, MODE_DIGITS))
                   , (int)(sslippage * j)
                   , 0
                   , 0
                   , com
                   , nMagic
                   , 0
                   , clr);
// Sleep(3000);
   int _error = GetLastError();
   if(_error == 134)
      ExpertRemove();
   string t;
   if(ty == OP_BUY)
      t = "BUY";
   if(ty == OP_SELL)
      t = "SELL";
   if(ty == OP_BUYSTOP)
      t = "BUY STOP";
   if(ty == OP_SELLSTOP)
      t = "SELL STOP";
   if(ty == OP_BUYLIMIT)
      t = "BUY LIMIT";
   if(ty == OP_SELLLIMIT)
      t = "SELL LIMIT";
   if(tik > 0)
     {
      if(ntp > 0 || nsl > 0)
         modi = OrderModify(tik, pr, nsl, ntp, 0, CLR_NONE);
      else
         modi = true;
      _error = GetLastError();
      if(!modi)
        {
         Print("Modify Err#= ", ErrorDescription(_error), "    Magic ", nMagic, " Comment ", com, "  ", sym, " ", Period(), "   Open Price= ", DoubleToStr(pr, (int)MarketInfo(sym, MODE_DIGITS)), "   SL= ", DoubleToStr(nsl, (int)MarketInfo(sym, MODE_DIGITS)), "   Tp= ", DoubleToStr(ntp, (int)MarketInfo(sym, MODE_DIGITS)));
         if(!modi && (nsl > 0 || ntp > 0))
            modi = OrderModify(tik, pr, nsl, ntp, 0, CLR_NONE);
         Sleep(50);
         if(!modi && (nsl > 0 || ntp > 0))
            modi = OrderModify(tik, pr, nsl, ntp, 0, CLR_NONE);
         Sleep(50);
         if(!modi && (nsl > 0 || ntp > 0))
            modi = OrderModify(tik, pr, nsl, ntp, 0, CLR_NONE);
         Sleep(50);
         if(!modi && (nsl > 0 || ntp > 0))
            modi = OrderModify(tik, pr, nsl, ntp, 0, CLR_NONE);
         Sleep(50);
         if(!modi && (nsl > 0 || ntp > 0))
            modi = OrderModify(tik, pr, nsl, ntp, 0, CLR_NONE);
         Sleep(50);
         if(!modi && (nsl > 0 || ntp > 0))
            Alert("Can not Set the TP or SL : Error ", ErrorDescription(_LastError));
        }
      Print("Order Opened successfully   Magic ", nMagic, " Comment ", com, "  Type   ", t, "  LotSize   ", lot, "  Price   ", DoubleToStr(pr, (int)MarketInfo(sym, MODE_DIGITS)), "  TP   ", DoubleToStr(ntp, (int)MarketInfo(sym, MODE_DIGITS)), "  SL   ", DoubleToStr(nsl, (int)MarketInfo(sym, MODE_DIGITS)));
     }
   else
     {
      Print("OrderSend failed with error #", ErrorDescription(_error), "    Magic ", nMagic, " Comment ", com, "  ", " Type ", t, "   LotSize= ", lot, "   ", T, "Now= ", DoubleToStr(pr, (int)MarketInfo(sym, MODE_DIGITS)), "   Price= ", DoubleToStr(pr, (int)MarketInfo(sym, MODE_DIGITS)), "   TP= ", DoubleToStr(ntp, (int)MarketInfo(sym, MODE_DIGITS)), "   SL= ", DoubleToStr(nsl, (int)MarketInfo(sym, MODE_DIGITS)), "   Spread= ", MarketInfo(sym, MODE_SPREAD));
      if(_error == 134)
         ExpertRemove();
     }
   return(tik);
  }
//+------------------------------------------------------------------+
string ErrorDescription(int error)
  {
   return "#"+IntegerToString(error);
  }
//+------------------------------------------------------------------+
