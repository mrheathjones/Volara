import Testing
import Foundation
@testable import Volara

@MainActor
struct SettingsModelTests {
    private func makeSettings() -> SettingsModel {
        // A throwaway UserDefaults suite so tests never touch the real app defaults.
        let suite = UserDefaults(suiteName: "volara.tests.\(UUID().uuidString)")!
        return SettingsModel(persistence: PersistenceService(defaults: suite))
    }

    @Test func addAndRemoveWatchlist() {
        let settings = makeSettings()
        settings.watchlistText = "AAPL, MSFT"
        #expect(settings.watchlist == ["AAPL", "MSFT"])

        settings.addToWatchlist("nvda")
        #expect(settings.isInWatchlist("NVDA"))
        #expect(settings.watchlist == ["AAPL", "MSFT", "NVDA"])

        settings.removeFromWatchlist("aapl")
        #expect(!settings.isInWatchlist("AAPL"))
        #expect(settings.watchlist == ["MSFT", "NVDA"])
    }

    @Test func addIsDedupedAndCaseInsensitive() {
        let settings = makeSettings()
        settings.watchlistText = "SPY"
        settings.addToWatchlist("SPY")
        settings.addToWatchlist("spy")
        #expect(settings.watchlist == ["SPY"])
    }

    @Test func toggleAddsThenRemoves() {
        let settings = makeSettings()
        settings.watchlistText = ""
        settings.toggleWatchlist("QQQ")
        #expect(settings.isInWatchlist("QQQ"))
        settings.toggleWatchlist("QQQ")
        #expect(!settings.isInWatchlist("QQQ"))
    }

    @Test func maxPositionSizeMath() {
        let settings = makeSettings()
        settings.accountSize = 10000
        settings.riskPerTradePct = 2 // budget = $200
        #expect(settings.maxPositionSize(premium: 2.0) == 1) // 200 / (2 * 100)
        #expect(settings.maxPositionSize(premium: 0) == 0)    // guards divide-by-zero
    }
}
