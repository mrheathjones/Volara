import SwiftUI
import AppKit

struct SignalDetailView: View {
    let row: ScannerRow

    @Environment(\.dismiss) private var dismiss

    private var analysis: TickerAnalysis { row.analysis }
    private var scan: ScanSignal { row.scan }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    whySection
                    atrSection
                    strikeSection
                    expirationSection
                    tradingViewButton
                }
                .padding(AppSpacing.xxl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 460, height: 600)
        .background(Color.appBackground)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(analysis.symbol)
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)
                Text(analysis.companyName)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.md)

            VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)

                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text(analysis.price.asPrice)
                        .font(.statValue)
                        .foregroundStyle(.primary)
                    SignalBadge(signal: scan.signal)
                }
            }
        }
        .padding(AppSpacing.xxl)
    }

    // MARK: - Sections

    private var whySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Why this signal")
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(Array(scan.triggeredConditions.enumerated()), id: \.offset) { _, condition in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundStyle(scan.signal.color)
                            .padding(.top, 7)
                        Text(condition)
                            .font(.bodyText)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var atrSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Average True Range")
            HStack(spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("ATR")
                        .font(.sectionHeader)
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                    Text(analysis.atr.asPrice)
                        .font(.statValue)
                        .foregroundStyle(.primary)
                }
                Spacer(minLength: AppSpacing.md)
                Text(scan.atrExplanation)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .cardStyle()
        }
    }

    private var strikeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Suggested strike zone")
            HStack(spacing: AppSpacing.md) {
                strikePill(label: "LOW", value: scan.strikeLow)
                Image(systemName: "arrow.left.and.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                strikePill(label: "CURRENT", value: analysis.price, emphasized: true)
                Image(systemName: "arrow.left.and.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                strikePill(label: "HIGH", value: scan.strikeHigh)
            }
            .frame(maxWidth: .infinity)
            Text("Strike zone spans roughly 1.5x ATR around the current price.")
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
    }

    private func strikePill(label: String, value: Double, emphasized: Bool = false) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .tracking(1.0)
                .foregroundStyle(.secondary)
            Text(value.asPrice)
                .font(.system(size: 16, weight: emphasized ? .regular : .light, design: .monospaced))
                .foregroundStyle(emphasized ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cardBorder, lineWidth: 0.5)
                )
        )
    }

    private var expirationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Expiration")
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text(scan.expirationHint)
                    .font(.bodyText)
                    .foregroundStyle(.primary)
            }
            .cardStyle()
        }
    }

    private var tradingViewButton: some View {
        Button {
            openInTradingView()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "chart.xyaxis.line")
                Text("Open in TradingView")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private func openInTradingView() {
        let symbol = analysis.symbol
        let encoded = symbol.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? symbol
        guard let url = URL(string: "https://www.tradingview.com/chart/?symbol=\(encoded)") else { return }
        NSWorkspace.shared.open(url)
    }
}
