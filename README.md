# Ichimoku Cloud Signals — MQL4 Script

A MetaTrader 4 script that monitors three independent **Ichimoku Kinko Hyo signal types** simultaneously — cloud entry/exit via Senkou Span A and B boundaries, Tenkan-sen / Kijun-sen crossovers via a persistent `wasAbove` static boolean, and Chikou Span / Lagging Span cloud-cross alerts — computing all five Ichimoku lines via `iIchimoku()` each cycle and dispatching alerts through a shared `AlertIchimokuSignal()` dispatcher with three configurable notification channels.

---

## Overview

Ichimoku Kinko Hyo — meaning "equilibrium at a glance" in Japanese — is a comprehensive multi-element charting system developed by journalist Goichi Hosoda and published in 1969. Unlike most indicators that reduce price action to a single line, Ichimoku simultaneously displays trend direction, momentum, support/resistance levels, and projected future support/resistance through five distinct components: the Tenkan-sen (conversion line), Kijun-sen (base line), Senkou Span A (leading span A, the faster cloud boundary), Senkou Span B (leading span B, the slower cloud boundary), and the Chikou Span (lagging span, the current close plotted 26 bars back). The cloud itself — the shaded area between Senkou Span A and B — is the system's defining feature: price above the cloud indicates bullish bias, price below indicates bearish bias, and price inside the cloud represents a transition or equilibrium zone. This script monitors all three primary Ichimoku signal types in a single continuous loop, giving traders comprehensive real-time Ichimoku coverage without requiring chart overlays.

---

## Features

- **Cloud entry/exit detection** — `CheckCloudSignals()`: `upperCloud = MathMax(senkou A, senkou B)`, `lowerCloud = MathMin(...)`: `price > lowerCloud && price < upperCloud` → **Price entered the cloud**; `price > upperCloud || price < lowerCloud` → **Price exited the cloud**
- **Tenkan/Kijun crossover detection** — `CheckTenkanKijunCross()`: `static bool wasAbove` persists across cycles; `isAbove = tenkan > kijun`; sign-change detection fires **Tenkan-Sen crossed above Kijun-Sen (Bullish Cross)** or **crossed below (Bearish Cross)**; `wasAbove` updated at end
- **Lagging Span / Chikou cloud-cross detection** — `CheckLaggingSpanCross()`: compares `chikou` (current close shifted 26 bars back) against `upperCloud` and `lowerCloud` — `chikou > upperCloud` → **Lagging Span crossed above the cloud**; `chikou < lowerCloud` → **Lagging Span crossed below the cloud**
- **Full five-line `iIchimoku()` resolution** — `TenkanSenPeriod`, `KijunSenPeriod`, `SenkouSpanBPeriod` all configurable; `MODE_TENKANSEN`, `MODE_KIJUNSEN`, `MODE_SENKOUSPANA`, `MODE_SENKOUSPAN B`, `MODE_CHIKOUSPAN` fetched each cycle at bar 0 (cloud values at bar 26 for lagging span)
- **Three independent alert gates** — `EnableCloudAlerts`, `EnableTenkanKijunCross`, `EnableLaggingSpanCross` boolean flags allow selective signal monitoring without source modification
- **Three notification channels:** sound alert, email, and mobile push via shared `AlertIchimokuSignal()` dispatcher
- **Lightweight loop** — polls once per minute (`Sleep(60000)`)

---

## How It Works

1. Every minute, `iIchimoku()` is called five times to resolve all Ichimoku components for the current bar
2. Three independent condition blocks evaluate based on their respective enable flags:
   - `EnableCloudAlerts` → `CheckCloudSignals(price, senkou A, senkou B)`
   - `EnableTenkanKijunCross` → `CheckTenkanKijunCross(tenkan, kijun)` with static `wasAbove`
   - `EnableLaggingSpanCross` → `CheckLaggingSpanCross(chikou, senkou A, senkou B)`
3. All alerts routed through `AlertIchimokuSignal(message)` which dispatches via `Alert()`, `SendMail()`, `SendNotification()` per enabled flags

---

## Input Parameters

| Parameter                  | Type            | Default     | Description                                                 |
|----------------------------|-----------------|-------------|-------------------------------------------------------------|
| `TradeSymbol`              | string          | `EURUSD`    | Symbol for analysis                                         |
| `Timeframe`                | ENUM_TIMEFRAMES | `PERIOD_H1` | Timeframe for analysis                                      |
| `TenkanSenPeriod`          | int             | `9`         | Tenkan-sen (conversion line) period                         |
| `KijunSenPeriod`           | int             | `26`        | Kijun-sen (base line) period                                |
| `SenkouSpanBPeriod`        | int             | `52`        | Senkou Span B (slow cloud boundary) period                  |
| `EnableCloudAlerts`        | bool            | `true`      | Fire alerts on price entering or exiting the cloud          |
| `EnableTenkanKijunCross`   | bool            | `true`      | Fire alerts on Tenkan-sen / Kijun-sen crossovers            |
| `EnableLaggingSpanCross`   | bool            | `true`      | Fire alerts on Chikou Span cloud crosses                    |
| `EnableAlerts`             | bool            | `true`      | Fire an on-screen/sound alert                               |
| `EnableEmail`              | bool            | `false`     | Send an email notification                                  |
| `EnablePush`               | bool            | `false`     | Send a mobile push notification                             |

---

## Alert Message Examples

```
Price entered the cloud.
Tenkan-Sen crossed above Kijun-Sen (Bullish Cross).
Lagging Span crossed above the cloud.
```

---

## Installation

1. Copy `Ichimoku_Cloud_Signals_001.mq4` to `MQL4/Scripts/` in your MT4 data folder
2. Compile in MetaEditor (F7)
3. Drag onto any chart from Navigator → Scripts
4. Configure inputs and click **OK**

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
