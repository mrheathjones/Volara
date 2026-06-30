import Foundation

nonisolated enum GreeksCalculator {
    static func normalCDF(_ x: Double) -> Double {
        // Abramowitz & Stegun 7.1.26 rational approximation via Horner's method.
        let l = abs(x)
        let k = 1.0 / (1.0 + 0.2316419 * l)
        let a1 = 0.319381530
        let a2 = -0.356563782
        let a3 = 1.781477937
        let a4 = -1.821255978
        let a5 = 1.330274429
        let poly = ((((a5 * k + a4) * k + a3) * k + a2) * k + a1) * k
        let w = 1.0 - normalPDF(l) * poly
        return x < 0 ? 1.0 - w : w
    }

    static func normalPDF(_ x: Double) -> Double {
        (1.0 / (2.0 * Double.pi).squareRoot()) * exp(-0.5 * x * x)
    }

    static func calculate(
        stockPrice: Double,
        strike: Double,
        daysToExpiration: Double,
        volatility: Double,
        riskFreeRate: Double,
        optionType: OptionType
    ) -> GreeksResult {
        let t = daysToExpiration / 365.0

        // Guard degenerate inputs.
        guard t > 0, volatility > 0, stockPrice > 0, strike > 0 else {
            let intrinsic: Double
            switch optionType {
            case .call: intrinsic = max(stockPrice - strike, 0)
            case .put: intrinsic = max(strike - stockPrice, 0)
            }
            let be = optionType == .call ? strike + intrinsic : strike - intrinsic
            let delta: Double
            switch optionType {
            case .call: delta = stockPrice > strike ? 1 : 0
            case .put: delta = stockPrice < strike ? -1 : 0
            }
            return GreeksResult(
                price: intrinsic,
                delta: delta,
                gamma: 0,
                theta: 0,
                vega: 0,
                breakeven: be
            )
        }

        let sqrtT = t.squareRoot()
        let d1 = (log(stockPrice / strike) + (riskFreeRate + 0.5 * volatility * volatility) * t) / (volatility * sqrtT)
        let d2 = d1 - volatility * sqrtT

        let nd1 = normalCDF(d1)
        let nd2 = normalCDF(d2)
        let pdfD1 = normalPDF(d1)
        let discount = exp(-riskFreeRate * t)

        let price: Double
        let delta: Double
        let theta: Double
        let breakevenResult: Double

        let gamma = pdfD1 / (stockPrice * volatility * sqrtT)
        let vega = stockPrice * pdfD1 * sqrtT / 100.0

        switch optionType {
        case .call:
            price = stockPrice * nd1 - strike * discount * nd2
            delta = nd1
            let thetaAnnual = -(stockPrice * pdfD1 * volatility) / (2 * sqrtT)
                - riskFreeRate * strike * discount * nd2
            theta = thetaAnnual / 365.0
            breakevenResult = strike + price
        case .put:
            price = strike * discount * normalCDF(-d2) - stockPrice * normalCDF(-d1)
            delta = nd1 - 1.0
            let thetaAnnual = -(stockPrice * pdfD1 * volatility) / (2 * sqrtT)
                + riskFreeRate * strike * discount * normalCDF(-d2)
            theta = thetaAnnual / 365.0
            breakevenResult = strike - price
        }

        return GreeksResult(
            price: price,
            delta: delta,
            gamma: gamma,
            theta: theta,
            vega: vega,
            breakeven: breakevenResult
        )
    }
}
