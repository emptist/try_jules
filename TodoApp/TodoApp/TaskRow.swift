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
                    task.isCompleted.toggle()
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
        // Consider adding a subtle background change or a leading bar for overdue tasks
        // For example:
        // .background(taskIsOverdue() && !task.isCompleted ? Color.red.opacity(0.1) : Color.clear)
        // However, this might make the UI too busy. Let's stick to text and icon for now.
    }

    private func taskIsOverdue() -> Bool {
        guard let dueDate = task.dueDate else { return false }
        // A task is overdue if its due date is before the start of today.
        // The check for !task.isCompleted is handled at the call sites where visual changes are applied.
        return dueDate < Calendar.current.startOfDay(for: Date())
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TaskItem.self, configurations: config)

        let overdueTask = TaskItem(title: "Overdue Task", dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), category: "Test")
        let dueTodayTask = TaskItem(title: "Due Today Task", dueDate: Date(), category: "Test") // Due today, not overdue yet.
        let dueLaterTask = TaskItem(title: "Future Task", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()), category: "Test")
        let completedOverdueTask = TaskItem(title: "Completed Overdue", isCompleted: true, dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), category: "Test")
        let noDueDateTask = TaskItem(title: "No Due Date", category: "Test")


        container.mainContext.insert(overdueTask)
        container.mainContext.insert(dueTodayTask)
        container.mainContext.insert(dueLaterTask)
        container.mainContext.insert(completedOverdueTask)
        container.mainContext.insert(noDueDateTask)

        return NavigationView {
            List {
                TaskRow(task: overdueTask)
                TaskRow(task: dueTodayTask)
                TaskRow(task: dueLaterTask)
                TaskRow(task: completedOverdueTask)
                TaskRow(task: noDueDateTask)
            }
        }
        .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}
