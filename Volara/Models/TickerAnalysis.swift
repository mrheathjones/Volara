import Foundation

nonisolated struct TickerAnalysis: Identifiable, Sendable {
    let symbol: String
    let companyName: String
    let price: Double
    let previousClose: Double
    let sparkline: [Double]
    let rsi: Double
    let sma20: Double
    let ema9: Double
    let ema21: Double
    let bollinger: BollingerBands
    let bbWidthPct: Double
    let lowestBBWidth20: Double
    let atr: Double
    let volume: Double
    let avgVolume: Double

    var id: String { symbol }

    var changeAmount: Double { price - previousClose }

    var changePct: Double {
        guard previousClose != 0 else { return 0 }
        return (price - previousClose) / previousClose * 100
    }

    var volumeRatio: Double {
        guard avgVolume != 0 else { return 0 }
        return volume / avgVolume
    }

    var isHighVolume: Bool { volumeRatio > 1.5 }
}
