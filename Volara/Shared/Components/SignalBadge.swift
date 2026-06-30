import SwiftUI

struct SignalBadge: View {
    let signal: SignalType

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: signal.systemImage)
            Text(signal.label)
        }
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(signal.color)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(
            Capsule().fill(signal.color.opacity(0.15))
        )
    }
}
