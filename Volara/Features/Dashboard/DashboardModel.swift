import Foundation
import Observation

@Observable
final class DashboardModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    /// Analyses for the user's watchlist symbols, in watchlist order.
    private(set) var watchlistCards: [TickerAnalysis] = []
    /// Ranked actionable opportunities from the broad market scan.
    private(set) var suggestions: [Suggestion] = []
    private(set) var loadState: LoadState = .idle
    private(set) var isRefreshing = false
    private(set) var lastUpdated: Date?

    var hasData: Bool { !watchlistCards.isEmpty || !suggestions.isEmpty }

    var isLoading: Bool {
        if case .loading = loadState { return true }
        return false
    }

    var failureMessage: String? {
        if case .failed(let message) = loadState { return message }
        return nil
    }

    /// Scans the union of the market universe and the watchlist in a single pass, then
    /// derives both dashboard sections from the result (avoids fetching shared tickers twice).
    func refresh(engine: SuggestionEngine, watchlist: [String], suggestionLimit: Int = 6) async {
        isRefreshing = true
        defer { isRefreshing = false }

        if !hasData { loadState = .loading }

        let normalizedWatchlist = watchlist.map { $0.uppercased() }
        let universe = TickerCatalog.marketUniverse + normalizedWatchlist
        let analyses = await engine.analyzeAll(symbols: universe)

        watchlistCards = normalizedWatchlist.compactMap { analyses[$0] }
        suggestions = engine.rankedSuggestions(from: Array(analyses.values), limit: suggestionLimit)
        lastUpdated = Date()

        if analyses.isEmpty {
            loadState = .failed("Couldn't load market data. Check your connection and try again.")
        } else {
            loadState = .loaded
        }
    }
}
