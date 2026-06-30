import SwiftUI

struct WatchlistView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var search = ""

    private var watchlist: [String] { env.settings.watchlist }

    private var filteredBrowse: [String] {
        let query = search.trimmingCharacters(in: .whitespaces).uppercased()
        let base = TickerCatalog.marketUniverse
        guard !query.isEmpty else { return base }
        return base.filter { symbol in
            symbol.contains(query)
                || TickerCatalog.companyName(for: symbol).uppercased().contains(query)
        }
    }

    /// A typed symbol that isn't already in the catalog or watchlist, so the user can
    /// add an arbitrary ticker (Yahoo supports symbols beyond our curated list).
    private var customCandidate: String? {
        let query = search.trimmingCharacters(in: .whitespaces).uppercased()
        guard (1...6).contains(query.count),
              query.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "." }),
              !TickerCatalog.marketUniverse.contains(query),
              !watchlist.contains(query) else { return nil }
        return query
    }

    @ViewBuilder
    private func rowContextMenu(for symbol: String) -> some View {
        Button {
            env.openInCalculator(ticker: symbol, optionType: .call)
        } label: {
            Label("Open in Calculator", systemImage: "function")
        }
        Button {
            env.settings.toggleWatchlist(symbol)
        } label: {
            Label(
                env.settings.isInWatchlist(symbol) ? "Remove from Watchlist" : "Add to Watchlist",
                systemImage: env.settings.isInWatchlist(symbol) ? "star.slash" : "star"
            )
        }
    }

    var body: some View {
        List {
            Section {
                if watchlist.isEmpty {
                    Text("No tickers yet. Search below and tap + to add some.")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(watchlist, id: \.self) { symbol in
                        WatchlistRow(symbol: symbol, inWatchlist: true) {
                            env.settings.toggleWatchlist(symbol)
                        }
                        .contextMenu { rowContextMenu(for: symbol) }
                    }
                }
            } header: {
                SectionHeader(title: "Your Watchlist (\(watchlist.count))")
            }

            Section {
                if let custom = customCandidate {
                    Button {
                        env.settings.addToWatchlist(custom)
                        search = ""
                    } label: {
                        Label("Add \u{0022}\(custom)\u{0022}", systemImage: "plus.circle")
                    }
                }
                ForEach(filteredBrowse, id: \.self) { symbol in
                    WatchlistRow(symbol: symbol, inWatchlist: env.settings.isInWatchlist(symbol)) {
                        env.settings.toggleWatchlist(symbol)
                    }
                    .contextMenu { rowContextMenu(for: symbol) }
                }
            } header: {
                SectionHeader(title: "Browse Tickers")
            } footer: {
                Text("Anything you add is scanned by the Dashboard and the Signal Scanner. You can also type any ticker symbol to add it.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $search, prompt: "Search ticker or company")
        .navigationTitle("Watchlist")
    }
}
