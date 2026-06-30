import SwiftUI

struct WatchlistRow: View {
    let symbol: String
    let inWatchlist: Bool
    var toggle: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(symbol)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                Text(TickerCatalog.companyName(for: symbol))
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: AppSpacing.md)
            Button(action: toggle) {
                Image(systemName: inWatchlist ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(inWatchlist ? .green : .blue)
            }
            .buttonStyle(.borderless)
            .help(inWatchlist ? "Remove from watchlist" : "Add to watchlist")
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(Rectangle())
    }
}
