import SwiftUI

struct DashboardView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model = DashboardModel()
    @State private var detailRow: ScannerRow?

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.lg),
        GridItem(.flexible(), spacing: AppSpacing.lg)
    ]

    // Restarts the auto-refresh loop whenever the cadence settings change.
    private var autoRefreshKey: String {
        "\(env.settings.autoRefreshEnabled)-\(env.settings.autoRefreshMinutes)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                suggestionsSection
                watchlistSection
            }
            .padding(AppSpacing.xl)
        }
        .background(Color.appBackground)
        .navigationTitle("Dashboard")
        .toolbar { toolbarContent }
        .sheet(item: $detailRow) { row in
            SignalDetailView(row: row)
        }
        .task(id: autoRefreshKey) {
            await runAutoRefreshLoop()
        }
    }

    // MARK: - Refresh

    private func runAutoRefreshLoop() async {
        while !Task.isCancelled {
            await model.refresh(engine: env.scanEngine, watchlist: env.settings.watchlist)
            guard env.settings.autoRefreshEnabled else { return }
            let seconds = max(60, env.settings.autoRefreshMinutes * 60)
            do {
                try await Task.sleep(for: .seconds(Double(seconds)))
            } catch {
                return // cancelled on disappear or settings change
            }
        }
    }

    private func manualRefresh() {
        Task { await model.refresh(engine: env.scanEngine, watchlist: env.settings.watchlist) }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: manualRefresh) {
                if model.isRefreshing {
                    ProgressView().controlSize(.small)
                } else {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .disabled(model.isRefreshing)
        }
    }

    // MARK: - Suggestions

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(alignment: .firstTextBaseline) {
                SectionHeader(title: "Suggestions")
                Spacer()
                if let updated = model.lastUpdated {
                    Text("Updated \(updated.formatted(date: .omitted, time: .shortened))")
                        .font(.appCaption)
                        .foregroundStyle(.tertiary)
                }
            }
            suggestionsContent
        }
    }

    @ViewBuilder
    private var suggestionsContent: some View {
        if !model.suggestions.isEmpty {
            LazyVGrid(columns: columns, spacing: AppSpacing.lg) {
                ForEach(model.suggestions) { suggestion in
                    SuggestionCard(suggestion: suggestion) {
                        detailRow = suggestion.scannerRow
                    }
                }
            }
        } else if model.isRefreshing || model.isLoading {
            scanningPlaceholder
        } else if let message = model.failureMessage, !model.hasData {
            failureView(message)
        } else {
            emptySuggestions
        }
    }

    private var scanningPlaceholder: some View {
        HStack(spacing: AppSpacing.sm) {
            ProgressView().controlSize(.small)
            Text("Scanning the market for setups…")
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
    }

    private var emptySuggestions: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(.secondary)
            Text("No strong setups right now")
                .font(.bodyText)
                .foregroundStyle(.secondary)
            Text("The market looks quiet. Volara will keep scanning and surface CALL, PUT, and SQUEEZE setups as they appear.")
                .font(.appCaption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
    }

    // MARK: - Watchlist

    private var watchlistSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(alignment: .firstTextBaseline) {
                SectionHeader(title: "Your Watchlist")
                Spacer()
                Button("Manage") { env.selection = .watchlist }
                    .buttonStyle(.borderless)
                    .font(.appCaption)
            }
            watchlistContent
        }
    }

    @ViewBuilder
    private var watchlistContent: some View {
        if env.settings.watchlist.isEmpty {
            emptyWatchlist
        } else if !model.watchlistCards.isEmpty {
            LazyVGrid(columns: columns, spacing: AppSpacing.lg) {
                ForEach(model.watchlistCards) { analysis in
                    TickerCard(analysis: analysis)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            detailRow = ScannerRow(
                                analysis: analysis,
                                scan: SignalEvaluator.scannerSignal(for: analysis)
                            )
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                env.settings.removeFromWatchlist(analysis.symbol)
                            } label: {
                                Label("Remove from Watchlist", systemImage: "star.slash")
                            }
                        }
                }
            }
        } else if model.isRefreshing || model.isLoading {
            LazyVGrid(columns: columns, spacing: AppSpacing.lg) {
                ForEach(0..<4, id: \.self) { _ in
                    DashboardSkeletonCard()
                }
            }
        } else if let message = model.failureMessage {
            failureView(message)
        } else {
            Text("Couldn't load your watchlist tickers. Try refreshing.")
                .font(.appCaption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
        }
    }

    private var emptyWatchlist: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "star")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(.secondary)
            Text("Your watchlist is empty")
                .font(.bodyText)
                .foregroundStyle(.secondary)
            Button("Add tickers") { env.selection = .watchlist }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
        .cardStyle()
    }

    // MARK: - Shared

    private func failureView(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(.secondary)
            Text("Unable to load market data")
                .font(.bodyText)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.appCaption)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
            Button("Retry", action: manualRefresh)
                .buttonStyle(.borderedProminent)
                .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
    }
}
