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

    private(set) var analyses: [TickerAnalysis] = []
    private(set) var loadState: LoadState = .idle

    func refresh(using service: StockDataService) async {
        loadState = .loading

        let symbols = TickerCatalog.dashboardSymbols

        let results: [String: TickerAnalysis] = await withTaskGroup(
            of: (String, TickerAnalysis?).self
        ) { group in
            for symbol in symbols {
                group.addTask {
                    let analysis = try? await service.analyze(
                        symbol: symbol,
                        companyName: TickerCatalog.companyName(for: symbol)
                    )
                    return (symbol, analysis)
                }
            }

            var collected: [String: TickerAnalysis] = [:]
            for await (symbol, analysis) in group {
                if let analysis {
                    collected[symbol] = analysis
                }
            }
            return collected
        }

        // Preserve dashboardSymbols order, dropping failures.
        let ordered = symbols.compactMap { results[$0] }

        analyses = ordered

        if ordered.isEmpty {
            loadState = .failed("Couldn't load market data. Check your connection and try again.")
        } else {
            loadState = .loaded
        }
    }
}
