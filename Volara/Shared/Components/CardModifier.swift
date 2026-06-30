import SwiftUI

struct CardBackground: ViewModifier {
    var padding: CGFloat = AppSpacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.cardBorder, lineWidth: 0.5)
            )
    }
}

extension View {
    func cardStyle(padding: CGFloat = AppSpacing.lg) -> some View {
        modifier(CardBackground(padding: padding))
    }
}
