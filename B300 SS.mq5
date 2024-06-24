//+------------------------------------------------------------------+
//|                                 BeardedFX SpikeSmasher(B300).mq5 |
//|                                             Created By BeardedFX |
//|                                                                  |
//+------------------------------------------------------------------+
#property   copyright       "BeardedFX Copyright"
#property   link            "Redacted"
#property   version         "1.00"
#property   description     "Created by BeardedFX"
#property   description     "1 MIN TIMEFRAME SPIKE INDICATOR."
#property   description     "STOPLOSS = 15 candles."
#property   description     "Trading with this indicator is done on OWN RISK!!"

#property   description     "BeardedFX will not be held reponsible for any losses. Own RISK MANAGEMENT has to be used"

#define     EA_NAME	       "BeardedFX SpikeSmasher(B300)"

//+------------------------------------------------------------------+
//|                        Patch Notes                               |
//+------------------------------------------------------------------+
// 27.02.2021
// [+]   Better Comments.
// [+]   Accurate Spikesmasher Indicator Data.
// [+]   Multiple Period Support(Stops bot from closing when switching timeframes).
// [+]   Email Functionality(Added by J.C Golden).
// [+]   Push Notification Functionality(Added by J.C Golden).
// [+]   Timer method used for MA instead of OnTick.
// [+]   Add arrow indicators to the chart where recommended trades should happen.
// [+]   Trailing stop using candles.
// [+]   Improved accuracy of the indicators.
// [+]   Make an alternative script that only places arrows but no trades.
// [+]   Correct indicator arrows should be displayed on the Boom EA's.
// [+]   Improve the accuracy of the SL and TP calculations.

// 06.03.2021
// [+]   The indicator data has been tested with real trades.
// [+]   The issue with multiple trades has been resolved.
// [+]   Only trades with the same magic number get closed.

//+------------------------------------------------------------------+
//|                     Necessary libraries                          |
//+------------------------------------------------------------------+
#include       <Trade/Trade.mqh>
#include       <Trade/SymbolInfo.mqh>
#include       <Trade/PositionInfo.mqh>
#include       <Trade/DealInfo.mqh>
#include       <Trade/OrderInfo.mqh>


//+------------------------------------------------------------------+
//|                        Global Variables                          |
//+------------------------------------------------------------------+
//Type         Name                                                                                         Comment
CTrade         Trade;
CDealInfo      Deal;
CSymbolInfo    Sym;
CPositionInfo  Position;
COrderInfo     Pending;

//+------------------------------------------------------------------+
//| BinaryChoice                                                     |
//+------------------------------------------------------------------+
enum BinaryChoice
{
// Option                  Value                                                                            Comment
   Yes                     = 1,                                                                             // Yes   
   No                      = 0,                                                                             // No
};


//+------------------------------------------------------------------+
//| Trailing_Options                                                 |
//+------------------------------------------------------------------+
enum Trailing_Options
{
// Option                           Value                                                                   Comment
   SL                               = 2,                                                                    // Handling Trailing with a SL.
   Candles                          = 1,                                                                    // Handling Trailing with Candles.   
   Both                             = 0,                                                                    // Both. SL must be higher than Candles.
};


//Type         Name                 Value                                                                   Comment
input group    "Trading"
input BinaryChoice AutoTrading      = 0;                                                                    // Trade in Downtrends. 0 = NO | 1 = YES
input double   Lot_Size             = 1;                                                                    // Lot sizes for trades.
input int      Stop_Loss            = 20;                                                                   // STOPLOSS for consolidation trade.
input int      Stop_Loss_2          = 20;                                                                   // STOPLOSS for confirmation trade.
input int      Take_Profit          = 40;                                                                   // TAKEPROFIT for consolidation trade.
input int      Take_Profit_2        = 40;                                                                   // TAKEPROFIT for confirmation trade.
input int      Magic_Number         = 123;                                                                  // The magic number.

int            Magic_Number2        = Magic_Number + 1;                                                     // The second magic number.
datetime       tempT                = 0;                                                                    // A temp variable for storing values.

double         Buffer1[5000];                                                                               // Candle buffer 1.
double         Buffer2[5000];                                                                               // Candle buffer 2.
datetime       time_alert;                                                                                  // Used when sending alert

input group    "Trailing Settings"
input Trailing_Options Trailing_Strategy = 0;                                                               // What trailing strategy would you like to use.
input double   Trailing_SL          = 4;                                                                    // Trailing SL. Enter value higher than 1.
input double   Trailing_Candles     = 10;                                                                   // Trailing Candles. Enter a value of 3 or higher.


input group    "Notifications"
input bool     Send_Email           = true;                                                                 // Email notifications
input bool     Audible_Alerts       = true;                                                                 // Audible alerts
input bool     Push_Notifications   = true;                                                                 // Push notification

double         myPoint;                                                                                     // Initialized in OnInit
int            MA_handle;                                                                                   // Moving Average handle.
double         MA[];                                                                                        // Moving Average array.
int            Envelopes_handle;                                                                            // The envelope handler.
double         Envelopes_Lower[];                                                                           // The envelope array.
double         Open[];                                                                                      // An array for open positions
int            Envelopes_handle2;                                                                           // The second envelope handler.
double         Envelopes_Lower2[];                                                                          // The second envelope array.
bool           DrasticMarketChange  = false;                                                                // If there are any drastic market changes.
int            MarketChangeBuffer   = 0;                                                                    // Check if there is any change in market buffer.
datetime       TimeShift[];
datetime       Time[];


double         Envelopes_Upper[];                                                                           // The envelope array.
double         Envelopes_Upper2[];                                                                          // The second envelope array.
int            IndicatorCount       = 0;                                                                    // The Indicator number generator.

int            TradeBuffer_1        = 30;                                                                   // Trade buffer for opening positions.
int            TradeBuffer_2        = 30;                                                                   // Trade buffer for opening positions.

//+------------------------------------------------------------------+
//| Moving averages variables.                                       |
//+------------------------------------------------------------------+
// Variables                        Value                                                                   Comment
string   strMarket_Trend            = "";                                                                   // What is the current market trend? Uptrend or Downtrend.
string   strLastMarket_Trend        = "";                                                                   // What was the prediction for the market on the last tick? Uptrend or Downtrend.
int      Ma_Event115;                                                                                       // Stores RSI data to identify moving averages.
int      Ma_Event215;                                                                                       // Stores RSI data to identify moving averages.

int      Ma_Event130;                                                                                       // Stores RSI data to identify moving averages.
int      Ma_Event230;                                                                                       // Stores RSI data to identify moving averages.
double   Ma_Array1[],                                                                                       // Ma_Array1 gets created. Moving average array.
         Ma_Array2[];                                                                                       // Ma_Array2 gets created. Moving average array.
color    colUptrend                 = clrLime,                                                              // The colour of the uptrend message.
         colDowntrend               = clrRed;                                                               // The colour of the downtrend message.

bool     Ma_Event15                 = false;                                                                // False = Downtrend AND True = Uptrend
bool     Ma_Event30                 = false;                                                                // False = Downtrend AND True = Uptrend

//+------------------------------------------------------------------+
//|                       Indicator Variables                        |
//+------------------------------------------------------------------+
// Variables                        Value                                                                   Comment
int prev_calculated                 = 0;                                                                    //* Indicator Note: Contains the value returned by the OnCalculate() function during the previous call. It is designed to skip the bars that have not changed since the previous launch of this function.

 
//--- ACCOUNT NUMBER USED FOR RESTRICTION
bool     useAccNumberRestriction    = false;                                                                // Set to false to disable verification, true to enable
long     m_account_number[]         = {100790678,21009105};                                                 // Account numbers
string   err_acc_num                = "["+EA_NAME+"] Due to licensing restrictions, code execution has been blocked! Please contact @BeardedFX Software";
//--- TRIAL PERIOD RESTRICTION
bool     useTrialPeriodRestriction  = false;                                                                //set false to disable trial, true to enable
int      m_expire_date              = D'2023.11.30 23:59';                                                  // Date of expiration - Trial period
string   err_trial                  = "["+EA_NAME+"] Your trial period has expired!! Please contact @BeardedFX Software";

//+------------------------------------------------------------------+
//|                           MyAlert                                |
//+------------------------------------------------------------------+
void myAlert(string type, string message)
{
   if(type == "print")
      Print(message);
   else if(type == "error")
   {
      Print(type+" | BeardedFX SpikeSmasher(B300) @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
   }
   else if(type == "order")
   {
   }
   else if(type == "modify")
   {
   }
   else if(type == "indicator")
   {
      if(Audible_Alerts) Alert(type+" | BeardedFX SpikeSmasher(B300) @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("BeardedFX SpikeSmasher(B300)", type+" | BeardedFX SpikeSmasher(B300) @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Push_Notifications) SendNotification(type+" | BeardedFX SpikeSmasher(B300) @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   TesterHideIndicators(true);
   EventSetTimer(5);
   
   if (useAccNumberRestriction)
    {      
      long account_number=AccountInfoInteger(ACCOUNT_LOGIN);
      int m_account_number_size=ArraySize(m_account_number);      
      bool isValid=false;
      for(int i=0; i<m_account_number_size;i++)
        {
         if(account_number==m_account_number[i])
           {
            isValid=true;
            break;
           }
        }
      if(!isValid)
        {
         if(MQLInfoInteger(MQL_TESTER)) // when testing, we will only output to the log about incorrect input parameters
            Print(__FILE__," ",__FUNCTION__,", ERROR: ",err_acc_num);
         else // if the Expert Advisor is run on the chart, tell the user about the error
            Alert(__FILE__," ",__FUNCTION__,", ERROR: ",err_acc_num);

         return(INIT_FAILED);
        }
    }
    
          //Time restriction
    if ( useTrialPeriodRestriction && TimeCurrent() > m_expire_date )
    {
      if(MQLInfoInteger(MQL_TESTER)) // when testing, we will only output to the log about incorrect input parameters
         Print(__FILE__," ",__FUNCTION__,", ERROR: ",err_trial);
      else // if the Expert Advisor is run on the chart, tell the user about the error
         Alert(__FILE__," ",__FUNCTION__,", ERROR: ",err_trial);
      return(INIT_FAILED);
    }
   
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
   {
      myPoint *= 10;
   }
   MA_handle = iMA(NULL, _Period, 1, 0, MODE_SMA, PRICE_LOW);
   if(MA_handle < 0)
   {
      Print("The creation of iMA has failed: MA_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
   }

   
   Envelopes_handle = iEnvelopes(NULL, _Period, 7, 0, MODE_LWMA, PRICE_WEIGHTED, 0.0100);
   if(Envelopes_handle < 0)
   {
      Print("The creation of iEnvelopes has failed: Envelopes_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
   }
   
   ChartMessages();                                                                                         // Apply the chart messages.
   MovingAverages();                                                                                        // Show the moving averages on startup.
   Sty_Log();
   
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

   
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
}


  
//+------------------------------------------------------------------+
//|                       OpenPosition                               |
//+------------------------------------------------------------------+
bool OpenPosition(ENUM_POSITION_TYPE TypeOrd,double lot,int magic, int type)
{
   int j;
   uint nRes;
   bool fRes;
   double Price=0;

   Trade.SetDeviationInPoints(6);
   Trade.SetExpertMagicNumber(magic);

   double sl=0;
   double tp=0;
   if(TypeOrd==POSITION_TYPE_BUY) Price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   if(TypeOrd==POSITION_TYPE_SELL) Price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   int Iter=10;
   
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)lot=minlot;
   
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) 
         {
            Alert("Check in the terminal settings permit for automatic trade!"); 
            nRes=1;
            return(false);
         } 
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) 
         {
            Alert("Automatic trade is prohibited in the properties of the program for ",__FILE__); 
            nRes=1;
            return(false);
         }
   
   for(j=0; j<Iter; j++)
     {
         if(type == 1)
         {
            sl = (Price - Stop_Loss );
            tp = (Price + Take_Profit);
         }
         
         if(type == 2)
         {
            sl = (Price - Stop_Loss_2 );
            tp = (Price + Take_Profit_2 );
         }
         
         
         if(TypeOrd==POSITION_TYPE_BUY)
         {
            Price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
            
            if(AutoTrading == 1)                                                                            // Autotrading is active.
            {
               fRes = Trade.Buy(lot, Symbol(), Price,sl,tp,"EA");                                           // Place a buy order even in uptrends.
            }
            else if(AutoTrading == 0)
            { 
               if(Ma_Event15 == true) fRes=Trade.Buy(lot, Symbol(), Price,sl,tp,"EA");                      // Place a buy order only in downtrends.
            }
            
         }
         

      nRes=Trade.ResultRetcode();
      if(fRes)
         break;


     }
   if(j==Iter)
     {
      Print("Fatal failure of the opening of the orders ");
     }
   else
     {
      Print("Order - OPENED");
     }
     
   return(true);
}

  
//+------------------------------------------------------------------+
//|                       ChartMessages                              |
//+------------------------------------------------------------------+
void ChartMessages()
   {      
//--- Brand Name                                                                                            Comments
      string brand_name = "CBRSI_brand";                                                                    // The brand name.
      string license_name = "CBRSI_license";                                                                // The license name.
      if(ObjectFind(0,brand_name) < 0)                                                                      // *IF* the brand name object is found.
         if(!ObjectCreate(0,brand_name,OBJ_LABEL,0,0,0))                                                    // *IF* the label creation was a failure.
         {
            Print(__FUNCTION__,": failed to create text label! Error code = ",GetLastError());              // Print the error code.
            return;                                                                                         // Return null and stop the function.
         }
      
      ObjectSetInteger(0,brand_name,OBJPROP_CORNER,1);                                                      // Set the object in the corner.
      ObjectSetInteger(0,brand_name,OBJPROP_XDISTANCE,10);                                                  // Set the X axis position.
      ObjectSetInteger(0,brand_name,OBJPROP_YDISTANCE,40);                                                  // Set the Y axis position.
      ObjectSetString(0,brand_name,OBJPROP_TEXT,"The Bearded Tech Copyright");                              // The text for the label.
      ObjectSetInteger(0,brand_name,OBJPROP_FONTSIZE,12);                                                   // The size of the font.
      ObjectSetString(0,brand_name,OBJPROP_FONT,"Arial");                                                   // The font for the label.
      ObjectSetInteger(0,brand_name,OBJPROP_COLOR,White);                                                   // The colour of the text.


//--- Product Activation Status                                                                             Comments
      if(ObjectFind(0,license_name) <0)                                                                     // *IF* the license object is found.
         if(!ObjectCreate(0,license_name,OBJ_LABEL,0,0,0))                                                  // *IF* creating the license object was a failure.
         {
            Print(__FUNCTION__,": failed to create text label! Error code = ",GetLastError());              // Print the error.
            return;                                                                                         // Return null to end the function.
         }
                                                                      
      ObjectSetInteger(0,license_name,OBJPROP_CORNER,1);                                                    // Set the object in the corner.
      ObjectSetInteger(0,license_name,OBJPROP_XDISTANCE,10);                                                // Set the X axis position.
      ObjectSetInteger(0,license_name,OBJPROP_YDISTANCE,20);                                                // Set the Y axis position.
      ObjectSetString(0,license_name,OBJPROP_TEXT,"Product Activated Successfully");                        // The text for the label.
      ObjectSetInteger(0,license_name,OBJPROP_FONTSIZE,8);                                                  // The size of the font.
      ObjectSetString(0,license_name,OBJPROP_FONT,"Arial");                                                 // The font for the label.
      ObjectSetInteger(0,license_name,OBJPROP_COLOR,White);                                                 // The colour of the text.
 
 
   }

 
//+------------------------------------------------------------------+
//|                       MovingAverages                             |
//+------------------------------------------------------------------+  
void MovingAverages()
{
   //--- 15 Min moving average indicator.
      // Commands                                                                                           Comments
      Ma_Event115 = iMA(_Symbol, PERIOD_M15, 17, 0, MODE_EMA, PRICE_TYPICAL);                               // The function returns the handle of the Moving Average indicator. It has only one buffer.
      Ma_Event215 = iMA(_Symbol, PERIOD_M15, 80, 0, MODE_EMA, PRICE_TYPICAL);                               // The function returns the handle of the Moving Average indicator. It has only one buffer.

      ArraySetAsSeries(Ma_Array1, true);                                                                    // Set Ma_Array1 to ascending order.
      ArraySetAsSeries(Ma_Array2, true);                                                                    // Set Ma_Array2 to ascending order.
      CopyBuffer(Ma_Event115, 0, 0, 3, Ma_Array1);                                                          // Copy the buffer from Ma_Event1 to Ma_Array1.
      CopyBuffer(Ma_Event215, 0, 0, 3, Ma_Array2);                                                          // Copy the buffer from Ma_Event2 to Ma_Array2.
  
      // Update the message for the trend indication.
      if(Ma_Array1[1] < Ma_Array2[1]) 
      {
         Ma_Event15 = false;
         strMarket_Trend = "15 Minute Trend Indication - Downtrend";                                        // A downtrend prediction has been made.
      }
      else
      { 
         Ma_Event15 = true;
         strMarket_Trend = "15 Minute Trend Indication - Uptrend";                                          // A uptrend prediction has been made.
      }
      
      // Update the front end message for 15 min moving average indicator.
      ObjectCreate(0, "TextMarket_Trend", OBJ_LABEL, 0, 0, 0);                                              // Create the label object. 
      ObjectSetInteger(0,"TextMarket_Trend",OBJPROP_CORNER,1);                                              // Set the object in the corner.               
      ObjectSetString(0, "TextMarket_Trend", OBJPROP_TEXT, strMarket_Trend);                                // Set the text of the message.
      ObjectSetString(0, "TextMarket_Trend", OBJPROP_FONT, "Ariel");                                        // Set the font of the text.
      ObjectSetInteger(0, "TextMarket_Trend", OBJPROP_FONTSIZE, 14);                                        // Set the size of the font.
      if(strMarket_Trend == "15 Minute Trend Indication - Uptrend") ObjectSetInteger(0, "TextMarket_Trend", OBJPROP_COLOR, colUptrend);                        // Set the text colour of the message.
      else ObjectSetInteger(0, "TextMarket_Trend", OBJPROP_COLOR, colDowntrend);
      ObjectSetInteger(0, "TextMarket_Trend", OBJPROP_XDISTANCE, 15);                                       // The X position on the graph for the message.
      ObjectSetInteger(0, "TextMarket_Trend", OBJPROP_YDISTANCE, 440);                                      // The Y position on the graph for the message.
      

//--- 30 Min moving average indicator.
      // Commands                                                                                           Comments
      Ma_Event130 = iMA(_Symbol, PERIOD_M30, 17, 0, MODE_EMA, PRICE_TYPICAL);                               // The function returns the handle of the Moving Average indicator. It has only one buffer.
      Ma_Event230 = iMA(_Symbol, PERIOD_M30, 80, 0, MODE_EMA, PRICE_TYPICAL);                               // The function returns the handle of the Moving Average indicator. It has only one buffer.

      ArraySetAsSeries(Ma_Array1, true);                                                                    // Set Ma_Array1 to ascending order.
      ArraySetAsSeries(Ma_Array2, true);                                                                    // Set Ma_Array2 to ascending order.
      CopyBuffer(Ma_Event130, 0, 0, 3, Ma_Array1);                                                          // Copy the buffer from Ma_Event1 to Ma_Array1.
      CopyBuffer(Ma_Event230, 0, 0, 3, Ma_Array2);                                                          // Copy the buffer from Ma_Event2 to Ma_Array2.
  
      // Update the message for the trend indication.
      if(Ma_Array1[1] < Ma_Array2[1])
      { 
         Ma_Event30 = false;
         strMarket_Trend = "30 Minute Trend Indication - Downtrend";                                        // A downtrend prediction has been made.
      }
      else 
      {
         Ma_Event30 = true;
         strMarket_Trend = "30 Minute Trend Indication - Uptrend";                                          // A uptrend prediction has been made.
      }
      // Update the front end message for 30 min moving average indicator.
      ObjectCreate(0, "TextMarket_Trend2", OBJ_LABEL, 0, 0, 0);                                             // Create the label object. 
      ObjectSetInteger(0,"TextMarket_Trend2",OBJPROP_CORNER,1);                                             // Set the object in the corner.               
      ObjectSetString(0, "TextMarket_Trend2", OBJPROP_TEXT, strMarket_Trend);                               // Set the text of the message.
      ObjectSetString(0, "TextMarket_Trend2", OBJPROP_FONT, "Ariel");                                       // Set the font of the text.
      ObjectSetInteger(0, "TextMarket_Trend2", OBJPROP_FONTSIZE, 14);                                       // Set the size of the font.
      if(strMarket_Trend == "30 Minute Trend Indication - Uptrend") ObjectSetInteger(0, "TextMarket_Trend2", OBJPROP_COLOR, colUptrend);                                   // Set the text colour of the message.
      else ObjectSetInteger(0, "TextMarket_Trend2", OBJPROP_COLOR, colDowntrend);
      ObjectSetInteger(0, "TextMarket_Trend2", OBJPROP_XDISTANCE, 15);                                      // The X position on the graph for the message.
      ObjectSetInteger(0, "TextMarket_Trend2", OBJPROP_YDISTANCE, 400);                                     // The Y position on the graph for the message.
}
      
      
       
//+------------------------------------------------------------------+
//|                            Sty_Log                               |
//+------------------------------------------------------------------+
void Sty_Log()
   {  
      // Graphic Objects                                                                                    Comments
      ChartSetInteger(0, CHART_SHOW_GRID, false);                                                           // Show the grid on the chart. [True = Yes] and [False = No]
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);                                                 // Set the colour backround of the chart to Black. 
      ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrWhite);                                                 // Set the colour foreground to White.
      ChartSetInteger(0, CHART_SHOW_VOLUMES, false);                                                        // Show the volumes on the chart. [True = Yes] and [False = No]
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrBlue);                                                 // Set the Bullish candle's colour to Blue. 
      ChartSetInteger(0, CHART_COLOR_CHART_UP, clrBlue);                                                    // Set the uptrend colour on the chart to Blue.
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrLime);                                                 // Set the Bearish candle's colour to Lime.
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrLime);                                                  // Set the downtrend colour on the chart to Lime.
   }
   
   
///+------------------------------------------------------------------+
//|                            ScanCandles                           |
//+------------------------------------------------------------------+   
void ScanCandles()
{
    // Number of total open positions
    int totalPositions = PositionsTotal();
    
    for(int i = PositionsTotal()-1; i >= 0; i--)                                                            // Loop through all open positions.
    {
        if(Position.SelectByIndex(i))                                                                       // Select the position in the current iteration.
        { 
            if(Position.Magic() == Magic_Number || Position.Magic() == Magic_Number2)
            {
               double bid =  SymbolInfoDouble(Symbol(),SYMBOL_BID);                                         // Get the symbol information.
               double sl  =  (Position.PriceCurrent() - Trailing_SL);                                       // Calculate the stop loss.
               double tp  =  Position.TakeProfit();                                                         // Calculate the take profit.
               datetime openTime = PositionGetInteger(POSITION_TIME);
               double savedLow = 0; 
               int difference = 0;
               string symbol = PositionGetString(POSITION_SYMBOL);
               ENUM_TIMEFRAMES timeframe = _Period;
               int openBar = iBarShift(symbol, timeframe, openTime, true);
               int currentBar = iBarShift(symbol, timeframe, TimeCurrent(), true);
               int TotalShift = currentBar - openBar;
                     
               TotalShift = MathAbs(TotalShift);                                                            // Get the absolute number first.

               //* Update SL and TP for any trades that are currently making a profit or a loss.
               switch(Trailing_Strategy)                                                                                                                                               //* Trailing strategy.
               {
                     //* Both
                     case 0:                                                                                                                                                             //* BOTH
                        if((Position.PriceCurrent() > Position.PriceOpen()) && (sl  > Position.StopLoss()) && TotalShift > 0) Trade.PositionModify(Position.Ticket(),sl,tp);            //* Adjust the SL.
                        if(!Trailing_Candles() && TotalShift >= Trailing_Candles) Trade.PositionClose(Position.Ticket(),-1);                                                            //* Check the trailing pips.
                        
                     break;

                     //* Candles
                     case 1:                                                                                                                                                             //* CANDLES
                           if(!Trailing_Candles() && TotalShift >= Trailing_Candles) Trade.PositionClose(Position.Ticket(), -1);                                                       //* Check the trailing pips.
                     break;

                     //* SL
                     case 2:                                                                                                                                                             //* SL
                        // Update SL and TP for any trades that are currently making a profit.
                        if((Position.PriceCurrent() > Position.PriceOpen()) && (sl  > Position.StopLoss()) && TotalShift > 0) Trade.PositionModify(Position.Ticket(),sl,tp);            //* Adjust the SL.
                     break;
               }
            }
           
      }
    }
}


//+------------------------------------------------------------------+
//|                            Trailing_Candles                      |
//+------------------------------------------------------------------+ 
bool Trailing_Candles()
{
   // Count bearish and bullish candles.
   bool returnVal = false;
   int bearishCandleCount = 0;
   int bullishCandleCount = 0;
   string symbol = PositionGetString(POSITION_SYMBOL);                                                      // Symbol of the position.
   ENUM_TIMEFRAMES timeframe = _Period;                                                                     // Timeframe (period) of the current chart.
               
   for (int i = 0; i < Trailing_Candles; ++i) 
   {
      double openPrice  = iOpen(symbol, timeframe, i);
      double closePrice = iClose(symbol, timeframe, i);
      
      if (closePrice < openPrice) ++bearishCandleCount;
      else if (closePrice > openPrice) ++bullishCandleCount;
   }
   
   if (bearishCandleCount == Trailing_Candles) returnVal = false;                                           // No Market change detected.
   else if(bearishCandleCount < Trailing_Candles) returnVal = true;                                         // Market change detected.
   
   return returnVal;
}

//+------------------------------------------------------------------+
//|                            Indicator                             |
//+------------------------------------------------------------------+    
int Indicator()
{
   // Indicator variables.                      Value                                                       Comment
   int rates_total                              = Bars(_Symbol, _Period);                                   //* Indicator Note: Size of the price[] array or input series available to the indicator for calculation. In the second function type, the parameter value corresponds to the number of bars on the chart it is launched at.
   int limit                                    = rates_total - prev_calculated;                            // Limit.
   datetime TimeShift[];                                                                                    // Timeshift Array.             
   datetime Time[];                                                                                         // Time Array.


   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   //--- initial zero
   if(prev_calculated < 1)
   {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
   }
   else limit++;
   
   if(BarsCalculated(MA_handle) <= 0) 
      return(0);
   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0) return(rates_total);
   ArraySetAsSeries(MA, true);
   if(CopyTime(Symbol(), PERIOD_CURRENT, 0, rates_total, TimeShift) <= 0) return(rates_total);
   ArraySetAsSeries(TimeShift, true);
   if(BarsCalculated(Envelopes_handle) <= 0) 
      return(0);
   if(CopyBuffer(Envelopes_handle, LOWER_LINE, 0, rates_total, Envelopes_Lower) <= 0) return(rates_total);
   ArraySetAsSeries(Envelopes_Lower, true);
   if(CopyOpen(Symbol(), PERIOD_M1, 0, rates_total, Open) <= 0) return(rates_total);
   ArraySetAsSeries(Open, true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0) return(rates_total);
   ArraySetAsSeries(Time, true);

   //--- main loop
   for(int i = limit-1; i >= 0; i--)
   {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      int barshift_M1 = iBarShift(Symbol(), PERIOD_M1, TimeShift[i]);
      if(barshift_M1 < 0) continue;
      
      //Indicator Buffer 1
      if(MA[barshift_M1] < Envelopes_Lower[barshift_M1]
      && MA[barshift_M1+1] > Envelopes_Lower[barshift_M1+1] //Moving Average crosses below Envelopes
      && TradeBuffer_1 == 30)
      {
         TradeBuffer_1--;
         OpenPosition(POSITION_TYPE_BUY,Lot_Size,Magic_Number,1);
         myAlert("indicator", "Buy ENTRY 1(SL-20 CANDLES)"); time_alert = Time[0]; 
         //DrawArrowOnPrice(233);
      }
      else
      {
         Buffer1[i] = EMPTY_VALUE;
      }
   }
   
   if(TradeBuffer_1 < 30) TradeBuffer_1--;
   if(TradeBuffer_1 == 1) TradeBuffer_1 = 30;
   return(rates_total);
}

//+------------------------------------------------------------------+
//|                        DrawArrowOnPrice                          |
//+------------------------------------------------------------------+
void DrawArrowOnPrice(int ArrowCode)
{
   // Calculate the price and time for the arrow
   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);                                                      // Get the current bidding price.
   Bid = Bid - 2;                                                                                           // Add a buffer so it wont be in the way.
   datetime arrowTime = TimeCurrent();                                                                      // Get the current time
   string Name = "Arrow_" + IndicatorCount;                                                                 // Get the unique name for the arrow ready.
   
   ObjectCreate(0, Name, OBJ_ARROW, 0, arrowTime, Bid);                                                     // Create the arrow object.
   ObjectSetInteger(0, Name, OBJPROP_WIDTH, 2);                                                             // Set arrow width.
   ObjectSetInteger(0, Name, OBJPROP_COLOR, clrSkyBlue);                                                    // Set arrow color.
   ObjectSetInteger(0, Name, OBJPROP_ARROWCODE, ArrowCode);                                                 // 234 for Consolidation and 242 for Confirmation.

   ++IndicatorCount;
}     

//+------------------------------------------------------------------+
//|                        Timer function                            |
//+------------------------------------------------------------------+
void OnTimer()
{    
   Indicator();
   prev_calculated = Bars(_Symbol, _Period);
   MovingAverages();
   ScanCandles();
}
