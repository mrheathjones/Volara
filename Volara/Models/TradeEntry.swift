import Foundation

nonisolated struct TradeEntry: Codable, Identifiable, Sendable {
    var id: UUID
    var date: Date
    var ticker: String
    var optionType: OptionType
    var strike: Double
    var expiration: Date
    var premium: Double
    var contracts: Int
    var entryReason: String
    var exitPrice: Double?
    var exitDate: Date?
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        ticker: String = "",
        optionType: OptionType = .call,
        strike: Double = 0,
        expiration: Date = Date().addingTimeInterval(60 * 60 * 24 * 21),
        premium: Double = 0,
        contracts: Int = 1,
        entryReason: String = "",
        exitPrice: Double? = nil,
        exitDate: Date? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.ticker = ticker
        self.optionType = optionType
        self.strike = strike
        self.expiration = expiration
        self.premium = premium
        self.contracts = contracts
        self.entryReason = entryReason
        self.exitPrice = exitPrice
        self.exitDate = exitDate
        self.notes = notes
    }

    var totalCost: Double { premium * Double(contracts) * 100 }

    var isOpen: Bool { exitPrice == nil }

    var profitLoss: Double? {
        guard let exitPrice else { return nil }
        return (exitPrice - premium) * Double(contracts) * 100
    }

    var profitLossPct: Double? {
        guard let profitLoss, totalCost != 0 else { return nil }
        return profitLoss / totalCost * 100
    }
}
