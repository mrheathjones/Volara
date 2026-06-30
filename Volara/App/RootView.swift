import SwiftUI

struct RootView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        @Bindable var env = environment

        NavigationSplitView {
            List(SidebarItem.allCases, selection: $env.selection) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: item.systemImage)
                }
            }
            .navigationTitle("Volara")
        } detail: {
            NavigationStack {
                detailView(for: environment.selection ?? .dashboard)
            }
        }
    }

    @ViewBuilder
    private func detailView(for item: SidebarItem) -> some View {
        switch item {
        case .dashboard: DashboardView()
        case .scanner: SignalScannerView()
        case .watchlist: WatchlistView()
        case .calculator: OptionsCalculatorView()
        case .learn: LearnView()
        case .journal: TradeJournalView()
        case .settings: SettingsView()
        }
    }
}
