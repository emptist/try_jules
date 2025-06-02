import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Bindable var task: TaskItem // Use @Bindable for two-way binding with the SwiftData model
    @Environment(\.dismiss) var dismiss // To dismiss the view if needed

    // State for managing optional Date
    @State private var taskDueDate: Date
    @State private var hasDueDate: Bool

    init(task: TaskItem) {
        self.task = task
        // Initialize local state for DatePicker
        _taskDueDate = State(initialValue: task.dueDate ?? Date())
        _hasDueDate = State(initialValue: task.dueDate != nil)
    }

    var body: some View {
        Form {
            Section(header: Text("Task Details")) {
                TextField("Task Title", text: $task.title)
                TextField("Category", text: $task.category) // Add this line
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
                    // Apply the date changes before dismissing
                    if hasDueDate {
                        task.dueDate = taskDueDate
                    } else {
                        task.dueDate = nil
                    }
                    // Changes to task.title are already bound and updated.
                    // SwiftData automatically saves changes to @Model objects.
                    dismiss()
                }
            }
        }
        // If presented modally, you might need a Done button within the view
        // that calls dismiss() and ensures data is saved/applied.
        // Since we'll use NavigationLink, the "Done" in toolbar is more appropriate.
        .onDisappear {
            // This is another place to ensure date is set,
            // but the "Done" button is more explicit for user action.
            // if hasDueDate {
            //     task.dueDate = taskDueDate
            // } else {
            //     task.dueDate = nil
            // }
        }
    }
}

#Preview {
    // Previewing EditTaskView requires a TaskItem instance and a ModelContainer.
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TaskItem.self, configurations: config)
        let exampleTask = TaskItem(title: "Edit Me", dueDate: Date())
        container.mainContext.insert(exampleTask)

        // EditTaskView is typically presented within a NavigationView
        return NavigationView {
            EditTaskView(task: exampleTask)
        }
        .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}

#Preview("Task without Due Date") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TaskItem.self, configurations: config)
        let exampleTask = TaskItem(title: "Edit Me No Due Date")
        container.mainContext.insert(exampleTask)

        return NavigationView {
            EditTaskView(task: exampleTask)
        }
        .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}
