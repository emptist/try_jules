import Foundation
import SwiftData

@Model
final class TaskItem { // Classes are typically used with @Model for SwiftData
    var id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    var category: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String = "", isCompleted: Bool = false, dueDate: Date? = nil, category: String = "General", createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.category = category
        self.createdAt = createdAt
    }
}

// Keep sample data for previews if needed, but it won't be used for the main app logic anymore.
// Or remove it if it causes confusion or issues with the @Model macro.
// For now, let's keep it but be aware it's for PREVIEW ONLY.
extension TaskItem {
    @MainActor
    static var sampleTasks: [TaskItem] {
        [
            TaskItem(title: "Buy groceries SwiftData", category: "Shopping"),
            TaskItem(title: "Finish report SwiftData", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()), category: "Work"),
            TaskItem(title: "Call mom SwiftData", isCompleted: true),
            TaskItem(title: "Book flight tickets SwiftData", category: "Personal", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date())
        ]
    }
}
