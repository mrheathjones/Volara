import SwiftUI

struct LessonListView: View {
    @Environment(AppEnvironment.self) private var env
    @Binding var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SectionHeader(title: "Progress")
                ProgressView(
                    value: Double(env.learn.completedCount),
                    total: Double(max(env.learn.totalCount, 1))
                )
                .tint(.green)
                Text("\(env.learn.completedCount) / \(env.learn.totalCount) completed")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
            .padding(AppSpacing.lg)

            Divider()

            List(env.learn.lessons, selection: $selection) { lesson in
                row(for: lesson)
                    .tag(lesson.id)
            }
            .listStyle(.sidebar)
        }
    }

    private func row(for lesson: Lesson) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: lesson.icon)
                .font(.system(size: 18))
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("\(lesson.number). \(lesson.title)")
                    .font(.bodyText)
                    .foregroundStyle(.primary)
                Text("\(lesson.estimatedMinutes) min")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: AppSpacing.sm)

            if env.learn.isCompleted(lesson) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
