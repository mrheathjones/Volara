import SwiftUI

struct TradeRow: View {
    let entry: TradeEntry

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.sm) {
                    Text(entry.ticker.isEmpty ? "—" : entry.ticker.uppercased())
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(.primary)
                    optionBadge
                }

                HStack(spacing: AppSpacing.sm) {
                    Text(Self.dateFormatter.string(from: entry.date))
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(strikeText)
                        .monospacedDigit()
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text("exp \(Self.shortDateFormatter.string(from: entry.expiration))")
                }
                .font(.appCaption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: AppSpacing.md)

            VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                Text(entry.totalCost.asCurrency)
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .foregroundStyle(.primary)

                if let profitLoss = entry.profitLoss {
                    let plColor: Color = profitLoss >= 0 ? .green : .red
                    HStack(spacing: AppSpacing.xs) {
                        Text(profitLoss.asSignedCurrency)
                        if let pct = entry.profitLossPct {
                            Text("(\(pct.asSignedPercent))")
                        }
                    }
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(plColor)
                } else {
                    Text("OPEN")
                        .font(.sectionHeader)
                        .tracking(1.0)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(Rectangle())
    }

    private var optionBadge: some View {
        Text(entry.optionType.shortLabel)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(entry.optionType.color)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(entry.optionType.color.opacity(0.15))
            )
    }

    private var strikeText: String {
        "\(entry.strike.asPrice) strike"
    }
}
