import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]

    @State private var selectedCategory: String = "All"
    @State private var newTaskTitle: String = ""
    @State private var newTaskCategory: String = "General"
    @State private var searchText: String = "" // State for search text

    var categories: [String] {
        let uniqueCategories = Set(allTasks.map { $0.category })
        return ["All"] + Array(uniqueCategories).sorted()
    }

    // Computed property for tasks filtered by category AND search text
    var searchedAndFilteredTasks: [TaskItem] {
        var tasksToDisplay = allTasks

        // Filter by selected category
        if selectedCategory != "All" {
            tasksToDisplay = tasksToDisplay.filter { $0.category == selectedCategory }
        }

        // Filter by search text (if not empty)
        if !searchText.isEmpty {
            tasksToDisplay = tasksToDisplay.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        return tasksToDisplay
    }

    var body: some View {
        VStack {
            // Category Picker
            Picker("Filter by Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .padding(.horizontal)
            .pickerStyle(.segmented) // Or .menu

            // Search Bar
            TextField("Search tasks...", text: $searchText)
                .padding(7)
                .padding(.horizontal, 25) // For icon spacing
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !searchText.isEmpty {
                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal)
                .padding(.top) // Add some space above the search bar


            List {
                // Use searchedAndFilteredTasks for the list
                ForEach(searchedAndFilteredTasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("My Tasks")
            // .listStyle(InsetGroupedListStyle()) // Optional: for a different list appearance

            // Task Creation UI (HStack)
            HStack {
                TextField("Enter new task...", text: $newTaskTitle) // Binding directly, rely on trim in addTask
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Category", text: $newTaskCategory) // Binding directly, rely on trim in addTask
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding() // Add padding around the input HStack
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
        newTaskCategory = "General" // Reset category field
    }

    private func deleteTask(offsets: IndexSet) {
        withAnimation {
            // Use searchedAndFilteredTasks to get the correct task to delete
            offsets.map { searchedAndFilteredTasks[$0] }.forEach(modelContext.delete)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TaskItem.self, configurations: config)

        // Sample data for preview
        container.mainContext.insert(TaskItem(title: "Groceries Shopping", category: "Shopping"))
        container.mainContext.insert(TaskItem(title: "Finish SwiftUI Report", category: "Work", dueDate: Date()))
        container.mainContext.insert(TaskItem(title: "Call Mom", category: "Personal", isCompleted: true))
        container.mainContext.insert(TaskItem(title: "Plan vacation", category: "Personal"))
        container.mainContext.insert(TaskItem(title: "Read Swift Programming book", category: "Study"))
        container.mainContext.insert(TaskItem(title: "Another Shopping task", category: "Shopping"))


        return NavigationView {
            TaskListView()
        }
        .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}
