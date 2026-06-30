import Foundation

nonisolated struct ScanSignal: Sendable {
    let signal: SignalType
    let triggeredConditions: [String]
    let strikeLow: Double
    let strikeHigh: Double
    let atrExplanation: String
    let expirationHint: String
}
