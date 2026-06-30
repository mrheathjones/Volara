import Foundation

nonisolated enum SortOption: String, CaseIterable, Identifiable {
    case signal
    case rsi
    case ticker

    var id: String { rawValue }

    var title: String {
        switch self {
        case .signal: return "Signal"
        case .rsi: return "RSI"
        case .ticker: return "Ticker"
        }
    }
}
