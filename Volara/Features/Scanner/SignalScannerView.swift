import SwiftUI

struct SignalScannerView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model = SignalScannerModel()

    var body: some View {
        @Bindable var model = model

        Group {
            if model.rows.isEmpty {
                switch model.loadState {
                case .failed(let message):
                    errorState(message)
                case .loaded:
                    content
                default:
                    loadingState
                }
            } else {
                content
            }
        }
        .navigationTitle("Signal Scanner")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Filter", selection: $model.filter) {
                    ForEach(SignalFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }

            ToolbarItem(placement: .automatic) {
                Picker("Sort", selection: $model.sort) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.menu)
            }

            ToolbarItem(placement: .automatic) {
                Button {
                    Task { await runScan() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(model.loadState == .loading)
                .help("Rescan watchlist")
            }
        }
        .sheet(item: $model.selectedRow) { row in
            SignalDetailView(row: row)
        }
        .task {
            if model.loadState == .idle {
                await runScan()
            }
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .controlSize(.large)
            Text("Scanning the watchlist…")
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.orange)
            Text(message)
                .font(.bodyText)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
            Button("Try Again") {
                Task { await runScan() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xxxl)
        .background(Color.appBackground)
    }

    private var content: some View {
        List {
            if case .loading = model.loadState {
                HStack(spacing: AppSpacing.sm) {
                    ProgressView().controlSize(.small)
                    Text("Refreshing…")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
                .listRowSeparator(.hidden)
            }

            if model.displayedRows.isEmpty {
                Text("No tickers match this filter.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.xxl)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(model.displayedRows) { row in
                    SignalRow(row: row)
                        .onTapGesture {
                            model.selectedRow = row
                        }
                }
            }
        }
        .listStyle(.inset)
        .background(Color.appBackground)
    }

    // MARK: - Actions

    private func runScan() async {
        let watchlist = env.settings.watchlist
        let symbols = watchlist.isEmpty ? TickerCatalog.scannerSymbols : watchlist
        await model.scan(using: env.stockService, symbols: symbols)
    }
}
