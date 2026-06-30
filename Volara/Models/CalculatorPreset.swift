import Foundation

/// A request to open the Options Calculator pre-filled for a specific ticker.
/// If `stockPrice` is nil the calculator fetches the latest price itself.
nonisolated struct CalculatorPreset: Sendable, Equatable {
    let ticker: String
    let optionType: OptionType
    let stockPrice: Double?
    let strike: Double?
    let volatilityPercent: Double?
}
