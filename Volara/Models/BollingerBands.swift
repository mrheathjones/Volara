import Foundation

nonisolated struct BollingerBands: Sendable {
    let middle: Double
    let upper: Double
    let lower: Double
    let width: Double
}
