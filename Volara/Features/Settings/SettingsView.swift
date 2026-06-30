import SwiftUI
import AppKit

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env

    @State private var samplePremium: Double = 2.00

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Volara"
    }

    private var appVersion: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "Version \(short) (\(build))"
    }

    var body: some View {
        @Bindable var settings = env.settings

        Form {
            Section {
                TextField(
                    "Tickers",
                    text: $settings.watchlistText,
                    axis: .vertical
                )
                .lineLimit(3...8)
                .font(.bodyText)

                Text("Manage your watchlist on the Watchlist tab, or bulk-edit here: symbols separated by commas, spaces, or new lines.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } header: {
                SectionHeader(title: "Scanner Watchlist")
            }

            Section {
                Toggle(isOn: $settings.autoRefreshEnabled) {
                    Text("Auto-refresh while open")
                        .font(.bodyText)
                }

                Picker(selection: $settings.autoRefreshMinutes) {
                    Text("Every 5 minutes").tag(5)
                    Text("Every 15 minutes").tag(15)
                    Text("Every 30 minutes").tag(30)
                    Text("Every 60 minutes").tag(60)
                } label: {
                    Text("Scan interval")
                        .font(.bodyText)
                }
                .disabled(!settings.autoRefreshEnabled)

                Text("The Dashboard auto-scans the market for CALL, PUT, and SQUEEZE setups on this interval while Volara is open. Background scanning with notifications when the app is closed is planned for a future update.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } header: {
                SectionHeader(title: "Scanning & Suggestions")
            }

            Section {
                Stepper(value: $settings.defaultContracts, in: 1...10) {
                    HStack {
                        Text("Default contracts")
                            .font(.bodyText)
                        Spacer()
                        Text("\(settings.defaultContracts)")
                            .font(.statValue)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Risk per trade: \(settings.riskPerTradePct.asPercent)")
                        .font(.bodyText)
                    Slider(value: $settings.riskPerTradePct, in: 0.5...5, step: 0.5)
                }

                HStack {
                    Text("Account size")
                        .font(.bodyText)
                    Spacer()
                    TextField(
                        "Account size",
                        value: $settings.accountSize,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 160)
                    .labelsHidden()
                }
            } header: {
                SectionHeader(title: "Trading Defaults")
            }

            Section {
                HStack {
                    Text("Sample premium")
                        .font(.bodyText)
                    Spacer()
                    TextField(
                        "Sample premium",
                        value: $samplePremium,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
                    .labelsHidden()
                }

                HStack {
                    Text("Max position size")
                        .font(.bodyText)
                    Spacer()
                    Text("\(env.settings.maxPositionSize(premium: samplePremium)) contracts")
                        .font(.statValue)
                        .foregroundStyle(.blue)
                }

                Text("Based on \(env.settings.accountSize.asCurrency) account and \(env.settings.riskPerTradePct.asPercent) risk per trade.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } header: {
                SectionHeader(title: "Position Sizing")
            }

            Section {
                HStack {
                    Text(appName)
                        .font(.bodyText)
                    Spacer()
                    Text(appVersion)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    if let url = URL(string: "https://www.tradingview.com") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("Open TradingView", systemImage: "chart.xyaxis.line")
                }

                Text("This app is for education and practice only and is not financial advice.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } header: {
                SectionHeader(title: "About")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}
