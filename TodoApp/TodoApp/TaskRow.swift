import SwiftUI
import SwiftData

struct TaskRow: View {
    @Bindable var task: TaskItem

    var body: some View {
        HStack {
            // Completion toggle
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(task.isCompleted ? .green : .gray)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) { // Added explicit animation
                        task.isCompleted.toggle()
                    }
                }

            // NavigationLink for editing
            NavigationLink(destination: EditTaskView(task: task)) {
                VStack(alignment: .leading) {
                    Text(task.title)
                        .strikethrough(task.isCompleted, color: .gray)
                        .foregroundColor(taskIsOverdue() && !task.isCompleted ? .red : .primary) // Highlight title if overdue
                        .opacity(task.isCompleted ? 0.5 : 1.0)
                    
                    if let dueDate = task.dueDate {
                        HStack {
                            if taskIsOverdue() && !task.isCompleted {
                                Image(systemName: "calendar.badge.exclamationmark") // Overdue icon
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            Text("Due: \(dueDate, style: .date)")
                                .font(.caption)
                                .foregroundColor(taskIsOverdue() && !task.isCompleted ? .red : .gray)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle()) 

            Spacer() 
        }
        .padding(.vertical, 4)
    }
    
    private func taskIsOverdue() -> Bool {
        guard let dueDate = task.dueDate else { return false }
        return dueDate < Calendar.current.startOfDay(for: Date())
    }
}

// Updated Preview for TaskRow to include Dark Mode
#Preview {
    // Helper closure to create and populate the container for preview items
    @MainActor
    func getPreviewTaskItems(in container: ModelContainer) -> (overdue: TaskItem, dueToday: TaskItem, future: TaskItem, completedOverdue: TaskItem, noDueDate: TaskItem) {
        let overdueTask = TaskItem(title: "Overdue Task", dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), category: "Test")
        let dueTodayTask = TaskItem(title: "Due Today Task", dueDate: Date(), category: "Test")
        let dueLaterTask = TaskItem(title: "Future Task", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()), category: "Test")
        let completedOverdueTask = TaskItem(title: "Completed Overdue", isCompleted: true, dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), category: "Test")
        let noDueDateTask = TaskItem(title: "No Due Date", category: "Test")

        container.mainContext.insert(overdueTask)
        container.mainContext.insert(dueTodayTask)
        container.mainContext.insert(dueLaterTask)
        container.mainContext.insert(completedOverdueTask)
        container.mainContext.insert(noDueDateTask)
        
        return (overdueTask, dueTodayTask, dueLaterTask, completedOverdueTask, noDueDateTask)
    }

    // Setup the overall container once
    let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: TaskItem.self, configurations: config)
        } catch {
            fatalError("Failed to create model container for preview: \(error)")
        }
    }()
    
    // Populate items for the preview
    let (overdue, today, future, completed, noDate) = getPreviewTaskItems(in: previewContainer)

    return ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
        NavigationView { // NavigationView is good for context
            List { // List provides row context
                TaskRow(task: overdue)
                TaskRow(task: today)
                TaskRow(task: future)
                TaskRow(task: completed)
                TaskRow(task: noDate)
            }
        }
        .modelContainer(previewContainer)
        .preferredColorScheme(colorScheme)
        .previewDisplayName("TaskRow - \(colorScheme == .dark ? "Dark" : "Light")")
    }
}
