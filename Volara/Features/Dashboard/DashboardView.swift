import SwiftUI

struct DashboardView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model = DashboardModel()

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.lg),
        GridItem(.flexible(), spacing: AppSpacing.lg)
    ]

    private var isLoading: Bool {
        if case .loading = model.loadState { return true }
        return false
    }

    var body: some View {
        ScrollView {
            content
                .padding(AppSpacing.xl)
        }
        .background(Color.appBackground)
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await model.refresh(using: env.stockService) }
                } label: {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(isLoading)
            }
        }
        .task {
            if case .idle = model.loadState {
                await model.refresh(using: env.stockService)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            SectionHeader(title: "Watchlist")

            if case .failed(let message) = model.loadState, model.analyses.isEmpty {
                failureView(message)
            } else if isLoading && model.analyses.isEmpty {
                skeletonGrid
            } else {
                tickerGrid
            }
        }
    }

    private var tickerGrid: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.lg) {
            ForEach(model.analyses) { analysis in
                TickerCard(analysis: analysis)
            }
        }
    }

    private var skeletonGrid: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.lg) {
            ForEach(0..<5, id: \.self) { _ in
                DashboardSkeletonCard()
            }
        }
    }

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
            Button("Retry") {
                Task { await model.refresh(using: env.stockService) }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, AppSpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
    }
}
