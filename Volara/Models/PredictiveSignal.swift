import Foundation

/// A heuristic directional-bias read for a ticker — combines trend, momentum (MACD),
/// RSI, Bollinger position, and price-vs-average into a breakout/breakdown lean with a
/// confidence score. It is a bias indicator, not a guarantee.
nonisolated struct PredictiveSignal: Sendable {
    let direction: BreakoutDirection
    let confidence: Double   // 0...100
    let rationale: [String]

    var confidenceLabel: String { "\(Int(confidence.rounded()))%" }
}
