import SwiftUI

struct MetricCard: View {
    let label: String
    let value: String
    var caption: String? = nil
    var valueColor: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(label.uppercased())
                .font(.sectionHeader)
                .tracking(1.5)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.statValue)
                .foregroundStyle(valueColor)
            if let caption {
                Text(caption)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
