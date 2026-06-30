import Foundation
import Observation

@Observable
final class LearnModel {
    private let persistence: PersistenceService
    private(set) var completedIDs: Set<String>

    init(persistence: PersistenceService) {
        self.persistence = persistence
        self.completedIDs = persistence.loadCompletedLessons()
    }

    var lessons: [Lesson] { Lesson.all }

    var completedCount: Int { completedIDs.count }

    var totalCount: Int { lessons.count }

    func isCompleted(_ lesson: Lesson) -> Bool {
        completedIDs.contains(lesson.id)
    }

    func toggleCompleted(_ lesson: Lesson) {
        if completedIDs.contains(lesson.id) {
            completedIDs.remove(lesson.id)
        } else {
            completedIDs.insert(lesson.id)
        }
        persistence.saveCompletedLessons(completedIDs)
    }
}
