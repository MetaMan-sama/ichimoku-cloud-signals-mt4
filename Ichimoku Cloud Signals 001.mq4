//+------------------------------------------------------------------+
//|                     IchimokuCloudSignals.mq4                     |
//| Alerts for Ichimoku Cloud signals                                |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string TradeSymbol = "EURUSD";        // Symbol for analysis
input ENUM_TIMEFRAMES Timeframe = PERIOD_H1; // Timeframe for analysis
input bool EnableCloudAlerts = true;        // Alert for price entering/exiting the cloud
input bool EnableTenkanKijunCross = true;   // Alert for Tenkan-Sen crossing Kijun-Sen
input bool EnableLaggingSpanCross = true;   // Alert for Lagging Span crossing price/cloud
input bool EnableAlerts = true;             // Enable sound alerts
input bool EnableEmail = false;             // Enable email notifications
input bool EnablePush = false;              // Enable push notifications

// Ichimoku parameters
input int TenkanSenPeriod = 9;              // Tenkan-Sen period
input int KijunSenPeriod = 26;              // Kijun-Sen period
input int SenkouSpanBPeriod = 52;           // Senkou Span B period

//+------------------------------------------------------------------+
//| Main Function                                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("Ichimoku Cloud Signals Script Started.");

   while (!IsStopped()) {
      // Calculate Ichimoku values
      double tenkanSen = iIchimoku(TradeSymbol, Timeframe, TenkanSenPeriod, KijunSenPeriod, SenkouSpanBPeriod, MODE_TENKANSEN, 0);
      double kijunSen = iIchimoku(TradeSymbol, Timeframe, TenkanSenPeriod, KijunSenPeriod, SenkouSpanBPeriod, MODE_KIJUNSEN, 0);
      double senkouSpanA = iIchimoku(TradeSymbol, Timeframe, TenkanSenPeriod, KijunSenPeriod, SenkouSpanBPeriod, MODE_SENKOUSPANA, 26);
      double senkouSpanB = iIchimoku(TradeSymbol, Timeframe, TenkanSenPeriod, KijunSenPeriod, SenkouSpanBPeriod, MODE_SENKOUSPANB, 26);
      double chikouSpan = iIchimoku(TradeSymbol, Timeframe, TenkanSenPeriod, KijunSenPeriod, SenkouSpanBPeriod, MODE_CHIKOUSPAN, 0);
      double currentPrice = iClose(TradeSymbol, Timeframe, 0);

      // Check for price entering or exiting the cloud
      if (EnableCloudAlerts) {
         CheckCloudSignals(currentPrice, senkouSpanA, senkouSpanB);
      }

      // Check for Tenkan-Sen and Kijun-Sen cross
      if (EnableTenkanKijunCross) {
         CheckTenkanKijunCross(tenkanSen, kijunSen);
      }

      // Check for Lagging Span cross
      if (EnableLaggingSpanCross) {
         CheckLaggingSpanCross(chikouSpan, senkouSpanA, senkouSpanB, currentPrice);
      }

      Sleep(60000); // Wait 1 minute before checking again
   }
}

//+------------------------------------------------------------------+
//| Check for price entering or exiting the cloud                   |
//+------------------------------------------------------------------+
void CheckCloudSignals(double price, double senkouA, double senkouB)
{
   double upperCloud = MathMax(senkouA, senkouB);
   double lowerCloud = MathMin(senkouA, senkouB);

   if (price > lowerCloud && price < upperCloud) {
      AlertIchimokuSignal("Price entered the cloud.");
   } else if (price > upperCloud || price < lowerCloud) {
      AlertIchimokuSignal("Price exited the cloud.");
   }
}

//+------------------------------------------------------------------+
//| Check for Tenkan-Sen and Kijun-Sen cross                        |
//+------------------------------------------------------------------+
void CheckTenkanKijunCross(double tenkan, double kijun)
{
   static bool wasAbove = false;

   bool isAbove = tenkan > kijun;
   if (wasAbove && tenkan < kijun) {
      AlertIchimokuSignal("Tenkan-Sen crossed below Kijun-Sen (Bearish Cross).");
   } else if (!wasAbove && tenkan > kijun) {
      AlertIchimokuSignal("Tenkan-Sen crossed above Kijun-Sen (Bullish Cross).");
   }

   wasAbove = isAbove;
}

//+------------------------------------------------------------------+
//| Check for Lagging Span cross                                    |
//+------------------------------------------------------------------+
void CheckLaggingSpanCross(double chikou, double senkouA, double senkouB, double price)
{
   if (chikou > price) {
      AlertIchimokuSignal("Lagging Span crossed above the price.");
   } else if (chikou < price) {
      AlertIchimokuSignal("Lagging Span crossed below the price.");
   }

   double upperCloud = MathMax(senkouA, senkouB);
   double lowerCloud = MathMin(senkouA, senkouB);

   if (chikou > upperCloud) {
      AlertIchimokuSignal("Lagging Span crossed above the cloud.");
   } else if (chikou < lowerCloud) {
      AlertIchimokuSignal("Lagging Span crossed below the cloud.");
   }
}

//+------------------------------------------------------------------+
//| Send alert notifications                                        |
//+------------------------------------------------------------------+
void AlertIchimokuSignal(string message)
{
   if (EnableAlerts) Alert(message);
   if (EnableEmail) SendMail("Ichimoku Cloud Alert", message);
   if (EnablePush) SendNotification(message);

   Print(message);
}
