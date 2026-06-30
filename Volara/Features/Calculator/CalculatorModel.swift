import Foundation
import Observation

@Observable
final class CalculatorModel {
    var ticker: String = ""
    var isLoadingTicker = false
    var stockPrice: Double = 150
    var strike: Double = 155
    var days: Double = 30
    var ivPercent: Double = 25
    var riskFreePercent: Double = 5.3
    var optionType: OptionType = .call
    var scenarioPct: Double = 0

    var result: GreeksResult {
        GreeksCalculator.calculate(
            stockPrice: stockPrice,
            strike: strike,
            daysToExpiration: days,
            volatility: ivPercent / 100,
            riskFreeRate: riskFreePercent / 100,
            optionType: optionType
        )
    }

    var breakeven: Double {
        result.breakeven
    }

    var scenarioStockPrice: Double {
        stockPrice * (1 + scenarioPct / 100)
    }

    var scenarioOptionValue: Double {
        switch optionType {
        case .call: return max(scenarioStockPrice - strike, 0)
        case .put: return max(strike - scenarioStockPrice, 0)
        }
    }

    // MARK: - Ticker pre-fill

    /// Apply a known price, defaulting the strike to an at-the-money round number and
    /// optionally seeding implied volatility (clamped to a sane range).
    func applyPrice(_ price: Double, strike: Double? = nil, volatilityPercent: Double? = nil) {
        stockPrice = price
        self.strike = strike ?? Self.atmStrike(for: price)
        if let volatilityPercent, (5...300).contains(volatilityPercent) {
            ivPercent = (volatilityPercent * 10).rounded() / 10
        }
    }

    /// Fetch the latest price (and a realized-volatility estimate) for a ticker.
    func loadTicker(_ symbol: String, service: StockDataService) async {
        isLoadingTicker = true
        defer { isLoadingTicker = false }
        do {
            let series = try await service.fetch(symbol: symbol)
            let hv = TechnicalIndicators.historicalVolatilityPercent(series.closes)
            applyPrice(series.currentPrice, volatilityPercent: hv)
        } catch {
            // Keep existing inputs; the calculator stays usable without live data.
        }
    }

    static func atmStrike(for price: Double) -> Double {
        guard price > 0 else { return price }
        let increment: Double = price < 25 ? 0.5 : (price < 200 ? 1 : 5)
        return (price / increment).rounded() * increment
    }
}
