import Testing
@testable import Volara

struct SuggestionEngineTests {
    private func analysis(
        symbol: String = "TEST",
        rsi: Double,
        price: Double,
        emaFast: Double,
        emaSlow: Double,
        volumeRatio: Double,
        lower: Double,
        upper: Double,
        bbWidth: Double = 8,
        lowestBBWidth: Double = 2
    ) -> TickerAnalysis {
        TickerAnalysis(
            symbol: symbol,
            companyName: symbol,
            price: price,
            previousClose: price,
            sparkline: [],
            rsi: rsi,
            sma20: price,
            ema9: emaFast,
            ema21: emaSlow,
            bollinger: BollingerBands(middle: (upper + lower) / 2, upper: upper, lower: lower, width: bbWidth),
            bbWidthPct: bbWidth,
            lowestBBWidth20: lowestBBWidth,
            atr: 1,
            volume: volumeRatio * 100,
            avgVolume: 100
        )
    }

    private var callSetup: TickerAnalysis {
        analysis(rsi: 25, price: 100, emaFast: 11, emaSlow: 10, volumeRatio: 2, lower: 100, upper: 110)
    }
    private var putSetup: TickerAnalysis {
        analysis(symbol: "PUTX", rsi: 75, price: 110, emaFast: 10, emaSlow: 11, volumeRatio: 2, lower: 100, upper: 110)
    }
    private var squeezeSetup: TickerAnalysis {
        analysis(symbol: "SQZ", rsi: 50, price: 105, emaFast: 10, emaSlow: 10, volumeRatio: 1, lower: 100, upper: 110, bbWidth: 1, lowestBBWidth: 2)
    }
    private var neutralSetup: TickerAnalysis {
        analysis(symbol: "NEU", rsi: 50, price: 105, emaFast: 10, emaSlow: 10, volumeRatio: 1, lower: 100, upper: 110, bbWidth: 10, lowestBBWidth: 2)
    }

    @Test func detectsEachSignalType() {
        #expect(SignalEvaluator.scannerSignal(for: callSetup).signal == .call)
        #expect(SignalEvaluator.scannerSignal(for: putSetup).signal == .put)
        #expect(SignalEvaluator.scannerSignal(for: squeezeSetup).signal == .squeeze)
        #expect(SignalEvaluator.scannerSignal(for: neutralSetup).signal == .neutral)
    }

    @Test func callOutranksSqueeze() {
        let call = callSetup
        let squeeze = squeezeSetup
        let callScore = SuggestionEngine.score(call, SignalEvaluator.scannerSignal(for: call))
        let squeezeScore = SuggestionEngine.score(squeeze, SignalEvaluator.scannerSignal(for: squeeze))
        #expect(callScore > squeezeScore)
    }

    @Test func moreOversoldCallScoresHigher() {
        let deep = analysis(rsi: 20, price: 100, emaFast: 11, emaSlow: 10, volumeRatio: 2, lower: 100, upper: 110)
        let mild = analysis(rsi: 30, price: 100, emaFast: 11, emaSlow: 10, volumeRatio: 2, lower: 100, upper: 110)
        let deepScore = SuggestionEngine.score(deep, SignalEvaluator.scannerSignal(for: deep))
        let mildScore = SuggestionEngine.score(mild, SignalEvaluator.scannerSignal(for: mild))
        #expect(deepScore > mildScore)
    }

    @Test func rankingFiltersNeutralAndRespectsLimit() {
        let engine = SuggestionEngine(service: StockDataService())
        let ranked = engine.rankedSuggestions(
            from: [neutralSetup, squeezeSetup, callSetup, putSetup],
            limit: 2
        )
        #expect(ranked.count == 2)
        #expect(!ranked.contains { $0.scan.signal == .neutral })
        // CALL/PUT outrank SQUEEZE, so they fill the top two slots.
        #expect(ranked.allSatisfy { $0.scan.signal == .call || $0.scan.signal == .put })
        #expect(ranked.first!.score >= ranked.last!.score)
    }
}
