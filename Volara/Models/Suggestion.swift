import Foundation

/// A ranked, actionable opportunity surfaced by the market scan — a ticker whose
/// indicators currently fire a CALL, PUT, or SQUEEZE signal.
nonisolated struct Suggestion: Identifiable, Sendable {
    let analysis: TickerAnalysis
    let scan: ScanSignal
    /// Higher score = stronger conviction. See `SuggestionEngine.score(_:_:)`.
    let score: Double

    var id: String { analysis.symbol }

    /// Adapter so suggestions can reuse the Scanner's detail sheet.
    var scannerRow: ScannerRow {
        ScannerRow(analysis: analysis, scan: scan)
    }
}
