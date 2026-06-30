import SwiftUI

struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var selection: SidebarItem? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: item.systemImage)
                }
            }
            .navigationTitle("Volara")
        } detail: {
            NavigationStack {
                detailView(for: selection ?? .dashboard)
            }
        }
    }

    @ViewBuilder
    private func detailView(for item: SidebarItem) -> some View {
        switch item {
        case .dashboard: DashboardView()
        case .scanner: SignalScannerView()
        case .calculator: OptionsCalculatorView()
        case .learn: LearnView()
        case .journal: TradeJournalView()
        case .settings: SettingsView()
        }
    }
}
