import Foundation
import Observation

@Observable
final class AppEnvironment {
    let stockService: StockDataService
    let scanEngine: SuggestionEngine
    let persistence: PersistenceService
    let settings: SettingsModel
    let journal: TradeJournalModel
    let learn: LearnModel

    /// Drives the sidebar selection. Held here so any screen can navigate
    /// (e.g. the Dashboard's "Manage" button jumps to the Watchlist screen).
    var selection: SidebarItem? = .dashboard

    init() {
        let stockService = StockDataService()
        let persistence = PersistenceService()
        self.stockService = stockService
        self.scanEngine = SuggestionEngine(service: stockService)
        self.persistence = persistence
        self.settings = SettingsModel(persistence: persistence)
        self.journal = TradeJournalModel(persistence: persistence)
        self.learn = LearnModel(persistence: persistence)
    }
}
