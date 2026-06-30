import Foundation

nonisolated enum OptionType: String, Codable, CaseIterable, Sendable, Identifiable {
    case call
    case put

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .call: return "Call"
        case .put: return "Put"
        }
    }

    var shortLabel: String {
        switch self {
        case .call: return "CALL"
        case .put: return "PUT"
        }
    }
}
