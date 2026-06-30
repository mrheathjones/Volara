import Foundation

nonisolated struct ScannerRow: Identifiable, Sendable {
    let analysis: TickerAnalysis
    let scan: ScanSignal

    var id: String { analysis.symbol }
}
