import Foundation

nonisolated enum TechnicalIndicators {
    static func sma(_ values: [Double], period: Int) -> Double? {
        guard period > 0, values.count >= period else { return nil }
        let window = values.suffix(period)
        return window.reduce(0, +) / Double(period)
    }

    static func ema(_ values: [Double], period: Int) -> Double? {
        emaSeries(values, period: period).last
    }

    static func emaSeries(_ values: [Double], period: Int) -> [Double] {
        guard period > 0, values.count >= period else { return [] }
        let multiplier = 2.0 / (Double(period) + 1.0)
        var result: [Double] = []
        // Seed with SMA of the first `period` values.
        let seed = values.prefix(period).reduce(0, +) / Double(period)
        var prev = seed
        result.append(prev)
        for i in period..<values.count {
            let value = values[i]
            prev = (value - prev) * multiplier + prev
            result.append(prev)
        }
        return result
    }

    static func rsi(_ closes: [Double], period: Int = 14) -> Double? {
        guard period > 0, closes.count >= period + 1 else { return nil }

        var gains: [Double] = []
        var losses: [Double] = []
        for i in 1..<closes.count {
            let change = closes[i] - closes[i - 1]
            gains.append(max(change, 0))
            losses.append(max(-change, 0))
        }

        // Initial averages over the first `period` changes.
        var avgGain = gains.prefix(period).reduce(0, +) / Double(period)
        var avgLoss = losses.prefix(period).reduce(0, +) / Double(period)

        // Wilder smoothing for the remainder.
        for i in period..<gains.count {
            avgGain = (avgGain * Double(period - 1) + gains[i]) / Double(period)
            avgLoss = (avgLoss * Double(period - 1) + losses[i]) / Double(period)
        }

        if avgLoss == 0 {
            return 100
        }
        let rs = avgGain / avgLoss
        return 100 - (100 / (1 + rs))
    }

    static func bollingerBands(_ closes: [Double], period: Int = 20, multiplier: Double = 2) -> BollingerBands? {
        guard period > 0, closes.count >= period else { return nil }
        let window = Array(closes.suffix(period))
        let mean = window.reduce(0, +) / Double(period)
        let variance = window.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(period)
        let stdDev = variance.squareRoot()
        let upper = mean + multiplier * stdDev
        let lower = mean - multiplier * stdDev
        let width = mean != 0 ? (upper - lower) / mean * 100 : 0
        return BollingerBands(middle: mean, upper: upper, lower: lower, width: width)
    }

    static func bbWidthSeries(_ closes: [Double], period: Int = 20, multiplier: Double = 2) -> [Double] {
        guard period > 0, closes.count >= period else { return [] }
        var result: [Double] = []
        for end in period...closes.count {
            let window = Array(closes[(end - period)..<end])
            let mean = window.reduce(0, +) / Double(period)
            let variance = window.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(period)
            let stdDev = variance.squareRoot()
            let upper = mean + multiplier * stdDev
            let lower = mean - multiplier * stdDev
            let width = mean != 0 ? (upper - lower) / mean * 100 : 0
            result.append(width)
        }
        return result
    }

    static func atr(highs: [Double], lows: [Double], closes: [Double], period: Int = 14) -> Double? {
        guard period > 0,
              highs.count == lows.count,
              lows.count == closes.count,
              closes.count >= period + 1 else { return nil }

        var trueRanges: [Double] = []
        for i in 1..<closes.count {
            let highLow = highs[i] - lows[i]
            let highClose = abs(highs[i] - closes[i - 1])
            let lowClose = abs(lows[i] - closes[i - 1])
            trueRanges.append(max(highLow, highClose, lowClose))
        }

        guard trueRanges.count >= period else { return nil }

        // Initial ATR = simple average of first `period` true ranges.
        var atrValue = trueRanges.prefix(period).reduce(0, +) / Double(period)
        // Wilder smoothing.
        for i in period..<trueRanges.count {
            atrValue = (atrValue * Double(period - 1) + trueRanges[i]) / Double(period)
        }
        return atrValue
    }

    /// MACD(fast, slow, signal) for the latest bar. Returns nil if there aren't enough bars.
    static func macd(_ closes: [Double], fast: Int = 12, slow: Int = 26, signalPeriod: Int = 9) -> MACDResult? {
        guard fast > 0, slow > fast, signalPeriod > 0,
              closes.count >= slow + signalPeriod else { return nil }

        let emaFast = fullEMA(closes, period: fast)
        let emaSlow = fullEMA(closes, period: slow)
        let macdLine = zip(emaFast, emaSlow).map { $0 - $1 }
        let signalLine = fullEMA(macdLine, period: signalPeriod)

        guard macdLine.count >= 2, signalLine.count >= 2,
              let macd = macdLine.last, let signal = signalLine.last else { return nil }

        let histogram = macd - signal
        let prevHistogram = macdLine[macdLine.count - 2] - signalLine[signalLine.count - 2]
        return MACDResult(
            macd: macd,
            signal: signal,
            histogram: histogram,
            histogramRising: histogram > prevHistogram
        )
    }

    /// Annualized historical (realized) volatility from daily closes, as a percent.
    /// A reasonable default for the options calculator when no live IV is available.
    static func historicalVolatilityPercent(_ closes: [Double]) -> Double? {
        guard closes.count >= 10 else { return nil }
        var logReturns: [Double] = []
        for i in 1..<closes.count where closes[i - 1] > 0 && closes[i] > 0 {
            logReturns.append(log(closes[i] / closes[i - 1]))
        }
        guard logReturns.count >= 2 else { return nil }
        let mean = logReturns.reduce(0, +) / Double(logReturns.count)
        let variance = logReturns.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(logReturns.count - 1)
        let annualized = variance.squareRoot() * (252.0).squareRoot()
        return annualized * 100
    }

    /// Full-length EMA: one value per input bar, seeded with the first value.
    /// Used by `macd` so the fast and slow lines stay index-aligned.
    private static func fullEMA(_ values: [Double], period: Int) -> [Double] {
        guard let first = values.first, period > 0 else { return [] }
        let multiplier = 2.0 / (Double(period) + 1.0)
        var result: [Double] = [first]
        var previous = first
        for index in 1..<values.count {
            previous = (values[index] - previous) * multiplier + previous
            result.append(previous)
        }
        return result
    }
}
