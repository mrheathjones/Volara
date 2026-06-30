import Testing
import Foundation
@testable import Volara

struct GreeksCalculatorTests {
    @Test func normalCDFKnownValues() {
        #expect(abs(GreeksCalculator.normalCDF(0) - 0.5) < 1e-6)
        #expect(abs(GreeksCalculator.normalCDF(1.96) - 0.9750) < 1e-3)
        #expect(abs(GreeksCalculator.normalCDF(-1.96) - 0.0250) < 1e-3)
    }

    // Textbook Black–Scholes: S=K=100, T=1yr, r=5%, sigma=20% -> call ~ 10.4506.
    @Test func atTheMoneyCallMatchesTextbook() {
        let r = GreeksCalculator.calculate(
            stockPrice: 100, strike: 100, daysToExpiration: 365,
            volatility: 0.20, riskFreeRate: 0.05, optionType: .call
        )
        #expect(abs(r.price - 10.4506) < 0.02)
        #expect(abs(r.delta - 0.6368) < 0.005)
        #expect(abs(r.breakeven - (100 + r.price)) < 1e-9)
        #expect(r.gamma > 0)
        #expect(r.vega > 0)
        #expect(r.theta < 0) // a long option loses value to time decay
    }

    // Same parameters -> put ~ 5.5735, delta ~ -0.3632.
    @Test func atTheMoneyPutMatchesTextbook() {
        let r = GreeksCalculator.calculate(
            stockPrice: 100, strike: 100, daysToExpiration: 365,
            volatility: 0.20, riskFreeRate: 0.05, optionType: .put
        )
        #expect(abs(r.price - 5.5735) < 0.02)
        #expect(abs(r.delta - (-0.3632)) < 0.005)
        #expect(abs(r.breakeven - (100 - r.price)) < 1e-9)
    }

    // Put–call parity: C - P = S - K e^{-rT}.
    @Test func putCallParityHolds() {
        let s = 120.0, k = 110.0, days = 200.0, vol = 0.30, rate = 0.04
        let c = GreeksCalculator.calculate(stockPrice: s, strike: k, daysToExpiration: days, volatility: vol, riskFreeRate: rate, optionType: .call)
        let p = GreeksCalculator.calculate(stockPrice: s, strike: k, daysToExpiration: days, volatility: vol, riskFreeRate: rate, optionType: .put)
        let t = days / 365.0
        #expect(abs((c.price - p.price) - (s - k * exp(-rate * t))) < 0.01)
    }

    @Test func degenerateInputsReturnIntrinsic() {
        let r = GreeksCalculator.calculate(
            stockPrice: 100, strike: 90, daysToExpiration: 0,
            volatility: 0.2, riskFreeRate: 0.05, optionType: .call
        )
        #expect(abs(r.price - 10) < 1e-9) // intrinsic = max(100 - 90, 0)
    }
}
