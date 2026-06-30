import Foundation

/// The predicted resolution of a Bollinger Band squeeze.
nonisolated enum BreakoutDirection: String, Sendable, Identifiable {
    case breakout   // upside bias -> favors calls
    case breakdown  // downside bias -> favors puts
    case neutral    // no clear edge

    var id: String { rawValue }

    var label: String {
        switch self {
        case .breakout: return "Breakout"
        case .breakdown: return "Breakdown"
        case .neutral: return "Unclear"
        }
    }

    /// The option side the prediction leans toward, if any.
    var suggestedOption: OptionType? {
        switch self {
        case .breakout: return .call
        case .breakdown: return .put
        case .neutral: return nil
        }
    }

    var systemImage: String {
        switch self {
        case .breakout: return "arrow.up.right"
        case .breakdown: return "arrow.down.right"
        case .neutral: return "arrow.left.and.right"
        }
    }
}
