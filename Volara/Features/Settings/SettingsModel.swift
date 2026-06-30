import Foundation
import Observation

@Observable
final class SettingsModel {
    private let persistence: PersistenceService

    var watchlistText: String {
        didSet { persistence.watchlist = watchlist }
    }

    var defaultContracts: Int {
        didSet { persistence.defaultContracts = defaultContracts }
    }

    var riskPerTradePct: Double {
        didSet { persistence.riskPerTradePct = riskPerTradePct }
    }

    var accountSize: Double {
        didSet { persistence.accountSize = accountSize }
    }

    var autoRefreshEnabled: Bool {
        didSet { persistence.autoRefreshEnabled = autoRefreshEnabled }
    }

    var autoRefreshMinutes: Int {
        didSet { persistence.autoRefreshMinutes = autoRefreshMinutes }
    }

    init(persistence: PersistenceService) {
        self.persistence = persistence
        self.watchlistText = persistence.watchlist.joined(separator: ", ")
        self.defaultContracts = persistence.defaultContracts
        self.riskPerTradePct = persistence.riskPerTradePct
        self.accountSize = persistence.accountSize
        self.autoRefreshEnabled = persistence.autoRefreshEnabled
        self.autoRefreshMinutes = persistence.autoRefreshMinutes
    }

    var watchlist: [String] {
        let separators = CharacterSet(charactersIn: ", \n\t")
        let tokens = watchlistText
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespaces).uppercased() }
            .filter { !$0.isEmpty }
        var seen = Set<String>()
        var result: [String] = []
        for token in tokens where !seen.contains(token) {
            seen.insert(token)
            result.append(token)
        }
        return result
    }

    func maxPositionSize(premium: Double) -> Int {
        guard premium > 0 else { return 0 }
        let budget = accountSize * riskPerTradePct / 100.0
        return Int((budget / (premium * 100)).rounded(.down))
    }

    // MARK: - Watchlist editing

    func isInWatchlist(_ symbol: String) -> Bool {
        watchlist.contains(normalize(symbol))
    }

    func addToWatchlist(_ symbol: String) {
        let sym = normalize(symbol)
        guard !sym.isEmpty, !watchlist.contains(sym) else { return }
        // Setting watchlistText triggers its didSet, which persists the parsed list.
        watchlistText = (watchlist + [sym]).joined(separator: ", ")
    }

    func removeFromWatchlist(_ symbol: String) {
        let sym = normalize(symbol)
        watchlistText = watchlist.filter { $0 != sym }.joined(separator: ", ")
    }

    func toggleWatchlist(_ symbol: String) {
        if isInWatchlist(symbol) {
            removeFromWatchlist(symbol)
        } else {
            addToWatchlist(symbol)
        }
    }

    private func normalize(_ symbol: String) -> String {
        symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }
}
