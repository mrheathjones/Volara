# Volara

A native macOS companion app for learning and practicing **options trading** alongside TradingView — built for beginners trading options on Robinhood.

> ⚠️ **Educational use only.** Volara is a learning and paper-trading tool. Nothing in it is financial advice. Options are risky and you can lose your entire premium. Do your own research and never risk money you can't afford to lose.

![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6-orange) ![UI](https://img.shields.io/badge/UI-SwiftUI-green)

## Features

- **Dashboard** — live market overview for SPY, QQQ, AAPL, TSLA, NVDA with price, 1-day change, a 30-day sparkline, RSI, and a CALL/PUT/NEUTRAL signal badge.
- **Signal Scanner** — scans a watchlist of 15 liquid tickers against the same logic as the TradingView Pine indicator (RSI, Bollinger Bands, EMA cross, volume, squeeze). Filter and sort, then open a per-ticker breakdown with an ATR-based suggested strike zone and an "Open in TradingView" shortcut.
- **Options Calculator** — a live Black-Scholes calculator: premium, Delta, Theta (per day), Vega, Gamma, breakeven, and a "what if the stock moves ±X%" scenario slider.
- **Learn** — 10 hand-written lessons covering options basics, the Greeks, reading the indicator, strike/expiration selection, risk management, IV, option chains, and common beginner mistakes. Progress is tracked.
- **Trade Journal** — log paper trades, track open vs. closed positions, and see win rate, average P&L %, and total P&L.
- **Settings** — customize the scanner watchlist, default contracts, risk-per-trade %, and account size (for position sizing).

## Tech

- **SwiftUI** only, `@Observable` state (no `ObservableObject`), `NavigationSplitView` sidebar layout
- **Swift 6** language mode with `MainActor` default actor isolation (strict concurrency, data-race safe)
- **macOS 14 (Sonoma)** minimum deployment target
- Apple **Charts** framework for sparklines
- Market data from the free Yahoo Finance v8 chart endpoint via `URLSession` async/await — no API key, no third-party dependencies
- All indicators (SMA, EMA, Wilder RSI, Bollinger Bands, Wilder ATR) and the Black-Scholes engine are pure, unit-tested functions

## Build & Run

Open in Xcode (recommended):

```bash
open Volara.xcodeproj
# then press ⌘R
```

Or from the command line:

```bash
xcodebuild -project Volara.xcodeproj -scheme Volara -configuration Debug -destination 'platform=macOS' build
```

Run the tests:

```bash
xcodebuild test -project Volara.xcodeproj -scheme Volara -destination 'platform=macOS' -only-testing:VolaraTests
```

## Architecture

Feature-folder structure under `Volara/`:

```
App/         — entry point, RootView (sidebar), AppEnvironment (DI container)
Models/      — pure value types (signals, trades, lessons, analysis)
Services/    — TechnicalIndicators, GreeksCalculator, SignalEvaluator,
               StockDataService (Yahoo), PersistenceService
Features/    — Dashboard, Scanner, Calculator, Learn, Journal, Settings
Shared/      — reusable components + design-system extensions
```

State persists locally: the trade journal as JSON in the app's Application Support container, lesson progress and settings in `UserDefaults`.

## Limitations

- Market data uses Yahoo Finance's **unofficial** public endpoint. It can rate-limit, change shape, or go down; the app degrades gracefully to an inline error state when a fetch fails.
- Prices reflect the last available close, not a real-time streaming quote.
- The app is sandboxed with only the outbound-network entitlement; it never accesses your files beyond its own container.
