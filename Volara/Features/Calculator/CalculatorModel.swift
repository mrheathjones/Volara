import Foundation
import Observation

@Observable
final class CalculatorModel {
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
}
