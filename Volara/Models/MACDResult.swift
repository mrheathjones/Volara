import Foundation

/// Moving Average Convergence Divergence snapshot for the most recent bar.
nonisolated struct MACDResult: Sendable {
    let macd: Double       // fast EMA - slow EMA
    let signal: Double     // EMA of the MACD line
    let histogram: Double  // macd - signal
    let histogramRising: Bool // histogram greater than the prior bar's

    static let zero = MACDResult(macd: 0, signal: 0, histogram: 0, histogramRising: false)
}
