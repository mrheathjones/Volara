import Testing
@testable import Volara

struct MACDTests {
    @Test func macdIsPositiveForRisingSeries() {
        let closes = (1...60).map(Double.init)
        let macd = TechnicalIndicators.macd(closes)
        #expect(macd != nil)
        #expect((macd?.macd ?? 0) > 0)
        #expect((macd?.histogram ?? 0) > 0)
    }

    @Test func macdIsNegativeForFallingSeries() {
        let closes = (1...60).reversed().map(Double.init)
        let macd = TechnicalIndicators.macd(closes)
        #expect(macd != nil)
        #expect((macd?.macd ?? 0) < 0)
    }

    @Test func macdIsNilForShortSeries() {
        #expect(TechnicalIndicators.macd([1, 2, 3, 4, 5]) == nil)
    }

    @Test func historicalVolatilityIsZeroForFlatSeries() {
        let hv = TechnicalIndicators.historicalVolatilityPercent(Array(repeating: 100.0, count: 30))
        #expect(hv != nil)
        #expect(abs(hv ?? -1) < 1e-9)
    }

    @Test func historicalVolatilityIsPositiveForVaryingSeries() {
        let closes = (0..<40).map { 100 + (($0 % 2 == 0) ? 2.0 : -2.0) }
        #expect((TechnicalIndicators.historicalVolatilityPercent(closes) ?? 0) > 0)
    }

    @Test func historicalVolatilityIsNilForShortSeries() {
        #expect(TechnicalIndicators.historicalVolatilityPercent([1, 2, 3]) == nil)
    }
}
