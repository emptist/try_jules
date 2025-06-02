import SwiftUI
import SwiftData

// Define SortOption enum outside the struct but in the same file
enum SortOption: String, CaseIterable, Identifiable {
    case createdAtDescending = "Newest First"
    case createdAtAscending = "Oldest First"
    case dueDateAscending = "By Due Date (Earliest)"
    // case dueDateDescending = "By Due Date (Latest)" // Optional, can be added later
    case completionStatus = "By Completion (Incomplete First)"

    var id: String { self.rawValue }
}

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\TaskItem.createdAt, order: .reverse)]) private var allTasks: [TaskItem]

    @State private var selectedCategory: String = "All"
    @State private var newTaskTitle: String = ""
    @State private var newTaskCategory: String = "General"
    @State private var searchText: String = ""
    @State private var currentSortOption: SortOption = .createdAtDescending

    var categories: [String] {
        let uniqueCategories = Set(allTasks.map { $0.category })
        return ["All"] + Array(uniqueCategories).sorted()
    }

    var searchedAndFilteredTasks: [TaskItem] {
        var tasksToDisplay = Array(allTasks)

        if selectedCategory != "All" {
            tasksToDisplay = tasksToDisplay.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            tasksToDisplay = tasksToDisplay.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch currentSortOption {
        case .createdAtDescending:
            tasksToDisplay.sort { $0.createdAt > $1.createdAt }
        case .createdAtAscending:
            tasksToDisplay.sort { $0.createdAt < $1.createdAt }
        case .dueDateAscending:
            tasksToDisplay.sort {
                guard let date1 = $0.dueDate else { return false }
                guard let date2 = $1.dueDate else { return true }
                return date1 < date2
            }
        case .completionStatus:
            tasksToDisplay.sort {
                if $0.isCompleted == $1.isCompleted {
                    return $0.createdAt > $1.createdAt
                }
                return !$0.isCompleted && $1.isCompleted
            }
        }
        return tasksToDisplay
    }

    var body: some View {
        VStack(alignment: .leading) {
            Picker("Sort by", selection: $currentSortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .padding(.horizontal)

            Picker("Filter by Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .padding(.horizontal)
            .pickerStyle(.segmented)

            TextField("Search tasks...", text: $searchText)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !searchText.isEmpty {
                            Button(action: { self.searchText = "" }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal)
                .padding(.top)

            List {
                ForEach(searchedAndFilteredTasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("My Tasks")

            HStack {
                TextField("Enter new task...", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Category", text: $newTaskCategory)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }

    private func addTask() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let trimmedCategory = newTaskCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryToSave = trimmedCategory.isEmpty ? "General" : trimmedCategory

        let newTask = TaskItem(title: trimmedTitle, category: categoryToSave)
        modelContext.insert(newTask)

        newTaskTitle = ""
        newTaskCategory = "General"
    }

    private func deleteTask(offsets: IndexSet) {
        withAnimation {
            offsets.map { searchedAndFilteredTasks[$0] }.forEach(modelContext.delete)
        }
    }
}

// Updated Preview for TaskListView to include Dark Mode
#Preview {
    // Helper closure to create and populate the container for preview
    @MainActor
    func getPreviewContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: TaskItem.self, configurations: config)

            let now = Date()
            container.mainContext.insert(TaskItem(title: "Task A (Due +5d, Created -10000s)", category: "Work", dueDate: Calendar.current.date(byAdding: .day, value: 5, to: now), createdAt: now.addingTimeInterval(-10000)))
            container.mainContext.insert(TaskItem(title: "Task B (Due +1d, Created -20000s)", category: "Work", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: now), createdAt: now.addingTimeInterval(-20000)))
            container.mainContext.insert(TaskItem(title: "Task C (No Due Date, Completed, Created -5000s)", category: "Personal", isCompleted: true, createdAt: now.addingTimeInterval(-5000)))
            container.mainContext.insert(TaskItem(title: "Task D (Due -1d, Completed, Created -30000s)", category: "Personal", isCompleted: true, dueDate: Calendar.current.date(byAdding: .day, value: -1, to: now), createdAt: now.addingTimeInterval(-30000)))
            container.mainContext.insert(TaskItem(title: "Task E (Recent, Incomplete, No Due Date, Created -100s)", category: "Study", createdAt: now.addingTimeInterval(-100)))
            container.mainContext.insert(TaskItem(title: "Task F (Oldest, Due +2d, Incomplete)", category: "Project", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: now), createdAt: now.addingTimeInterval(-50000)))
            container.mainContext.insert(TaskItem(title: "Task G (Recent, Completed, Due +3d)", category: "Work", isCompleted: true, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: now), createdAt: now.addingTimeInterval(-50)))
            return container
        } catch {
            fatalError("Failed to create model container for preview: \(error)")
        }
    }

    // Loop through color schemes
    return ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
        NavigationView {
            TaskListView()
        }
        .modelContainer(getPreviewContainer()) // Use the helper
        .preferredColorScheme(colorScheme)
        .previewDisplayName("\(colorScheme == .dark ? "Dark" : "Light") Mode")
    }
}
