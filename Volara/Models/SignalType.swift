import Foundation

nonisolated enum SignalType: String, Codable, CaseIterable, Sendable, Identifiable {
    case call
    case put
    case neutral
    case squeeze

    var id: String { rawValue }

    var label: String {
        switch self {
        case .call: return "CALL"
        case .put: return "PUT"
        case .neutral: return "NEUTRAL"
        case .squeeze: return "SQUEEZE"
        }
    }

    var systemImage: String {
        switch self {
        case .call: return "arrow.up.right"
        case .put: return "arrow.down.right"
        case .neutral: return "minus"
        case .squeeze: return "arrow.left.and.right.righttriangle.left.righttriangle.right"
        }
    }
}
