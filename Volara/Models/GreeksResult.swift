import Foundation

nonisolated struct GreeksResult: Sendable {
    let price: Double
    let delta: Double
    let gamma: Double
    let theta: Double
    let vega: Double
    let breakeven: Double
}
