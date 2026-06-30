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
}
