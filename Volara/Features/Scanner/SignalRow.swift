import SwiftUI

struct SignalRow: View {
    let row: ScannerRow

    private var analysis: TickerAnalysis { row.analysis }

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(analysis.symbol)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.primary)
                Text(analysis.companyName)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.md)

            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text(analysis.price.asPrice)
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundStyle(.primary)
                Text(analysis.changePct.asSignedPercent)
                    .font(.appCaption)
                    .foregroundStyle(analysis.changeAmount >= 0 ? .green : .red)
            }
            .frame(minWidth: 88, alignment: .trailing)

            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text("RSI \(Int(analysis.rsi.rounded()))")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                Text("BBW \(analysis.bbWidthPct.asPercent)")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 80, alignment: .trailing)

            volumeTag
                .frame(width: 64, alignment: .center)

            SignalBadge(signal: row.scan.signal)
                .frame(minWidth: 96, alignment: .trailing)
        }
        .padding(.vertical, AppSpacing.xs)
        .contentShape(Rectangle())
    }

    private var volumeTag: some View {
        let isHigh = analysis.isHighVolume
        let tint: Color = isHigh ? .orange : .secondary
        return Text(isHigh ? "HIGH" : "NORMAL")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(tint.opacity(0.15))
            )
    }
}
