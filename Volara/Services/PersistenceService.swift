import Foundation

nonisolated final class PersistenceService: Sendable {
    // UserDefaults is thread-safe; nonisolated(unsafe) lets this Sendable type hold an
    // injectable instance (real .standard in the app, a throwaway suite in tests).
    private nonisolated(unsafe) let defaults: UserDefaults

    private enum Keys {
        static let completedLessons = "completedLessons"
        static let watchlist = "watchlist"
        static let defaultContracts = "defaultContracts"
        static let riskPerTradePct = "riskPerTradePct"
        static let accountSize = "accountSize"
        static let autoRefreshEnabled = "autoRefreshEnabled"
        static let autoRefreshMinutes = "autoRefreshMinutes"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Journal

    private var journalURL: URL? {
        let fm = FileManager.default
        guard let support = try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return nil }
        let dir = support.appendingPathComponent("Volara", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("journal.json")
    }

    func loadJournal() -> [TradeEntry] {
        guard let url = journalURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([TradeEntry].self, from: data)
        } catch {
            return []
        }
    }

    func saveJournal(_ entries: [TradeEntry]) {
        guard let url = journalURL else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let data = try encoder.encode(entries)
            try data.write(to: url, options: [.atomic])
        } catch {
            // Persisting failure is non-fatal for the UI; leave prior file intact.
        }
    }

    // MARK: - Lessons

    func loadCompletedLessons() -> Set<String> {
        let ids = defaults.array(forKey: Keys.completedLessons) as? [String] ?? []
        return Set(ids)
    }

    func saveCompletedLessons(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: Keys.completedLessons)
    }

    // MARK: - Settings

    var watchlist: [String] {
        get {
            defaults.array(forKey: Keys.watchlist) as? [String] ?? TickerCatalog.scannerSymbols
        }
        set {
            defaults.set(newValue, forKey: Keys.watchlist)
        }
    }

    var defaultContracts: Int {
        get {
            if defaults.object(forKey: Keys.defaultContracts) == nil { return 1 }
            return defaults.integer(forKey: Keys.defaultContracts)
        }
        set {
            defaults.set(newValue, forKey: Keys.defaultContracts)
        }
    }

    var riskPerTradePct: Double {
        get {
            if defaults.object(forKey: Keys.riskPerTradePct) == nil { return 2.0 }
            return defaults.double(forKey: Keys.riskPerTradePct)
        }
        set {
            defaults.set(newValue, forKey: Keys.riskPerTradePct)
        }
    }

    var accountSize: Double {
        get {
            if defaults.object(forKey: Keys.accountSize) == nil { return 10000 }
            return defaults.double(forKey: Keys.accountSize)
        }
        set {
            defaults.set(newValue, forKey: Keys.accountSize)
        }
    }

    var autoRefreshEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.autoRefreshEnabled) == nil { return true }
            return defaults.bool(forKey: Keys.autoRefreshEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.autoRefreshEnabled)
        }
    }

    var autoRefreshMinutes: Int {
        get {
            if defaults.object(forKey: Keys.autoRefreshMinutes) == nil { return 15 }
            return defaults.integer(forKey: Keys.autoRefreshMinutes)
        }
        set {
            defaults.set(newValue, forKey: Keys.autoRefreshMinutes)
        }
    }
}
