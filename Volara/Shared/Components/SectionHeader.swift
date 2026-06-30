import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.sectionHeader)
            .tracking(1.5)
            .foregroundStyle(.secondary)
    }
}
