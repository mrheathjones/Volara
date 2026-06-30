import Foundation

nonisolated enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard
    case scanner
    case watchlist
    case calculator
    case learn
    case journal
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .scanner: return "Scanner"
        case .watchlist: return "Watchlist"
        case .calculator: return "Calculator"
        case .learn: return "Learn"
        case .journal: return "Journal"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "chart.line.uptrend.xyaxis"
        case .scanner: return "magnifyingglass"
        case .watchlist: return "star"
        case .calculator: return "function"
        case .learn: return "book.closed"
        case .journal: return "square.and.pencil"
        case .settings: return "gear"
        }
    }
}
