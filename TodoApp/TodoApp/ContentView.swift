import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TaskListView()
        }
    }
}

// Updated Preview for ContentView to include Dark Mode
#Preview {
    // Helper closure to create and populate the container for preview
    // This is similar to TaskListView's preview container.
    // For a real app, this might be a shared utility.
    @MainActor
    func getPreviewContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: TaskItem.self, configurations: config)
            
            // Add some basic sample data, as TaskListView's preview does more extensive seeding.
            container.mainContext.insert(TaskItem(title: "Sample Task 1 (Content)", category: "Home"))
            container.mainContext.insert(TaskItem(title: "Sample Task 2 (Content)", category: "Work", isCompleted: true))
            
            return container
        } catch {
            fatalError("Failed to create model container for preview: \(error)")
        }
    }

    return ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
        ContentView()
            .modelContainer(getPreviewContainer()) // Provide the model container
            .preferredColorScheme(colorScheme)
            .previewDisplayName("ContentView - \(colorScheme == .dark ? "Dark" : "Light")")
    }
}
