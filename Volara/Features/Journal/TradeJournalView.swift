import SwiftUI

struct TradeJournalView: View {
    @Environment(AppEnvironment.self) private var env

    @State private var draft: TradeEntry?
    @State private var pendingDelete: TradeEntry?

    private let summaryColumns = [
        GridItem(.adaptive(minimum: 160), spacing: AppSpacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            summaryBar
                .padding(.horizontal, AppSpacing.xl)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)

            if env.journal.entries.isEmpty {
                emptyState
            } else {
                tradeList
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Journal")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    draft = TradeEntry()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(item: $draft) { entry in
            TradeEntryView(entry: entry)
                .environment(env)
        }
        .confirmationDialog(
            "Delete this trade?",
            isPresented: deleteDialogBinding,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let entry = pendingDelete {
                    env.journal.delete(entry)
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            if let entry = pendingDelete {
                Text("\(entry.ticker.uppercased()) \(entry.optionType.shortLabel) — this can't be undone.")
            }
        }
    }

    // MARK: - Summary

    private var summaryBar: some View {
        LazyVGrid(columns: summaryColumns, alignment: .leading, spacing: AppSpacing.md) {
            MetricCard(
                label: "Total Trades",
                value: "\(env.journal.totalTrades)"
            )
            MetricCard(
                label: "Win Rate",
                value: env.journal.winRate.asPercent
            )
            MetricCard(
                label: "Avg P&L %",
                value: env.journal.averagePLPct.asSignedPercent,
                valueColor: plColor(env.journal.averagePLPct)
            )
            MetricCard(
                label: "Total P&L",
                value: env.journal.totalPL.asSignedCurrency,
                valueColor: plColor(env.journal.totalPL)
            )
        }
    }

    // MARK: - List

    private var tradeList: some View {
        List {
            if !env.journal.openTrades.isEmpty {
                Section {
                    ForEach(env.journal.openTrades) { entry in
                        row(for: entry)
                    }
                } header: {
                    SectionHeader(title: "Open Trades")
                }
            }

            if !env.journal.closedTrades.isEmpty {
                Section {
                    ForEach(env.journal.closedTrades) { entry in
                        row(for: entry)
                    }
                } header: {
                    SectionHeader(title: "Closed Trades")
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }

    private func row(for entry: TradeEntry) -> some View {
        TradeRow(entry: entry)
            .contentShape(Rectangle())
            .onTapGesture {
                draft = entry
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    pendingDelete = entry
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Image(systemName: "square.and.pencil")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No trades yet")
                .font(.bodyText)
                .foregroundStyle(.secondary)
            Text("Log your first options trade to start tracking performance.")
                .font(.appCaption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Button {
                draft = TradeEntry()
            } label: {
                Label("Add Trade", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, AppSpacing.sm)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }

    // MARK: - Helpers

    private var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { newValue in
                if !newValue { pendingDelete = nil }
            }
        )
    }

    private func plColor(_ value: Double) -> Color {
        if value > 0 { return .green }
        if value < 0 { return .red }
        return .primary
    }
}
