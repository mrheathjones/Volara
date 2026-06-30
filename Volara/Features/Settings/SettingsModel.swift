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

    init(persistence: PersistenceService) {
        self.persistence = persistence
        self.watchlistText = persistence.watchlist.joined(separator: ", ")
        self.defaultContracts = persistence.defaultContracts
        self.riskPerTradePct = persistence.riskPerTradePct
        self.accountSize = persistence.accountSize
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
}
