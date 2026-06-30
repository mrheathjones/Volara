import SwiftUI
import Charts

struct TickerCard: View {
    let analysis: TickerAnalysis

    private var isUp: Bool { analysis.changeAmount >= 0 }
    private var trendColor: Color { isUp ? .green : .red }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            header
            price
            sparkline
            footer
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
            SignalBadge(signal: SignalEvaluator.dashboardSignal(for: analysis))
        }
    }

    private var price: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(analysis.price.asPrice)
                .font(.statValue)
                .foregroundStyle(.primary)
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: isUp ? "arrow.up" : "arrow.down")
                    .font(.system(size: 11, weight: .semibold))
                Text(analysis.changeAmount.asSignedCurrency)
                Text("(\(analysis.changePct.asSignedPercent))")
            }
            .font(.system(size: 13, weight: .medium, design: .monospaced))
            .foregroundStyle(trendColor)
        }
    }

    private var sparkline: some View {
        Chart(Array(analysis.sparkline.enumerated()), id: \.offset) { index, value in
            LineMark(
                x: .value("Index", index),
                y: .value("Price", value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(trendColor)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 48)
    }

    private var footer: some View {
        HStack {
            Text("RSI \(Int(analysis.rsi.rounded()))")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
            Spacer()
            if analysis.isHighVolume {
                Text("HIGH VOL")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.orange)
            }
        }
    }
}
