import Foundation

nonisolated enum SignalEvaluator {
    static func dashboardSignal(for a: TickerAnalysis) -> SignalType {
        if a.price > a.sma20 && a.rsi < 70 {
            return .call
        }
        if a.price < a.sma20 && a.rsi > 30 {
            return .put
        }
        return .neutral
    }

    static func scannerSignal(for a: TickerAnalysis) -> ScanSignal {
        let strikeLow = a.price - 1.5 * a.atr
        let strikeHigh = a.price + 1.5 * a.atr
        let atrExplanation = String(
            format: "%@ moves about $%.2f per day on average.",
            a.symbol, a.atr
        )
        let expirationHint = "Look for options expiring in 14-28 days."

        // Proximity bands (within 0.5%).
        let lowerBandThreshold = a.bollinger.lower * 1.005
        let upperBandThreshold = a.bollinger.upper * 0.995

        let callCondition = a.rsi < 35
            && a.price <= lowerBandThreshold
            && a.ema9 > a.ema21
            && a.volumeRatio > 1.5

        let putCondition = a.rsi > 65
            && a.price >= upperBandThreshold
            && a.ema9 < a.ema21
            && a.volumeRatio > 1.5

        let squeezeCondition = a.bbWidthPct < a.lowestBBWidth20 * 1.05

        let signal: SignalType
        var conditions: [String] = []

        if callCondition {
            signal = .call
            conditions.append(String(format: "RSI is oversold at %.1f (below 35).", a.rsi))
            conditions.append("Price is at or below the lower Bollinger Band.")
            conditions.append("Short-term EMA (9) is above the long-term EMA (21).")
            conditions.append(String(format: "Volume is %.1fx the average.", a.volumeRatio))
        } else if putCondition {
            signal = .put
            conditions.append(String(format: "RSI is overbought at %.1f (above 65).", a.rsi))
            conditions.append("Price is at or above the upper Bollinger Band.")
            conditions.append("Short-term EMA (9) is below the long-term EMA (21).")
            conditions.append(String(format: "Volume is %.1fx the average.", a.volumeRatio))
        } else if squeezeCondition {
            signal = .squeeze
            conditions.append(String(
                format: "Bollinger Band width (%.2f%%) is near its 20-day low — a squeeze is forming.",
                a.bbWidthPct
            ))
        } else {
            signal = .neutral
            conditions.append("No strong setup right now. Conditions are mixed.")
        }

        return ScanSignal(
            signal: signal,
            triggeredConditions: conditions,
            strikeLow: strikeLow,
            strikeHigh: strikeHigh,
            atrExplanation: atrExplanation,
            expirationHint: expirationHint
        )
    }
}
