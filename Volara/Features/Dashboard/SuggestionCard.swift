import SwiftUI

struct SuggestionCard: View {
    let suggestion: Suggestion
    var onOpenDetails: () -> Void

    @Environment(AppEnvironment.self) private var env

    private var analysis: TickerAnalysis { suggestion.analysis }
    private var scan: ScanSignal { suggestion.scan }
    private var inWatchlist: Bool { env.settings.isInWatchlist(analysis.symbol) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            header
            priceRow
            reason
            Divider()
            actions
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(analysis.symbol)
                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                Text(analysis.companyName)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: AppSpacing.sm)
            SignalBadge(signal: scan.signal)
        }
    }

    private var priceRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(analysis.price.asPrice)
                .font(.statValue)
                .foregroundStyle(.primary)
            Spacer()
            Text("RSI \(Int(analysis.rsi.rounded()))")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
            if analysis.isHighVolume {
                Text("HIGH VOL")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.orange)
            }
        }
    }

    @ViewBuilder
    private var reason: some View {
        if let first = scan.triggeredConditions.first {
            Text(first)
                .font(.appCaption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actions: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                env.settings.toggleWatchlist(analysis.symbol)
            } label: {
                Label(
                    inWatchlist ? "In Watchlist" : "Add",
                    systemImage: inWatchlist ? "checkmark.circle.fill" : "plus.circle"
                )
                .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.borderless)
            .foregroundStyle(inWatchlist ? .green : .blue)

            Spacer()

            Button {
                onOpenDetails()
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text("Details")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.primary)
        }
    }
}
