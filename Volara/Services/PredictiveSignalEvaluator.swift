import Foundation

/// Produces a heuristic breakout/breakdown bias for a ticker by weighing the confluence
/// of trend (EMA cross), momentum (MACD), RSI, Bollinger-band position (%B), and
/// price-vs-average. Designed to give squeeze setups a directional lean, but valid for
/// any ticker. This is an explainable bias score — not a forecast or financial advice.
nonisolated enum PredictiveSignalEvaluator {
    // Maximum achievable absolute score (sum of per-factor weights), used to scale confidence.
    private static let maxScore = 6.5

    static func predict(for a: TickerAnalysis) -> PredictiveSignal {
        let macd = a.macd
        var score = 0.0
        var rationale: [String] = []

        // Trend — 9-EMA vs 21-EMA (weight 1.5)
        if a.ema9 > a.ema21 {
            score += 1.5
            rationale.append("Short-term trend is up: the 9-EMA is above the 21-EMA.")
        } else {
            score -= 1.5
            rationale.append("Short-term trend is down: the 9-EMA is below the 21-EMA.")
        }

        // Momentum — MACD histogram and its slope (weight up to 2.0)
        if macd.histogram > 0 {
            score += macd.histogramRising ? 2.0 : 1.0
            rationale.append("MACD histogram is positive\(macd.histogramRising ? " and rising" : ""), upward momentum is building.")
        } else if macd.histogram < 0 {
            score -= macd.histogramRising ? 1.0 : 2.0
            rationale.append("MACD histogram is negative\(macd.histogramRising ? " but turning up" : " and falling"), downward momentum is building.")
        }

        // RSI lean around the 50 midline (weight up to 1.0)
        score += max(-1, min(1, (a.rsi - 50) / 50))
        if a.rsi >= 55 {
            rationale.append(String(format: "RSI at %.0f is above the midline, favoring upside.", a.rsi))
        } else if a.rsi <= 45 {
            rationale.append(String(format: "RSI at %.0f is below the midline, favoring downside.", a.rsi))
        }

        // Bollinger position — %B (weight up to 1.0)
        let bandWidth = a.bollinger.upper - a.bollinger.lower
        let percentB = bandWidth > 0 ? (a.price - a.bollinger.lower) / bandWidth : 0.5
        score += max(-1, min(1, (percentB - 0.5) * 2))
        if percentB >= 0.6 {
            rationale.append("Price is pressing the upper half of the Bollinger Bands.")
        } else if percentB <= 0.4 {
            rationale.append("Price is hugging the lower half of the Bollinger Bands.")
        }

        // Price vs 20-day average (weight 1.0)
        if a.price > a.sma20 {
            score += 1.0
            rationale.append("Price is trading above its 20-day average.")
        } else {
            score -= 1.0
            rationale.append("Price is trading below its 20-day average.")
        }

        let confidence = min(100, abs(score) / maxScore * 100)
        let direction: BreakoutDirection
        if abs(score) < 0.75 {
            direction = .neutral
        } else if score > 0 {
            direction = .breakout
        } else {
            direction = .breakdown
        }

        return PredictiveSignal(direction: direction, confidence: confidence, rationale: rationale)
    }
}
