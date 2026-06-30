import Foundation
import Observation

@Observable
final class SignalScannerModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var rows: [ScannerRow] = []
    private(set) var loadState: LoadState = .idle

    var filter: SignalFilter = .all
    var sort: SortOption = .signal
    var selectedRow: ScannerRow?

    func scan(using service: StockDataService, symbols: [String]) async {
        loadState = .loading

        let results = await withTaskGroup(of: ScannerRow?.self) { group in
            for symbol in symbols {
                let companyName = TickerCatalog.companyName(for: symbol)
                group.addTask {
                    do {
                        let analysis = try await service.analyze(symbol: symbol, companyName: companyName)
                        let scan = SignalEvaluator.scannerSignal(for: analysis)
                        return ScannerRow(analysis: analysis, scan: scan)
                    } catch {
                        return nil
                    }
                }
            }

            var collected: [ScannerRow] = []
            for await row in group {
                if let row { collected.append(row) }
            }
            return collected
        }

        rows = results

        if results.isEmpty {
            loadState = .failed("Could not load signals. Check your connection and try again.")
        } else {
            loadState = .loaded
        }
    }

    var displayedRows: [ScannerRow] {
        let filtered = rows.filter { filter.matches($0.scan.signal) }
        switch sort {
        case .signal:
            return filtered.sorted { lhs, rhs in
                let lRank = signalRank(lhs.scan.signal)
                let rRank = signalRank(rhs.scan.signal)
                if lRank != rRank { return lRank < rRank }
                return lhs.analysis.rsi < rhs.analysis.rsi
            }
        case .rsi:
            return filtered.sorted { $0.analysis.rsi < $1.analysis.rsi }
        case .ticker:
            return filtered.sorted { $0.analysis.symbol < $1.analysis.symbol }
        }
    }

    private func signalRank(_ signal: SignalType) -> Int {
        switch signal {
        case .call: return 0
        case .put: return 1
        case .squeeze: return 2
        case .neutral: return 3
        }
    }
}
