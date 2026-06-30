import Foundation

/// Scans a universe of tickers and ranks the actionable ones into suggestions.
///
/// Intentionally UI-agnostic and `nonisolated` so it can be driven by the Dashboard's
/// in-app timer today and, later, by a background scheduler (e.g. a menu-bar app using
/// `NSBackgroundActivityScheduler`) that posts notifications — without any UI dependency.
nonisolated final class SuggestionEngine: Sendable {
    private let service: StockDataService

    init(service: StockDataService) {
        self.service = service
    }

    /// Fetches and analyzes every symbol, returning a map keyed by uppercased symbol.
    /// Individual failures are skipped (the map simply omits them). Runs in bounded
    /// concurrency batches to stay friendly to the data provider's rate limits.
    func analyzeAll(symbols: [String], maxConcurrent: Int = 8) async -> [String: TickerAnalysis] {
        let unique = orderedUnique(symbols)
        var out: [String: TickerAnalysis] = [:]
        var index = 0
        while index < unique.count {
            let end = min(index + maxConcurrent, unique.count)
            let batch = Array(unique[index..<end])
            let analyzed = await withTaskGroup(of: TickerAnalysis?.self) { group in
                for symbol in batch {
                    group.addTask {
                        try? await self.service.analyze(
                            symbol: symbol,
                            companyName: TickerCatalog.companyName(for: symbol)
                        )
                    }
                }
                var collected: [TickerAnalysis] = []
                for await analysis in group {
                    if let analysis { collected.append(analysis) }
                }
                return collected
            }
            for analysis in analyzed {
                out[analysis.symbol.uppercased()] = analysis
            }
            index = end
        }
        return out
    }

    /// Ranks already-analyzed tickers into the top actionable suggestions.
    func rankedSuggestions(from analyses: [TickerAnalysis], limit: Int) -> [Suggestion] {
        let scored: [Suggestion] = analyses.compactMap { analysis in
            let scan = SignalEvaluator.scannerSignal(for: analysis)
            guard scan.signal != .neutral else { return nil }
            return Suggestion(analysis: analysis, scan: scan, score: Self.score(analysis, scan))
        }
        return Array(scored.sorted { $0.score > $1.score }.prefix(limit))
    }

    /// Convenience: analyze a universe and return its ranked suggestions in one call.
    func suggestions(in symbols: [String], limit: Int, maxConcurrent: Int = 8) async -> [Suggestion] {
        let analyses = await analyzeAll(symbols: symbols, maxConcurrent: maxConcurrent)
        return rankedSuggestions(from: Array(analyses.values), limit: limit)
    }

    /// Conviction score. CALL/PUT (all four conditions met) rank above SQUEEZE setups,
    /// and within a signal more extreme RSI / heavier volume scores higher.
    static func score(_ analysis: TickerAnalysis, _ scan: ScanSignal) -> Double {
        switch scan.signal {
        case .call:
            return 1000 + max(0, 35 - analysis.rsi) * 4 + min(analysis.volumeRatio, 5) * 10
        case .put:
            return 1000 + max(0, analysis.rsi - 65) * 4 + min(analysis.volumeRatio, 5) * 10
        case .squeeze:
            // Within the squeeze tier, rank by predictive breakout/breakdown confidence
            // first, with band tightness as a secondary tiebreak. CALL/PUT still outrank
            // every squeeze (base 1000 vs 500-650 here).
            let prediction = PredictiveSignalEvaluator.predict(for: analysis)
            let reference = analysis.lowestBBWidth20 * 1.05
            let tightness = reference > 0 ? max(0, 1 - analysis.bbWidthPct / reference) : 0
            return 500 + prediction.confidence + tightness * 50
        case .neutral:
            return 0
        }
    }

    private func orderedUnique(_ symbols: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for symbol in symbols {
            let upper = symbol.uppercased()
            if !upper.isEmpty, !seen.contains(upper) {
                seen.insert(upper)
                result.append(upper)
            }
        }
        return result
    }
}
