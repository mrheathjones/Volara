import SwiftUI

struct LearnView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var selectedID: String? = Lesson.all.first?.id

    private var selectedLesson: Lesson? {
        env.learn.lessons.first { $0.id == selectedID }
    }

    var body: some View {
        HStack(spacing: 0) {
            LessonListView(selection: $selectedID)
                .frame(width: 300)

            Divider()

            Group {
                if let lesson = selectedLesson {
                    LessonDetailView(lesson: lesson)
                } else {
                    placeholder
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBackground)
        .navigationTitle("Learn")
    }

    private var placeholder: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(.secondary)
            Text("Select a lesson to begin")
                .font(.bodyText)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
