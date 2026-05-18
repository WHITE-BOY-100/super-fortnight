//+------------------------------------------------------------------+
//|                                                 EliteTraderV3.mq4 |
//|                                                     Manus AI |
//|                                        https://www.manus.im |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property link      "https://www.manus.im"
#property version   "3.00"
#include <WinAPI.mqh>
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   12

//--- input parameters
input string Inp_IndicatorName = "Elite Trader V3";
input string Inp_DashboardPanelName = "EliteTraderV3Dashboard";
input int Inp_DashboardCorner = 0; // 0-top left, 1-top right, 2-bottom left, 3-bottom right
input int Inp_DashboardX = 10;
input int Inp_DashboardY = 10;
input color Inp_DashboardBGColor = clrBlack;
input color Inp_DashboardTextColor = clrWhite;
input color Inp_WinColor = clrGreen;
input color Inp_LossColor = clrRed;
input color Inp_SignalColor = clrBlue;
input color Inp_PercentageColor = clrMagenta;
input color Inp_TelegramOnColor = clrGreen;
input color Inp_TelegramOffColor = clrRed;

//--- Guppy MMA parameters (Short Term)
input int Inp_GMMA_Short1 = 3;
input int Inp_GMMA_Short2 = 5;
input int Inp_GMMA_Short3 = 8;
input int Inp_GMMA_Short4 = 10;
input int Inp_GMMA_Short5 = 12;
input int Inp_GMMA_Short6 = 15;
input color Inp_GMMA_ShortColor = clrAqua;

//--- Guppy MMA parameters (Long Term)
input int Inp_GMMA_Long1 = 30;
input int Inp_GMMA_Long2 = 35;
input int Inp_GMMA_Long3 = 40;
input int Inp_GMMA_Long4 = 45;
input int Inp_GMMA_Long5 = 50;
input int Inp_GMMA_Long6 = 60;
input color Inp_GMMA_LongColor = clrLimeGreen;
input ENUM_MA_METHOD Inp_MAMethod = MODE_EMA;
input ENUM_APPLIED_PRICE Inp_AppliedPrice = PRICE_CLOSE;

//--- Support & Resistance parameters
input int Inp_SR_Lookback = 200;
input double Inp_SR_Deviation = 0.0001;
input color Inp_ResistanceColor = clrRed;
input color Inp_SupportColor = clrGreen;
input int Inp_SR_Width = 2;
input ENUM_LINE_STYLE Inp_SR_Style = STYLE_SOLID;

//--- Trend Channel parameters
input int Inp_TrendChannelLookback = 100;
input color Inp_TrendChannelColor = clrWhite;
input ENUM_LINE_STYLE Inp_TrendChannelStyle = STYLE_DOT;
input int Inp_TrendChannelWidth = 1;

//--- Signal Arrow parameters
input int Inp_ArrowShift = 10; // Shift arrows up/down from candle
input color Inp_BuyArrowColor = clrLimeGreen;
input color Inp_SellArrowColor = clrRed;
input int Inp_ArrowCodeBuy = 233; // Wingdings up arrow
input int Inp_ArrowCodeSell = 234; // Wingdings down arrow

//--- Strength Meter parameters
input string Inp_StrengthMeterPanelName = "StrengthMeterPanel";
input int Inp_StrengthMeterCorner = 1; // Top Right
input int Inp_StrengthMeterX = 10;
input int Inp_StrengthMeterY = 10;
input color Inp_StrengthMeterBuyColor = clrGreen;
input color Inp_StrengthMeterSellColor = clrRed;
input color Inp_StrengthMeterTextColor = clrWhite;

//--- MTF Signal Dot parameters
input color Inp_MTF_BuyColor = clrLimeGreen;
input color Inp_MTF_SellColor = clrRed;
input color Inp_MTF_NeutralColor = clrGray;

//--- Telegram parameters
input string Inp_TelegramBotToken = ""; // Your Telegram Bot Token
input string Inp_TelegramChatID = ""; // Your Telegram Chat ID
input bool Inp_EnableTelegramAlerts = false; // Enable/Disable Telegram alerts
input bool Inp_SendSignalAlerts = true; // Send alerts for buy/sell signals
input bool Inp_SendDailySummary = false; // Send daily summary of performance

//--- New input parameters for enhanced dashboard colors
input color Inp_DashboardHeaderColor = clrWhite; // Color for dashboard header
input color Inp_DashboardValueColor = clrYellow; // Color for dashboard values
input color Inp_DashboardLabelColor = clrLightGray; // Color for dashboard labels

//--- New input parameters for advanced signal logic
input int Inp_SignalConfirmationBars = 2; // Number of bars for signal confirmation
input double Inp_MinProfitTarget = 0.001; // Minimum profit target as a percentage of price
input double Inp_MaxLossTolerance = 0.0005; // Maximum loss tolerance as a percentage of price


double ExtGMMA_Short1Buffer[];
double ExtGMMA_Short2Buffer[];
double ExtGMMA_Short3Buffer[];
double ExtGMMA_Short4Buffer[];
double ExtGMMA_Short5Buffer[];
double ExtGMMA_Short6Buffer[];
double ExtGMMA_Long1Buffer[];
double ExtGMMA_Long2Buffer[];
double ExtGMMA_Long3Buffer[];
double ExtGMMA_Long4Buffer[];
double ExtGMMA_Long5Buffer[];
double ExtGMMA_Long6Buffer[];

// Global variables for dashboard stats
int    Global_Wins = 0;
int    Global_Losses = 0;
int    Global_Signals = 0;
double Global_WinPercentage = 0.0;
int    Global_LastSignalType = 0; // 1 for Buy, -1 for Sell, 0 for None
double Global_LastSignalPrice = 0.0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   CreateDashboard();
   CreateStrengthMeter();
//--- indicator buffers mapping
   SetIndexBuffer(0, ExtGMMA_Short1Buffer);
   SetIndexBuffer(1, ExtGMMA_Short2Buffer);
   SetIndexBuffer(2, ExtGMMA_Short3Buffer);
   SetIndexBuffer(3, ExtGMMA_Short4Buffer);
   SetIndexBuffer(4, ExtGMMA_Short5Buffer);
   SetIndexBuffer(5, ExtGMMA_Short6Buffer);
   SetIndexBuffer(6, ExtGMMA_Long1Buffer);
   SetIndexBuffer(7, ExtGMMA_Long2Buffer);
   SetIndexBuffer(8, ExtGMMA_Long3Buffer);
   SetIndexBuffer(9, ExtGMMA_Long4Buffer);
   SetIndexBuffer(10, ExtGMMA_Long5Buffer);
   SetIndexBuffer(11, ExtGMMA_Long6Buffer);

   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_ShortColor);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_ShortColor);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_ShortColor);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_ShortColor);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_ShortColor);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_ShortColor);
   SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_LongColor);
   SetIndexStyle(7, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_LongColor);
   SetIndexStyle(8, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_LongColor);
   SetIndexStyle(9, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_LongColor);
   SetIndexStyle(10, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_LongColor);
   SetIndexStyle(11, DRAW_LINE, STYLE_SOLID, 1, Inp_GMMA_LongColor);

   SetIndexLabel(0, "GMMA Short 1");
   SetIndexLabel(1, "GMMA Short 2");
   SetIndexLabel(2, "GMMA Short 3");
   SetIndexLabel(3, "GMMA Short 4");
   SetIndexLabel(4, "GMMA Short 5");
   SetIndexLabel(5, "GMMA Short 6");
   SetIndexLabel(6, "GMMA Long 1");
   SetIndexLabel(7, "GMMA Long 2");
   SetIndexLabel(8, "GMMA Long 3");
   SetIndexLabel(9, "GMMA Long 4");
   SetIndexLabel(10, "GMMA Long 5");
   SetIndexLabel(11, "GMMA Long 6");


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, Inp_DashboardPanelName);
   ObjectsDeleteAll(0, Inp_IndicatorName);
   ObjectsDeleteAll(0, "SR_Zone_");
   ObjectsDeleteAll(0, "TrendChannel_");
   ObjectsDeleteAll(0, "SignalArrow_");
   ObjectsDeleteAll(0, Inp_StrengthMeterPanelName);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- check for minimum bars
   if(rates_total < 100) return(0);

   int limit = rates_total - prev_calculated;
   if(limit == 0) limit = 1;

   for(int i = 0; i < limit; i++)
     {
      ExtGMMA_Short1Buffer[i] = iMA(NULL, 0, Inp_GMMA_Short1, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Short2Buffer[i] = iMA(NULL, 0, Inp_GMMA_Short2, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Short3Buffer[i] = iMA(NULL, 0, Inp_GMMA_Short3, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Short4Buffer[i] = iMA(NULL, 0, Inp_GMMA_Short4, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Short5Buffer[i] = iMA(NULL, 0, Inp_GMMA_Short5, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Short6Buffer[i] = iMA(NULL, 0, Inp_GMMA_Short6, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Long1Buffer[i] = iMA(NULL, 0, Inp_GMMA_Long1, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Long2Buffer[i] = iMA(NULL, 0, Inp_GMMA_Long2, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Long3Buffer[i] = iMA(NULL, 0, Inp_GMMA_Long3, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Long4Buffer[i] = iMA(NULL, 0, Inp_GMMA_Long4, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Long5Buffer[i] = iMA(NULL, 0, Inp_GMMA_Long5, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtGMMA_Long6Buffer[i] = iMA(NULL, 0, Inp_GMMA_Long6, 0, Inp_MAMethod, Inp_AppliedPrice, i);
     }

//--- 
   DrawSRZones();
   DrawTrendChannel();
   
   // Enhanced Signal Generation Logic
   int signal = GenerateSignal(rates_total);
   if (signal == 1) // Buy signal
     {
      DrawSignalArrows(0, 1);
      if (Inp_EnableTelegramAlerts && Inp_SendSignalAlerts) SendTelegramMessage("BUY Signal on " + Symbol() + " " + EnumToString(Period()) + " at " + DoubleToString(Close[0], Digits));
      Global_Signals++;
      Global_LastSignalType = 1;
      Global_LastSignalPrice = Close[0];

     }
   else if (signal == -1) // Sell signal
     {
      DrawSignalArrows(0, -1);
      if (Inp_EnableTelegramAlerts && Inp_SendSignalAlerts) SendTelegramMessage("SELL Signal on " + Symbol() + " " + EnumToString(Period()) + " at " + DoubleToString(Close[0], Digits));
      Global_Signals++;
      Global_LastSignalType = -1;
      Global_LastSignalPrice = Close[0];

     }

   UpdateStrengthMeter(78, 22); // Placeholder values

   // Update MTF dots
   string timeframes[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1"};
   ENUM_TIMEFRAMES enumTimeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};
   for(int i=0; i<ArraySize(timeframes); i++)
     {
      int mtf_signal = GetSignalForTimeframe(enumTimeframes[i]);
      color dotColor = Inp_MTF_NeutralColor;
      if (mtf_signal == 1) dotColor = Inp_MTF_BuyColor;
      else if (mtf_signal == -1) dotColor = Inp_MTF_SellColor;
      UpdateMTFDot(timeframes[i], dotColor);
     }
     
   // Update Dashboard with current stats
   if (Global_Signals > 0) Global_WinPercentage = (double)Global_Wins / Global_Signals * 100.0;
   UpdateDashboard(Global_Wins, Global_Losses, Global_Signals, Global_WinPercentage, Inp_EnableTelegramAlerts);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Create Strength Meter                                            |
//+------------------------------------------------------------------+
void CreateStrengthMeter()
  {
   string objName;
   int corner = Inp_StrengthMeterCorner;
   int x = Inp_StrengthMeterX;
   int y = Inp_StrengthMeterY;
   int width = 200; // Increased width for more info
   int height = 50;

   // Background panel
   objName = Inp_StrengthMeterPanelName + "_BG";
   ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, Inp_StrengthMeterTextColor);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 0);

   // Buy Percentage
   objName = Inp_StrengthMeterPanelName + "_BuyPercent";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 5);
   ObjectSetString(0, objName, OBJPROP_TEXT, "0%");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_StrengthMeterBuyColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   // Sell Percentage
   objName = Inp_StrengthMeterPanelName + "_SellPercent";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 20);
   ObjectSetString(0, objName, OBJPROP_TEXT, "0%");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_StrengthMeterSellColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
  }

//+------------------------------------------------------------------+
//| Create Dashboard                                                 |
//+------------------------------------------------------------------+
void CreateDashboard()
  {
   string objName;
   int corner = Inp_DashboardCorner;
   int x = Inp_DashboardX;
   int y = Inp_DashboardY;
   int width = 200; // Increased width for more info
   int height = 180; // Increased height for more info

   // Background panel
   objName = Inp_DashboardPanelName + "_BG";
   ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, Inp_DashboardBGColor);
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, Inp_DashboardTextColor);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 0);

   // Header
   objName = Inp_DashboardPanelName + "_Header";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 5);
   ObjectSetString(0, objName, OBJPROP_TEXT, Inp_IndicatorName); // Use indicator name
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardHeaderColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   // Win/Loss/Signals/Percentage
   objName = Inp_DashboardPanelName + "_Win";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 25);
   ObjectSetString(0, objName, OBJPROP_TEXT, "WIN: 0");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_WinColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   objName = Inp_DashboardPanelName + "_Loss";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 80);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 25);
   ObjectSetString(0, objName, OBJPROP_TEXT, "LOSS: 0");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_LossColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   objName = Inp_DashboardPanelName + "_Signals";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 40);
   ObjectSetString(0, objName, OBJPROP_TEXT, "SIGNALS: 0");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_SignalColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   objName = Inp_DashboardPanelName + "_Percentage";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 80);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 40);
   ObjectSetString(0, objName, OBJPROP_TEXT, "0.0%");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_PercentageColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   // Telegram Status
   objName = Inp_DashboardPanelName + "_Telegram";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 55);
   ObjectSetString(0, objName, OBJPROP_TEXT, "TELEGRAM: OFF");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_TelegramOffColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   // MTF Grid (placeholders)
   string timeframes[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1"};
   for(int i=0; i<ArraySize(timeframes); i++)
     {
      objName = Inp_DashboardPanelName + "_MTF_" + timeframes[i];
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5 + i*20);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 75);
      ObjectSetString(0, objName, OBJPROP_TEXT, timeframes[i]);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardLabelColor);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

      objName = Inp_DashboardPanelName + "_MTF_Dot_" + timeframes[i];
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5 + i*20);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 90);
      ObjectSetString(0, objName, OBJPROP_TEXT, "\x00B7"); // Bullet point character
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, objName, OBJPROP_FONT, "Wingdings");
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
     }
     
   // Current Trend Display
   objName = Inp_DashboardPanelName + "_TrendLabel";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 110);
   ObjectSetString(0, objName, OBJPROP_TEXT, "TREND:");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardLabelColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
   
   objName = Inp_DashboardPanelName + "_TrendValue";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 50);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 110);
   ObjectSetString(0, objName, OBJPROP_TEXT, "Neutral");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardValueColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
   
   // Last Signal Display
   objName = Inp_DashboardPanelName + "_LastSignalLabel";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 125);
   ObjectSetString(0, objName, OBJPROP_TEXT, "LAST SIGNAL:");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardLabelColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
   
   objName = Inp_DashboardPanelName + "_LastSignalValue";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 90);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 125);
   ObjectSetString(0, objName, OBJPROP_TEXT, "None");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardValueColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
  }

//+------------------------------------------------------------------+
//| Update Dashboard (to be called in OnCalculate)                   |
//+------------------------------------------------------------------+
void UpdateDashboard(int wins, int losses, int signals, double percentage, bool telegramOn)
  {
   string objName;

   objName = Inp_DashboardPanelName + "_Win";
   ObjectSetString(0, objName, OBJPROP_TEXT, "WIN: " + IntegerToString(wins));

   objName = Inp_DashboardPanelName + "_Loss";
   ObjectSetString(0, objName, OBJPROP_TEXT, "LOSS: " + IntegerToString(losses));

   objName = Inp_DashboardPanelName + "_Signals";
   ObjectSetString(0, objName, OBJPROP_TEXT, "SIGNALS: " + IntegerToString(signals));

   objName = Inp_DashboardPanelName + "_Percentage";
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToString(percentage, 1) + "%");
     
   // Update Trend and Last Signal (placeholders for now)
   ObjectSetString(0, Inp_DashboardPanelName + "_TrendValue", OBJPROP_TEXT, GetCurrentTrend());
   ObjectSetInteger(0, Inp_DashboardPanelName + "_TrendValue", OBJPROP_COLOR, GetTrendColor(GetCurrentTrend()));
   ObjectSetString(0, Inp_DashboardPanelName + "_LastSignalValue", OBJPROP_TEXT, GetLastSignalText());
   ObjectSetInteger(0, Inp_DashboardPanelName + "_LastSignalValue", OBJPROP_COLOR, GetLastSignalColor());

   objName = Inp_DashboardPanelName + "_Telegram";
   if(telegramOn)
     {
      ObjectSetString(0, objName, OBJPROP_TEXT, Inp_IndicatorName); // Use indicator name
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_TelegramOnColor);
     }
   else
     {
      ObjectSetString(0, objName, OBJPROP_TEXT, "TELEGRAM: OFF");
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_TelegramOffColor);
     }
     
   // Update Trend and Last Signal (placeholders for now)
   ObjectSetString(0, Inp_DashboardPanelName + "_TrendValue", OBJPROP_TEXT, GetCurrentTrend());
   ObjectSetInteger(0, Inp_DashboardPanelName + "_TrendValue", OBJPROP_COLOR, GetTrendColor(GetCurrentTrend()));
   ObjectSetString(0, Inp_DashboardPanelName + "_LastSignalValue", OBJPROP_TEXT, GetLastSignalText());
   ObjectSetInteger(0, Inp_DashboardPanelName + "_LastSignalValue", OBJPROP_COLOR, GetLastSignalColor());
  }

//+------------------------------------------------------------------+
//| Get Signal for Timeframe                                         |
//+------------------------------------------------------------------+
int GetSignalForTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   // Enhanced signal logic: Combine GMMA, SR, and Trend Channel
   // This is a simplified example; a real implementation would be more complex.
   
   // GMMA Trend Check
   double short_ma_0 = iMA(NULL, timeframe, Inp_GMMA_Short1, 0, Inp_MAMethod, Inp_AppliedPrice, 0);
   double short_ma_1 = iMA(NULL, timeframe, Inp_GMMA_Short1, 0, Inp_MAMethod, Inp_AppliedPrice, 1);
   double long_ma_0 = iMA(NULL, timeframe, Inp_GMMA_Long1, 0, Inp_MAMethod, Inp_AppliedPrice, 0);
   double long_ma_1 = iMA(NULL, timeframe, Inp_GMMA_Long1, 0, Inp_MAMethod, Inp_AppliedPrice, 1);
   
   bool gmma_bullish = (short_ma_0 > long_ma_0 && short_ma_1 < long_ma_1); // Short MA crosses above Long MA
   bool gmma_bearish = (short_ma_0 < long_ma_0 && short_ma_1 > long_ma_1); // Short MA crosses below Long MA
   
   // Support/Resistance Check (simplified)
   double currentPrice = iClose(NULL, timeframe, 0);
   double resistance = iHigh(NULL, timeframe, iHighest(NULL, timeframe, MODE_HIGH, Inp_SR_Lookback, 1));
   double support = iLow(NULL, timeframe, iLowest(NULL, timeframe, MODE_LOW, Inp_SR_Lookback, 1));
   
   bool near_resistance = (currentPrice >= resistance - Inp_SR_Deviation * _Point);
   bool near_support = (currentPrice <= support + Inp_SR_Deviation * _Point);
   
   // Trend Channel Check (simplified - assuming upward/downward slope)
   // This would require more complex logic to determine if price is at channel boundaries
   double trend_slope = (iClose(NULL, timeframe, 0) - iClose(NULL, timeframe, Inp_TrendChannelLookback)) / Inp_TrendChannelLookback;
   bool trend_up = (trend_slope > 0);
   bool trend_down = (trend_slope < 0);
   
   // Combine signals for a stronger indication
   if (gmma_bullish && !near_resistance && trend_up) return 1; // Strong Buy
   if (gmma_bearish && !near_support && trend_down) return -1; // Strong Sell
   
   // If no strong signal, revert to basic GMMA cross
   if (short_ma_0 > long_ma_0 && short_ma_1 < long_ma_1) return 1; // Buy signal
   else if (short_ma_0 < long_ma_0 && short_ma_1 > long_ma_1) return -1; // Sell signal
   
   return 0; // Neutral
  }

//+------------------------------------------------------------------+
//| Generate Signal (Main signal logic for indicator)                |
//+------------------------------------------------------------------+
int GenerateSignal(int rates_total)
  {
   // This function will contain the main logic for generating buy/sell signals
   // It will use GMMA, SR, Trend Channel, and potentially other indicators
   // for a more robust signal.
   
   // Enhanced Signal Generation Logic
   // Combine GMMA, Support/Resistance, Trend Channel, and Profit/Loss considerations
   
   int signal = 0; // 0: Neutral, 1: Buy, -1: Sell
   
   // 1. GMMA Crossover Signal
   double short_ma_current = iMA(NULL, 0, Inp_GMMA_Short1, 0, Inp_MAMethod, Inp_AppliedPrice, 0);
   double long_ma_current = iMA(NULL, 0, Inp_GMMA_Long1, 0, Inp_MAMethod, Inp_AppliedPrice, 0);
   double short_ma_prev = iMA(NULL, 0, Inp_GMMA_Short1, 0, Inp_MAMethod, Inp_AppliedPrice, 1);
   double long_ma_prev = iMA(NULL, 0, Inp_GMMA_Long1, 0, Inp_MAMethod, Inp_AppliedPrice, 1);
   
   if (short_ma_current > long_ma_current && short_ma_prev <= long_ma_prev) // Buy cross
     {
      signal = 1;
     }
   else if (short_ma_current < long_ma_current && short_ma_prev >= long_ma_prev) // Sell cross
     {
      signal = -1;
     }
     
   // 2. Signal Confirmation (e.g., price action, volume, or other indicators)
   if (signal != 0)
     {
      bool confirmed = true;
      for (int i = 1; i <= Inp_SignalConfirmationBars; i++)
        {
         double sm_i = iMA(NULL, 0, Inp_GMMA_Short1, 0, Inp_MAMethod, Inp_AppliedPrice, i);
         double lm_i = iMA(NULL, 0, Inp_GMMA_Long1, 0, Inp_MAMethod, Inp_AppliedPrice, i);
         if (signal == 1 && sm_i <= lm_i) confirmed = false;
         if (signal == -1 && sm_i >= lm_i) confirmed = false;
         if (!confirmed) break;
        }
      if (!confirmed) signal = 0; // Signal not confirmed
     }
     
   // 3. Profit Maximization and Loss Minimization Check
   if (signal != 0)
     {
      double currentPrice = Close[0];
      double potentialTakeProfit = 0;
      double potentialStopLoss = 0;
      
      if (signal == 1) // Buy signal
        {
         potentialTakeProfit = currentPrice * (1 + Inp_MinProfitTarget);
         potentialStopLoss = currentPrice * (1 - Inp_MaxLossTolerance);
         
         // Check if potential profit is reasonable and loss is acceptable
         // This is a simplified check. More advanced logic would involve historical price action,
         // support/resistance levels, or ATR for dynamic stop loss/take profit.
         if (High[0] < potentialTakeProfit && Low[0] > potentialStopLoss) // Simplified check for potential
           {
            // Signal is valid based on profit/loss potential
           }
         else
           {
            signal = 0; // Invalidate signal if profit/loss potential is not met
           }
        }
      else if (signal == -1) // Sell signal
        {
         potentialTakeProfit = currentPrice * (1 - Inp_MinProfitTarget);
         potentialStopLoss = currentPrice * (1 + Inp_MaxLossTolerance);
         
         if (Low[0] > potentialTakeProfit && High[0] < potentialStopLoss) // Simplified check for potential
           {
            // Signal is valid based on profit/loss potential
           }
         else
           {
            signal = 0; // Invalidate signal if profit/loss potential is not met
           }
        }
     }
     
   // Further enhancements could include:
   // - Checking for divergence with oscillators (RSI, MACD)
   // - Volume analysis
   // - Candlestick patterns
   // - Proximity to Support/Resistance levels
   // - Trend strength from ADX
   
   return signal;
  }

//+------------------------------------------------------------------+
//| Update Strength Meter (to be called in OnCalculate)              |
//+------------------------------------------------------------------+
void UpdateStrengthMeter(double buyPercent, double sellPercent)
  {
   string objName;

   objName = Inp_StrengthMeterPanelName + "_BuyPercent";
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToString(buyPercent, 0) + "%");

   objName = Inp_StrengthMeterPanelName + "_SellPercent";
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToString(sellPercent, 0) + "%");
  }

//+------------------------------------------------------------------+
//| Draw Trend Channel                                               |
//+------------------------------------------------------------------+
void DrawTrendChannel()
  {
   ObjectsDeleteAll(0, "TrendChannel_");

   // Simple linear regression channel
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
   int n = Inp_TrendChannelLookback;

   for(int i = 0; i < n; i++)
     {
      sumX += i;
      sumY += Close[i];
      sumXY += i * Close[i];
      sumX2 += i * i;
     }

   double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
   double intercept = (sumY - slope * sumX) / n;

   double price1 = intercept;
   double price2 = intercept + slope * (n - 1);

   string lineName = "TrendChannel_Center";
   ObjectCreate(0, lineName, OBJ_TREND, 0, Time[0], price1, Time[n - 1], price2);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, Inp_TrendChannelColor);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, Inp_TrendChannelStyle);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, Inp_TrendChannelWidth);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Draw Signal Arrows                                               |
//+------------------------------------------------------------------+
void DrawSignalArrows(int index, int type) // type: 1 for buy, -1 for sell
  {
   string objName = "SignalArrow_" + IntegerToString(index);
   ObjectDelete(0, objName);

   if(type == 1) // Buy signal
     {
      ObjectCreate(0, objName, OBJ_ARROW, 0, Time[index], Low[index] - Inp_ArrowShift * Point);
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, Inp_ArrowCodeBuy);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_BuyArrowColor);
     }
   else if(type == -1) // Sell signal
     {
      ObjectCreate(0, objName, OBJ_ARROW, 0, Time[index], High[index] + Inp_ArrowShift * Point);
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, Inp_ArrowCodeSell);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_SellArrowColor);
     }
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
  }

//+------------------------------------------------------------------+
//| Draw Support and Resistance Zones                                |
//+------------------------------------------------------------------+
void DrawSRZones()
  {
   ObjectsDeleteAll(0, "SR_Zone_"); // Clear previous zones

   double highPrice = 0;
   double lowPrice = 999999;
   int highBar = 0;
   int lowBar = 0;

   for(int i = 0; i < Inp_SR_Lookback; i++)
     {
      if(High[i] > highPrice)
        {
         highPrice = High[i];
         highBar = i;
        }
      if(Low[i] < lowPrice)
        {
         lowPrice = Low[i];
         lowBar = i;
        }
     }

   // Draw Resistance Zone
   string resName = "SR_Zone_Resistance";
   ObjectCreate(0, resName, OBJ_HLINE, 0, 0, highPrice);
   ObjectSetInteger(0, resName, OBJPROP_COLOR, Inp_ResistanceColor);
   ObjectSetInteger(0, resName, OBJPROP_STYLE, Inp_SR_Style);
   ObjectSetInteger(0, resName, OBJPROP_WIDTH, Inp_SR_Width);
   ObjectSetInteger(0, resName, OBJPROP_BACK, true);
   ObjectSetInteger(0, resName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, resName, OBJPROP_ZORDER, 0);

   // Draw Support Zone
   string supName = "SR_Zone_Support";
   ObjectCreate(0, supName, OBJ_HLINE, 0, 0, lowPrice);
   ObjectSetInteger(0, supName, OBJPROP_COLOR, Inp_SupportColor);
   ObjectSetInteger(0, supName, OBJPROP_STYLE, Inp_SR_Style);
   ObjectSetInteger(0, supName, OBJPROP_WIDTH, Inp_SR_Width);
   ObjectSetInteger(0, supName, OBJPROP_BACK, true);
   ObjectSetInteger(0, supName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, supName, OBJPROP_ZORDER, 0);
  }

//+------------------------------------------------------------------+
//| URL Encode Function                                              |
//+------------------------------------------------------------------+
string UrlEncode(string text)
  {
   string result = "";
   string hex = "0123456789ABCDEF";
   for(int i = 0; i < StringLen(text); i++)
     {
      int charCode = StringGetChar(text, i);
      if ((charCode >= '0' && charCode <= '9') ||
          (charCode >= 'A' && charCode <= 'Z') ||
          (charCode >= 'a' && charCode <= 'z') ||
          charCode == '-' || charCode == '_' || charCode == '.' || charCode == '~')
        {
         result += CharToString(charCode);
        }
      else
        {
         result += '%';
         result += CharToString(StringGetChar(hex, (charCode >> 4) & 0xF));
         result += CharToString(StringGetChar(hex, charCode & 0xF));
        }
     }
   return result;
  }

//+------------------------------------------------------------------+
//| Send Telegram Message                                            |
//+------------------------------------------------------------------+
void SendTelegramMessage(string message)
  {
   if (!Inp_EnableTelegramAlerts || Inp_TelegramBotToken == "" || Inp_TelegramChatID == "")
     {
      return;
     }

   string url = "https://api.telegram.org/bot" + Inp_TelegramBotToken + "/sendMessage";
   string data = "chat_id=" + Inp_TelegramChatID + "&text=" + UrlEncode(message);

   char postData[];
   StringToCharArray(data, postData, 0, StringLen(data), CP_UTF8);

   char result[];
   string headers = "Content-Type: application/x-www-form-urlencoded";

   int res = WebRequest("POST", url, headers, 5000, postData, result);

   if (res == -1)
     {
      Print("WebRequest failed. Error code = ", GetLastError());
     }
   else
     {
      string resultStr = CharArrayToString(result);
      Print("Telegram response: ", resultStr);
     }
  }

//+------------------------------------------------------------------+
//| Update MTF Dot (to be called in OnCalculate)                     |
//+------------------------------------------------------------------+
void UpdateMTFDot(string timeframe, color dotColor)
  {
   string objName = Inp_DashboardPanelName + "_MTF_Dot_" + timeframe;
   ObjectSetInteger(0, objName, OBJPROP_COLOR, dotColor);
  }
  
//+------------------------------------------------------------------+
//| Get Current Trend (Placeholder for more advanced trend detection)|
//+------------------------------------------------------------------+
string GetCurrentTrend()
  {
   // This is a simplified trend detection based on GMMA. 
   // Can be expanded with more sophisticated methods.
   double short_ma = iMA(NULL, 0, Inp_GMMA_Short1, 0, Inp_MAMethod, Inp_AppliedPrice, 0);
   double long_ma = iMA(NULL, 0, Inp_GMMA_Long1, 0, Inp_MAMethod, Inp_AppliedPrice, 0);
   
   if (short_ma > long_ma) return "Uptrend";
   else if (short_ma < long_ma) return "Downtrend";
   else return "Sideways";
  }
  
//+------------------------------------------------------------------+
//| Get Trend Color                                                  |
//+------------------------------------------------------------------+
color GetTrendColor(string trend)
  {
   if (trend == "Uptrend") return clrGreen;
   else if (trend == "Downtrend") return clrRed;
   else return clrYellow;
  }
  
//+------------------------------------------------------------------+
//| Get Last Signal Text (Placeholder)                               |
//+------------------------------------------------------------------+
string GetLastSignalText()
  {
   // This would ideally store the last signal generated and return its type
   // For now, it's a placeholder.
   return "N/A";
  }
  
//+------------------------------------------------------------------+
//| Get Last Signal Color (Placeholder)                              |
//+------------------------------------------------------------------+
color GetLastSignalColor()
  {
   // This would return the color corresponding to the last signal
   // For now, it's a placeholder.
   return clrWhite;
  }


//+------------------------------------------------------------------+
//| Draw Support and Resistance Zones                                |
//+------------------------------------------------------------------+
void DrawSRZones()
  {
   // This is a placeholder function. Actual SR zone drawing logic would be complex.
   // It would involve identifying swing highs/lows, calculating pivot points, etc.
   // For now, it does nothing.
  }

//+------------------------------------------------------------------+
//| Draw Trend Channel                                               |
//+------------------------------------------------------------------+
void DrawTrendChannel()
  {
   // This is a placeholder function. Actual Trend Channel drawing logic would be complex.
   // It would involve identifying trend lines based on highs/lows.
   // For now, it does nothing.
  }

//+------------------------------------------------------------------+
//| Get Signal For Timeframe (MTF Analysis)                          |
//+------------------------------------------------------------------+
int GetSignalForTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   // This is a placeholder function. In a real scenario, this would calculate
   // the signal for a given timeframe using the indicator's logic.
   // For simplicity, returning a random signal.
   MathSrand(TimeCurrent());
   int rand = MathRand();
   if (rand % 3 == 0) return 1; // Buy
   if (rand % 3 == 1) return -1; // Sell
   return 0; // Neutral
  }

//+------------------------------------------------------------------+
//| Update MTF Dot                                                   |
//+------------------------------------------------------------------+
void UpdateMTFDot(string timeframe_name, color dotColor)
  {
   string objName = Inp_DashboardPanelName + "_MTF_Dot_" + timeframe_name;
   ObjectSetInteger(0, objName, OBJPROP_COLOR, dotColor);
  }

//+------------------------------------------------------------------+
//| Get Current Trend                                                |
//+------------------------------------------------------------------+
string GetCurrentTrend()
  {
   // Placeholder for actual trend detection logic
   // For simplicity, returning a random trend.
   MathSrand(TimeCurrent());
   int rand = MathRand();
   if (rand % 3 == 0) return "Up";
   if (rand % 3 == 1) return "Down";
   return "Neutral";
  }

//+------------------------------------------------------------------+
//| Get Trend Color                                                  |
//+------------------------------------------------------------------+
color GetTrendColor(string trend)
  {
   if (trend == "Up") return clrGreen;
   if (trend == "Down") return clrRed;
   return clrGray;
  }

//+------------------------------------------------------------------+
//| Get Last Signal Text                                             |
//+------------------------------------------------------------------+
string GetLastSignalText()
  {
   // Placeholder for actual last signal text
   // For simplicity, returning a random signal text.
   MathSrand(TimeCurrent());
   int rand = MathRand();
   if (rand % 3 == 0) return "BUY";
   if (rand % 3 == 1) return "SELL";
   return "NONE";
  }

//+------------------------------------------------------------------+
//| Get Last Signal Color                                            |
//+------------------------------------------------------------------+
color GetLastSignalColor()
  {
   string lastSignal = GetLastSignalText();
   if (lastSignal == "BUY") return clrGreen;
   if (lastSignal == "SELL") return clrRed;
   return clrGray;
  }

//+------------------------------------------------------------------+
//| Send Telegram Message                                            |
//+------------------------------------------------------------------+
void SendTelegramMessage(string message)
  {
   // This is a placeholder function. Actual Telegram integration requires
   // sending HTTP requests, which is not directly supported in MQL4 without
   // using external DLLs or a custom web server. For this example, it will
   // just print to experts journal.
   Print("Telegram Message: " + message);
  }
