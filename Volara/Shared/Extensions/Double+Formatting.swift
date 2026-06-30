import Foundation

extension Double {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }

    var asPrice: String {
        String(format: "$%.2f", self)
    }

    var asSignedCurrency: String {
        let sign = self >= 0 ? "+" : "-"
        return sign + String(format: "$%.2f", abs(self))
    }

    var asPercent: String {
        String(format: "%.1f%%", self)
    }

    var asSignedPercent: String {
        let sign = self >= 0 ? "+" : "-"
        return sign + String(format: "%.1f%%", abs(self))
    }

    var asCompactVolume: String {
        let absValue = abs(self)
        switch absValue {
        case 1_000_000_000...:
            return String(format: "%.1fB", self / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.1fM", self / 1_000_000)
        case 1_000...:
            return String(format: "%.1fK", self / 1_000)
        default:
            return String(format: "%.0f", self)
        }
    }
}
