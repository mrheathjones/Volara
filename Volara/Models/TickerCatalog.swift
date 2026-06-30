import Foundation

nonisolated enum TickerCatalog {
    static let dashboardSymbols: [String] = ["SPY", "QQQ", "AAPL", "TSLA", "NVDA"]

    static let scannerSymbols: [String] = [
        "SPY", "QQQ", "AAPL", "TSLA", "NVDA", "AMZN", "MSFT", "META",
        "AMD", "GOOGL", "BA", "COIN", "PLTR", "SOFI", "MARA"
    ]

    static let companyNames: [String: String] = [
        "SPY": "SPDR S&P 500 ETF",
        "QQQ": "Invesco QQQ Trust",
        "AAPL": "Apple Inc.",
        "TSLA": "Tesla, Inc.",
        "NVDA": "NVIDIA Corporation",
        "AMZN": "Amazon.com, Inc.",
        "MSFT": "Microsoft Corporation",
        "META": "Meta Platforms, Inc.",
        "AMD": "Advanced Micro Devices, Inc.",
        "GOOGL": "Alphabet Inc.",
        "BA": "The Boeing Company",
        "COIN": "Coinbase Global, Inc.",
        "PLTR": "Palantir Technologies Inc.",
        "SOFI": "SoFi Technologies, Inc.",
        "MARA": "MARA Holdings, Inc."
    ]

    static func companyName(for symbol: String) -> String {
        companyNames[symbol.uppercased()] ?? symbol.uppercased()
    }
}
