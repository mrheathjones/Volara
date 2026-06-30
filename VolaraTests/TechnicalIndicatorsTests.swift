import Testing
import Foundation
@testable import Volara

struct TechnicalIndicatorsTests {
    @Test func smaComputesTrailingMean() {
        #expect(TechnicalIndicators.sma([1, 2, 3, 4, 5], period: 5) == 3)
        #expect(TechnicalIndicators.sma([2, 4, 6], period: 2) == 5) // last two: (4+6)/2
        #expect(TechnicalIndicators.sma([1, 2], period: 5) == nil)  // insufficient data
    }

    @Test func emaOfConstantSeriesIsThatConstant() {
        let e = TechnicalIndicators.ema([5, 5, 5, 5, 5, 5], period: 3)
        #expect(e != nil)
        #expect(abs((e ?? 0) - 5) < 1e-9)
    }

    @Test func rsiAllGainsIs100() {
        let closes = (1...20).map(Double.init)
        let r = TechnicalIndicators.rsi(closes)
        #expect(r != nil)
        #expect(abs((r ?? 0) - 100) < 1e-6)
    }

    @Test func rsiAllLossesIs0() {
        let closes = (1...20).reversed().map(Double.init)
        let r = TechnicalIndicators.rsi(closes)
        #expect(r != nil)
        #expect((r ?? 100) < 1e-6)
    }

    @Test func rsiInsufficientDataIsNil() {
        #expect(TechnicalIndicators.rsi([1, 2, 3], period: 14) == nil)
    }

    @Test func bollingerOfConstantSeriesHasZeroWidth() {
        let b = TechnicalIndicators.bollingerBands(Array(repeating: 50.0, count: 20))
        #expect(b != nil)
        if let b {
            #expect(abs(b.upper - b.lower) < 1e-9)
            #expect(abs(b.width) < 1e-9)
            #expect(abs(b.middle - 50) < 1e-9)
        }
    }

    @Test func atrComputesWilderAverageTrueRange() {
        let highs = [10.0, 11, 12]
        let lows = [9.0, 10, 11]
        let closes = [9.5, 10.5, 11.5]
        let a = TechnicalIndicators.atr(highs: highs, lows: lows, closes: closes, period: 2)
        #expect(a != nil)
        #expect(abs((a ?? 0) - 1.5) < 1e-9)
    }

    @Test func atrMismatchedInputLengthsIsNil() {
        #expect(TechnicalIndicators.atr(highs: [1, 2], lows: [1], closes: [1, 2], period: 1) == nil)
    }
}
