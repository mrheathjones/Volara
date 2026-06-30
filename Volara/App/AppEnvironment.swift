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

    /// Set when another screen asks to open a ticker in the calculator; the
    /// calculator consumes and clears it on appear.
    var pendingCalculatorPreset: CalculatorPreset?

    /// Navigate to the Options Calculator pre-filled for a ticker. Pass a known
    /// `stockPrice` for an instant fill; omit it to have the calculator fetch live.
    func openInCalculator(
        ticker: String,
        optionType: OptionType,
        stockPrice: Double? = nil,
        strike: Double? = nil,
        volatilityPercent: Double? = nil
    ) {
        pendingCalculatorPreset = CalculatorPreset(
            ticker: ticker.uppercased(),
            optionType: optionType,
            stockPrice: stockPrice,
            strike: strike,
            volatilityPercent: volatilityPercent
        )
        selection = .calculator
    }

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
