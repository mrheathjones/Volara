import Foundation
import Observation

@Observable
final class AppEnvironment {
    let stockService: StockDataService
    let persistence: PersistenceService
    let settings: SettingsModel
    let journal: TradeJournalModel
    let learn: LearnModel

    init() {
        let stockService = StockDataService()
        let persistence = PersistenceService()
        self.stockService = stockService
        self.persistence = persistence
        self.settings = SettingsModel(persistence: persistence)
        self.journal = TradeJournalModel(persistence: persistence)
        self.learn = LearnModel(persistence: persistence)
    }
}
