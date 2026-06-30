import Foundation

nonisolated enum TickerCatalog {
    /// Tickers shown as the market-overview default watchlist on first launch.
    static let dashboardSymbols: [String] = ["SPY", "QQQ", "AAPL", "TSLA", "NVDA"]

    /// Default watchlist seeded on first launch (used by the Signal Scanner and Dashboard).
    static let scannerSymbols: [String] = [
        "SPY", "QQQ", "AAPL", "TSLA", "NVDA", "AMZN", "MSFT", "META",
        "AMD", "GOOGL", "BA", "COIN", "PLTR", "SOFI", "MARA"
    ]

    /// Broad universe of liquid, optionable names that the Dashboard auto-scans for
    /// suggestions — independent of the user's watchlist.
    static let marketUniverse: [String] = [
        // Index & sector ETFs
        "SPY", "QQQ", "IWM", "DIA", "SMH", "XLF", "XLE", "ARKK", "GLD", "TLT",
        // Mega-cap tech
        "AAPL", "MSFT", "NVDA", "AMZN", "GOOGL", "META", "TSLA", "AMD", "AVGO", "NFLX",
        "INTC", "CRM", "ORCL", "ADBE", "QCOM", "MU", "CSCO", "PLTR", "SHOP", "UBER",
        // Financials & fintech
        "JPM", "BAC", "GS", "V", "MA", "COIN", "SOFI", "HOOD", "PYPL",
        // Consumer, health, industrial, energy
        "DIS", "KO", "MCD", "NKE", "WMT", "COST", "HD", "JNJ", "UNH", "PFE",
        "XOM", "CVX", "BA", "CAT", "F", "GM", "T",
        // High-beta / crypto-adjacent
        "MARA", "RIOT", "NIO"
    ]

    static let companyNames: [String: String] = [
        "SPY": "SPDR S&P 500 ETF",
        "QQQ": "Invesco QQQ Trust",
        "IWM": "iShares Russell 2000 ETF",
        "DIA": "SPDR Dow Jones Industrial Average ETF",
        "SMH": "VanEck Semiconductor ETF",
        "XLF": "Financial Select Sector SPDR",
        "XLE": "Energy Select Sector SPDR",
        "ARKK": "ARK Innovation ETF",
        "GLD": "SPDR Gold Shares",
        "TLT": "iShares 20+ Year Treasury Bond ETF",
        "AAPL": "Apple Inc.",
        "MSFT": "Microsoft Corporation",
        "NVDA": "NVIDIA Corporation",
        "AMZN": "Amazon.com, Inc.",
        "GOOGL": "Alphabet Inc.",
        "META": "Meta Platforms, Inc.",
        "TSLA": "Tesla, Inc.",
        "AMD": "Advanced Micro Devices, Inc.",
        "AVGO": "Broadcom Inc.",
        "NFLX": "Netflix, Inc.",
        "INTC": "Intel Corporation",
        "CRM": "Salesforce, Inc.",
        "ORCL": "Oracle Corporation",
        "ADBE": "Adobe Inc.",
        "QCOM": "QUALCOMM Incorporated",
        "MU": "Micron Technology, Inc.",
        "CSCO": "Cisco Systems, Inc.",
        "PLTR": "Palantir Technologies Inc.",
        "SHOP": "Shopify Inc.",
        "UBER": "Uber Technologies, Inc.",
        "JPM": "JPMorgan Chase & Co.",
        "BAC": "Bank of America Corporation",
        "GS": "The Goldman Sachs Group, Inc.",
        "V": "Visa Inc.",
        "MA": "Mastercard Incorporated",
        "COIN": "Coinbase Global, Inc.",
        "SOFI": "SoFi Technologies, Inc.",
        "HOOD": "Robinhood Markets, Inc.",
        "PYPL": "PayPal Holdings, Inc.",
        "DIS": "The Walt Disney Company",
        "KO": "The Coca-Cola Company",
        "MCD": "McDonald's Corporation",
        "NKE": "NIKE, Inc.",
        "WMT": "Walmart Inc.",
        "COST": "Costco Wholesale Corporation",
        "HD": "The Home Depot, Inc.",
        "JNJ": "Johnson & Johnson",
        "UNH": "UnitedHealth Group Incorporated",
        "PFE": "Pfizer Inc.",
        "XOM": "Exxon Mobil Corporation",
        "CVX": "Chevron Corporation",
        "BA": "The Boeing Company",
        "CAT": "Caterpillar Inc.",
        "F": "Ford Motor Company",
        "GM": "General Motors Company",
        "T": "AT&T Inc.",
        "MARA": "MARA Holdings, Inc.",
        "RIOT": "Riot Platforms, Inc.",
        "NIO": "NIO Inc."
    ]

    static func companyName(for symbol: String) -> String {
        companyNames[symbol.uppercased()] ?? symbol.uppercased()
    }
}
