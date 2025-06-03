import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Bindable var task: TaskItem
    @Environment(\.dismiss) var dismiss

    @State private var taskDueDate: Date
    @State private var hasDueDate: Bool

    init(task: TaskItem) {
        self.task = task
        _taskDueDate = State(initialValue: task.dueDate ?? Date())
        _hasDueDate = State(initialValue: task.dueDate != nil)
    }

    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                TextField("Task Title", text: $task.title)
                TextField("Category", text: $task.category)
            }

            Section(header: Text("Due Date")) {
                Toggle("Set Due Date", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("Select Date", selection: $taskDueDate, displayedComponents: .date)
                }
            }
        }
        .navigationTitle("Edit Task")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if hasDueDate {
                        task.dueDate = taskDueDate
                    } else {
                        task.dueDate = nil
                    }
                    dismiss()
                }
            }
        }
    }
}

// Updated Preview for EditTaskView to include Dark Mode
#Preview("Task With Due Date") {
    // Helper to create a sample task in a container
    @MainActor
    func getPreviewTaskWithDueDate() -> (task: TaskItem, container: ModelContainer) {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: TaskItem.self, configurations: config)
            let exampleTask = TaskItem(title: "Edit Me With Due Date", dueDate: Date(), category: "Work")
            container.mainContext.insert(exampleTask)
            return (exampleTask, container)
        } catch {
            fatalError("Failed to create model container for preview: \(error)")
        }
    }
    
    let (task, container) = getPreviewTaskWithDueDate()

    return ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
        NavigationView {
            EditTaskView(task: task)
        }
        .modelContainer(container)
        .preferredColorScheme(colorScheme)
//        .previewDisplayName("With Due Date - \(colorScheme == .dark ? "Dark" : "Light")")
    }
}

#Preview("Task Without Due Date") {
    @MainActor
    func getPreviewTaskWithoutDueDate() -> (task: TaskItem, container: ModelContainer) {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: TaskItem.self, configurations: config)
            let exampleTask = TaskItem(title: "Edit Me No Due Date", category: "Personal")
            container.mainContext.insert(exampleTask)
            return (exampleTask, container)
        } catch {
            fatalError("Failed to create model container for preview: \(error)")
        }
    }
    
    let (task, container) = getPreviewTaskWithoutDueDate()

    return ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
        NavigationView {
            EditTaskView(task: task)
        }
        .modelContainer(container)
        .preferredColorScheme(colorScheme)
//        .previewDisplayName("No Due Date - \(colorScheme == .dark ? "Dark" : "Light")")
    }
}
