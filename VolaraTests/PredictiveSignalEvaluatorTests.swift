import Testing
@testable import Volara

struct PredictiveSignalEvaluatorTests {
    private func analysis(
        rsi: Double,
        price: Double,
        ema9: Double,
        ema21: Double,
        sma20: Double,
        lower: Double,
        upper: Double,
        macd: MACDResult
    ) -> TickerAnalysis {
        TickerAnalysis(
            symbol: "T",
            companyName: "T",
            price: price,
            previousClose: price,
            sparkline: [],
            rsi: rsi,
            sma20: sma20,
            ema9: ema9,
            ema21: ema21,
            bollinger: BollingerBands(middle: (upper + lower) / 2, upper: upper, lower: lower, width: 5),
            bbWidthPct: 5,
            lowestBBWidth20: 2,
            atr: 1,
            volume: 100,
            avgVolume: 100,
            macd: macd
        )
    }

    @Test func bullishConfluencePredictsBreakout() {
        let setup = analysis(
            rsi: 65, price: 109, ema9: 11, ema21: 10, sma20: 100, lower: 100, upper: 110,
            macd: MACDResult(macd: 1, signal: 0.5, histogram: 0.5, histogramRising: true)
        )
        let prediction = PredictiveSignalEvaluator.predict(for: setup)
        #expect(prediction.direction == .breakout)
        #expect(prediction.direction.suggestedOption == .call)
        #expect(prediction.confidence > 50)
    }

    @Test func bearishConfluencePredictsBreakdown() {
        let setup = analysis(
            rsi: 35, price: 101, ema9: 10, ema21: 11, sma20: 110, lower: 100, upper: 110,
            macd: MACDResult(macd: -1, signal: -0.5, histogram: -0.5, histogramRising: false)
        )
        let prediction = PredictiveSignalEvaluator.predict(for: setup)
        #expect(prediction.direction == .breakdown)
        #expect(prediction.direction.suggestedOption == .put)
        #expect(prediction.confidence > 50)
    }

    @Test func balancedSignalsAreNeutral() {
        // Trend up (+1.5) offset by price below its 20-day average (-1.0); flat elsewhere.
        let setup = analysis(
            rsi: 50, price: 105, ema9: 11, ema21: 10, sma20: 106, lower: 100, upper: 110,
            macd: MACDResult(macd: 0, signal: 0, histogram: 0, histogramRising: false)
        )
        let prediction = PredictiveSignalEvaluator.predict(for: setup)
        #expect(prediction.direction == .neutral)
    }
}
