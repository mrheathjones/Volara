import Foundation
import Observation

@Observable
final class TradeJournalModel {
    private let persistence: PersistenceService
    private(set) var entries: [TradeEntry]

    init(persistence: PersistenceService) {
        self.persistence = persistence
        self.entries = persistence.loadJournal().sorted { $0.date > $1.date }
    }

    var openTrades: [TradeEntry] { entries.filter { $0.isOpen } }

    var closedTrades: [TradeEntry] { entries.filter { !$0.isOpen } }

    var totalTrades: Int { entries.count }

    var winRate: Double {
        let closed = closedTrades
        guard !closed.isEmpty else { return 0 }
        let wins = closed.filter { ($0.profitLoss ?? 0) > 0 }.count
        return Double(wins) / Double(closed.count) * 100
    }

    var averagePLPct: Double {
        let pcts = closedTrades.compactMap { $0.profitLossPct }
        guard !pcts.isEmpty else { return 0 }
        return pcts.reduce(0, +) / Double(pcts.count)
    }

    var totalPL: Double {
        closedTrades.reduce(0) { $0 + ($1.profitLoss ?? 0) }
    }

    func add(_ entry: TradeEntry) {
        entries.append(entry)
        sortAndPersist()
    }

    func update(_ entry: TradeEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        sortAndPersist()
    }

    func delete(_ entry: TradeEntry) {
        entries.removeAll { $0.id == entry.id }
        sortAndPersist()
    }

    private func sortAndPersist() {
        entries.sort { $0.date > $1.date }
        persistence.saveJournal(entries)
    }
}
