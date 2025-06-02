import SwiftUI
import SwiftData

@main
struct TodoAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TaskItem.self) // Setup SwiftData container for TaskItem
    }
}
