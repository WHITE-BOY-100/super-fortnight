//+------------------------------------------------------------------+
//|                                            EliteTradersIndicator.mq4 |
//|                                                     Manus AI |
//|                                        https://www.manus.im |
//+------------------------------------------------------------------+
#property copyright "Manus AI"
#property link      "https://www.manus.im"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- input parameters
input string Inp_IndicatorName = "Elite Traders Indicator";
input string Inp_DashboardPanelName = "EliteTradersDashboard";
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

//--- Guppy MMA parameters
input int Inp_ShortTermMMAPeriods = 3; // Example, adjust as needed
input int Inp_LongTermMMAPeriods = 5; // Example, adjust as needed
input color Inp_ShortTermMMAColor = clrAqua;
input color Inp_LongTermMMAColor = clrLimeGreen;
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






double ExtShortTermBuffer[];
double ExtLongTermBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   CreateDashboard();
   CreateStrengthMeter();
//--- indicator buffers mapping
   SetIndexBuffer(0, ExtShortTermBuffer);
   SetIndexBuffer(1, ExtLongTermBuffer);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, Inp_ShortTermMMAColor);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, Inp_LongTermMMAColor);
   SetIndexLabel(0, "Short Term MMA");
   SetIndexLabel(1, "Long Term MMA");


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
      ExtShortTermBuffer[i] = iMA(NULL, 0, Inp_ShortTermMMAPeriods, 0, Inp_MAMethod, Inp_AppliedPrice, i);
      ExtLongTermBuffer[i] = iMA(NULL, 0, Inp_LongTermMMAPeriods, 0, Inp_MAMethod, Inp_AppliedPrice, i);
     }

//--- 
   UpdateDashboard(19, 2, 21, 90.5, true); // Placeholder values
   DrawSRZones();
   DrawTrendChannel();
   // For testing, let's draw a buy signal on the last bar if close > open
   if(Close[0] > Open[0]) DrawSignalArrows(0, 1);
   else if (Close[0] < Open[0]) DrawSignalArrows(0, -1);
   UpdateStrengthMeter(78, 22); // Placeholder values

   // Update MTF dots
   string timeframes[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1"};
   ENUM_TIMEFRAMES enumTimeframes[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};
   for(int i=0; i<ArraySize(timeframes); i++)
     {
      int signal = GetSignalForTimeframe(enumTimeframes[i]);
      color dotColor = Inp_MTF_NeutralColor;
      if (signal == 1) dotColor = Inp_MTF_BuyColor;
      else if (signal == -1) dotColor = Inp_MTF_SellColor;
      UpdateMTFDot(timeframes[i], dotColor);
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Create Dashboard                                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create Strength Meter                                            |
//+------------------------------------------------------------------+
void CreateStrengthMeter()
  {
   string objName;
   int corner = Inp_StrengthMeterCorner;
   int x = Inp_StrengthMeterX;
   int y = Inp_StrengthMeterY;
   int width = 100;
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
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   // Sell Percentage
   objName = Inp_StrengthMeterPanelName + "_SellPercent";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 25);
   ObjectSetString(0, objName, OBJPROP_TEXT, "0%");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_StrengthMeterSellColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
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
   int width = 200;
   int height = 150;

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
   ObjectSetString(0, objName, OBJPROP_TEXT, "ELITE TRADERS");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardTextColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
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
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
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
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
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
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
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
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

   // Telegram Status
   objName = Inp_DashboardPanelName + "_Telegram";
   ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 60);
   ObjectSetString(0, objName, OBJPROP_TEXT, "A TELEGRAM: ON");
   ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_TelegramOnColor);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
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
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 80);
      ObjectSetString(0, objName, OBJPROP_TEXT, timeframes[i]);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_DashboardTextColor);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);

      objName = Inp_DashboardPanelName + "_MTF_Dot_" + timeframes[i];
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x + 5 + i*20);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y + 95);
      ObjectSetString(0, objName, OBJPROP_TEXT, "\x00B7"); // Bullet point character
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, objName, OBJPROP_FONT, "Wingdings");
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, objName, OBJPROP_ZORDER, 1);
     }
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

   objName = Inp_DashboardPanelName + "_Telegram";
   if(telegramOn)
     {
      ObjectSetString(0, objName, OBJPROP_TEXT, "A TELEGRAM: ON");
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_TelegramOnColor);
     }
   else
     {
      ObjectSetString(0, objName, OBJPROP_TEXT, "A TELEGRAM: OFF");
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Inp_TelegramOffColor);
     }
  }

//+------------------------------------------------------------------+
//| Update MTF Dot (to be called in OnCalculate)                     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Get Signal for Timeframe                                         |
//+------------------------------------------------------------------+
int GetSignalForTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   // For simplicity, a basic signal: buy if close > open, sell if close < open
   // In a real indicator, this would involve more complex logic
   double currentClose = iClose(NULL, timeframe, 0);
   double currentOpen = iOpen(NULL, timeframe, 0);

   if (currentClose > currentOpen) return 1; // Buy signal
   else if (currentClose < currentOpen) return -1; // Sell signal
   else return 0; // Neutral
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
   ObjectCreate(0, resName, OBJ_RECTANGLE, 0, Time[highBar], highPrice + Inp_SR_Deviation, Time[highBar], highPrice - Inp_SR_Deviation);
   ObjectSetInteger(0, resName, OBJPROP_COLOR, Inp_ResistanceColor);
   ObjectSetInteger(0, resName, OBJPROP_STYLE, Inp_SR_Style);
   ObjectSetInteger(0, resName, OBJPROP_WIDTH, Inp_SR_Width);
   ObjectSetInteger(0, resName, OBJPROP_BACK, true);
   ObjectSetInteger(0, resName, OBJPROP_SELECTABLE, false);

   // Draw Support Zone
   string supName = "SR_Zone_Support";
   ObjectCreate(0, supName, OBJ_RECTANGLE, 0, Time[lowBar], lowPrice + Inp_SR_Deviation, Time[lowBar], lowPrice - Inp_SR_Deviation);
   ObjectSetInteger(0, supName, OBJPROP_COLOR, Inp_SupportColor);
   ObjectSetInteger(0, supName, OBJPROP_STYLE, Inp_SR_Style);
   ObjectSetInteger(0, supName, OBJPROP_WIDTH, Inp_SR_Width);
   ObjectSetInteger(0, supName, OBJPROP_BACK, true);
   ObjectSetInteger(0, supName, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
