import SwiftUI

struct LessonDetailView: View {
    @Environment(AppEnvironment.self) private var env
    let lesson: Lesson

    private var isCompleted: Bool {
        env.learn.isCompleted(lesson)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(lesson.title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: lesson.icon)
                        Text("Lesson \(lesson.number)")
                        Text("·")
                        Text("\(lesson.estimatedMinutes) min read")
                    }
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                }

                Divider()

                MarkdownText(markdown: lesson.content)

                completeButton
                    .padding(.top, AppSpacing.md)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.xxl)
        }
    }

    private var completeButton: some View {
        Button {
            env.learn.toggleCompleted(lesson)
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                Text(isCompleted ? "Completed" : "Mark as complete")
            }
            .font(.bodyText)
            .foregroundStyle(isCompleted ? Color.green : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isCompleted ? Color.green.opacity(0.15) : Color.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isCompleted ? Color.green.opacity(0.4) : Color.cardBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}
