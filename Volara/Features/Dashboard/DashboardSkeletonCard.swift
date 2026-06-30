import SwiftUI

struct DashboardSkeletonCard: View {
    @State private var isAnimating = false

    private var placeholderColor: Color {
        Color.secondary.opacity(isAnimating ? 0.10 : 0.22)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    bar(width: 60, height: 16)
                    bar(width: 120, height: 11)
                }
                Spacer()
                bar(width: 56, height: 22)
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                bar(width: 100, height: 22)
                bar(width: 80, height: 13)
            }

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(placeholderColor)
                .frame(height: 48)

            bar(width: 64, height: 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(placeholderColor)
            .frame(width: width, height: height)
    }
}
