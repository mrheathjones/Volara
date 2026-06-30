import Foundation

nonisolated enum StockDataError: Error, LocalizedError, Sendable {
    case badResponse(Int)
    case emptyData
    case malformedData

    var errorDescription: String? {
        switch self {
        case .badResponse(let code): return "The data provider returned HTTP \(code)."
        case .emptyData: return "No price data was returned for this symbol."
        case .malformedData: return "The price data could not be read."
        }
    }
}

nonisolated final class StockDataService: Sendable {
    init() {}

    func fetch(symbol: String, range: String = "3mo", interval: String = "1d") async throws -> PriceSeries {
        let upper = symbol.uppercased()
        let encoded = upper.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? upper
        guard let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(encoded)?interval=\(interval)&range=\(range)") else {
            throw StockDataError.malformedData
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw StockDataError.badResponse(http.statusCode)
        }

        let decoder = JSONDecoder()
        let root: YahooChartResponse
        do {
            root = try decoder.decode(YahooChartResponse.self, from: data)
        } catch {
            throw StockDataError.malformedData
        }

        guard let result = root.chart.result?.first else {
            throw StockDataError.emptyData
        }

        let meta = result.meta
        let timestamps = result.timestamp ?? []
        guard let quote = result.indicators.quote.first else {
            throw StockDataError.emptyData
        }

        let rawCloses = quote.close ?? []
        let rawHighs = quote.high ?? []
        let rawLows = quote.low ?? []
        let rawVolumes = quote.volume ?? []

        var dates: [Date] = []
        var closes: [Double] = []
        var highs: [Double] = []
        var lows: [Double] = []
        var volumes: [Double] = []

        let count = min(timestamps.count, rawCloses.count)
        for i in 0..<count {
            guard let close = rawCloses[i] else { continue }
            let high = (i < rawHighs.count ? rawHighs[i] : nil) ?? close
            let low = (i < rawLows.count ? rawLows[i] : nil) ?? close
            let volume = (i < rawVolumes.count ? rawVolumes[i] : nil) ?? 0
            dates.append(Date(timeIntervalSince1970: TimeInterval(timestamps[i])))
            closes.append(close)
            highs.append(high)
            lows.append(low)
            volumes.append(Double(volume))
        }

        guard !closes.isEmpty else {
            throw StockDataError.emptyData
        }

        let currentPrice = meta.regularMarketPrice ?? closes.last ?? 0
        // For a 1-day change we want the prior trading session's close. Prefer the
        // meta previousClose (yesterday), then the second-to-last close in the series.
        // chartPreviousClose is the close before the whole range began (~3 months ago),
        // so it is only a last-resort fallback.
        let previousClose = meta.previousClose
            ?? (closes.count >= 2 ? closes[closes.count - 2] : nil)
            ?? meta.chartPreviousClose
            ?? currentPrice

        return PriceSeries(
            symbol: upper,
            currentPrice: currentPrice,
            previousClose: previousClose,
            timestamps: dates,
            closes: closes,
            highs: highs,
            lows: lows,
            volumes: volumes
        )
    }

    func analyze(symbol: String, companyName: String) async throws -> TickerAnalysis {
        let series = try await fetch(symbol: symbol)
        let closes = series.closes

        let rsi = TechnicalIndicators.rsi(closes) ?? 50
        let sma20 = TechnicalIndicators.sma(closes, period: 20) ?? series.currentPrice
        let ema9 = TechnicalIndicators.ema(closes, period: 9) ?? series.currentPrice
        let ema21 = TechnicalIndicators.ema(closes, period: 21) ?? series.currentPrice
        let bollinger = TechnicalIndicators.bollingerBands(closes)
            ?? BollingerBands(middle: series.currentPrice, upper: series.currentPrice, lower: series.currentPrice, width: 0)
        let bbWidthPct = bollinger.width
        let widthSeries = TechnicalIndicators.bbWidthSeries(closes)
        let lowestBBWidth20 = widthSeries.suffix(20).min() ?? bbWidthPct
        let atr = TechnicalIndicators.atr(highs: series.highs, lows: series.lows, closes: closes) ?? 0
        let macd = TechnicalIndicators.macd(closes) ?? .zero

        let volume = series.volumes.last ?? 0
        let avgWindow = series.volumes.suffix(20)
        let avgVolume = avgWindow.isEmpty ? 0 : avgWindow.reduce(0, +) / Double(avgWindow.count)

        let sparkline = Array(closes.suffix(30))

        return TickerAnalysis(
            symbol: series.symbol,
            companyName: companyName,
            price: series.currentPrice,
            previousClose: series.previousClose,
            sparkline: sparkline,
            rsi: rsi,
            sma20: sma20,
            ema9: ema9,
            ema21: ema21,
            bollinger: bollinger,
            bbWidthPct: bbWidthPct,
            lowestBBWidth20: lowestBBWidth20,
            atr: atr,
            volume: volume,
            avgVolume: avgVolume,
            macd: macd
        )
    }
}

// MARK: - Private decoding helpers

private nonisolated struct YahooChartResponse: Decodable {
    let chart: Chart

    nonisolated struct Chart: Decodable {
        let result: [ChartResult]?
        let error: ChartError?
    }

    nonisolated struct ChartError: Decodable {
        let code: String?
        let description: String?
    }

    nonisolated struct ChartResult: Decodable {
        let meta: Meta
        let timestamp: [Int]?
        let indicators: Indicators
    }

    nonisolated struct Meta: Decodable {
        let regularMarketPrice: Double?
        let chartPreviousClose: Double?
        let previousClose: Double?
    }

    nonisolated struct Indicators: Decodable {
        let quote: [Quote]
    }

    nonisolated struct Quote: Decodable {
        let close: [Double?]?
        let high: [Double?]?
        let low: [Double?]?
        let volume: [Int?]?
    }
}
