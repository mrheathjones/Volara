import SwiftUI
import AppKit

extension Color {
    static let appBackground = Color(nsColor: .windowBackgroundColor)
    static let cardFill = Color(nsColor: .controlBackgroundColor)
    static let cardBorder = Color(nsColor: .separatorColor)
}

extension SignalType {
    var color: Color {
        switch self {
        case .call: return .green
        case .put: return .red
        case .neutral: return .blue
        case .squeeze: return .orange
        }
    }
}

extension OptionType {
    var color: Color {
        switch self {
        case .call: return .green
        case .put: return .red
        }
    }
}

extension BreakoutDirection {
    var color: Color {
        switch self {
        case .breakout: return .green
        case .breakdown: return .red
        case .neutral: return .blue
        }
    }
}
