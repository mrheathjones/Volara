import SwiftUI

struct MarkdownText: View {
    let markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                blockView(for: block)
            }
        }
    }

    private var blocks: [String] {
        markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    @ViewBuilder
    private func blockView(for block: String) -> some View {
        let lines = block.components(separatedBy: "\n")

        if block.hasPrefix("## ") {
            Text(stripped(block, prefix: "## "))
                .font(.title3)
                .fontWeight(.semibold)
        } else if block.hasPrefix("# ") {
            Text(stripped(block, prefix: "# "))
                .font(.title2)
                .fontWeight(.semibold)
        } else if lines.allSatisfy({ $0.hasPrefix("- ") }) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    bulletRow(for: stripped(line, prefix: "- "))
                }
            }
        } else {
            Text(.init(block))
                .font(.bodyText)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func bulletRow(for text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
            Text("•")
                .font(.bodyText)
                .foregroundStyle(.secondary)
            Text(.init(text))
                .font(.bodyText)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func stripped(_ value: String, prefix: String) -> String {
        String(value.dropFirst(prefix.count))
            .trimmingCharacters(in: .whitespaces)
    }
}
