import Foundation

nonisolated struct PriceSeries: Sendable {
    let symbol: String
    let currentPrice: Double
    let previousClose: Double
    let timestamps: [Date]
    let closes: [Double]
    let highs: [Double]
    let lows: [Double]
    let volumes: [Double]
}
