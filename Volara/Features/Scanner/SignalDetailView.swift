import SwiftUI
import AppKit

struct SignalDetailView: View {
    let row: ScannerRow

    @Environment(\.dismiss) private var dismiss
    @Environment(AppEnvironment.self) private var env

    private var analysis: TickerAnalysis { row.analysis }
    private var scan: ScanSignal { row.scan }

    private var predictive: PredictiveSignal { PredictiveSignalEvaluator.predict(for: analysis) }

    /// The predictive read is most useful where the base signal is non-directional.
    private var showsPredictive: Bool { scan.signal == .squeeze || scan.signal == .neutral }

    private var calculatorOptionType: OptionType {
        switch scan.signal {
        case .call: return .call
        case .put: return .put
        case .squeeze, .neutral: return predictive.direction.suggestedOption ?? .call
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    whySection
                    if showsPredictive {
                        predictiveSection
                    }
                    atrSection
                    strikeSection
                    expirationSection
                    actionButtons
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

    private var predictiveSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: scan.signal == .squeeze ? "Squeeze Prediction" : "Predictive Signal")
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: predictive.direction.systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(predictive.direction.color)
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(predictiveHeadline)
                            .font(.bodyText.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("Confidence \(predictive.confidenceLabel)")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                ProgressView(value: predictive.confidence, total: 100)
                    .tint(predictive.direction.color)

                ForEach(Array(predictive.rationale.enumerated()), id: \.offset) { _, reason in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundStyle(predictive.direction.color)
                            .padding(.top, 7)
                        Text(reason)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Text("Heuristic bias from trend, MACD, RSI, and Bollinger position — not a guarantee.")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .padding(.top, AppSpacing.xs)
            }
            .cardStyle()
        }
    }

    private var predictiveHeadline: String {
        switch predictive.direction {
        case .breakout: return "Leaning breakout — bias to calls"
        case .breakdown: return "Leaning breakdown — bias to puts"
        case .neutral: return "No clear directional edge yet"
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            Button {
                openInCalculator()
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "function")
                    Text("Open in Calculator")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                openInTradingView()
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Open in TradingView")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private func openInCalculator() {
        let hv = TechnicalIndicators.historicalVolatilityPercent(analysis.sparkline)
        env.openInCalculator(
            ticker: analysis.symbol,
            optionType: calculatorOptionType,
            stockPrice: analysis.price,
            volatilityPercent: hv
        )
        dismiss()
    }

    private func openInTradingView() {
        let symbol = analysis.symbol
        let encoded = symbol.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? symbol
        guard let url = URL(string: "https://www.tradingview.com/chart/?symbol=\(encoded)") else { return }
        NSWorkspace.shared.open(url)
    }
}
