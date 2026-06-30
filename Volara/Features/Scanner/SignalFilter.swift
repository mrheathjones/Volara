import Foundation

nonisolated enum SignalFilter: String, CaseIterable, Identifiable {
    case all
    case call
    case put
    case squeeze

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .call: return "CALL"
        case .put: return "PUT"
        case .squeeze: return "SQUEEZE"
        }
    }

    func matches(_ s: SignalType) -> Bool {
        switch self {
        case .all: return true
        case .call: return s == .call
        case .put: return s == .put
        case .squeeze: return s == .squeeze
        }
    }
}
