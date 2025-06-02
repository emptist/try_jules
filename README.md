# To-Do App

A concise and practical to-do list application built with SwiftUI and SwiftData for iOS. This app focuses on core task management functionalities with a clean and intuitive user interface.

## Features

*   **Task Management**: Add, edit, delete, and mark tasks as complete or incomplete.
*   **Persistent Storage**: Tasks are saved locally using SwiftData, so they persist across app sessions.
*   **Task Categories**: Assign categories to tasks (e.g., "Work", "Personal", "Shopping") and filter the task list by category.
*   **Due Dates**: Set due dates for tasks. Overdue tasks (that are not yet completed) are highlighted in the list.
*   **Search**: Quickly find tasks by searching for keywords in their titles.
*   **Sorting**: Sort tasks by:
    *   Creation Date (Newest/Oldest First)
    *   Due Date (Earliest First)
    *   Completion Status (Incomplete First)
*   **User Interface**:
    *   Clean and minimalist design built with SwiftUI.
    *   Supports both Light and Dark system modes.
    *   Simple animation feedback for task completion.
*   **Quick Add**: Easily add new tasks using input fields at the bottom of the main list.
*   **Intuitive Gestures**: Tap to toggle completion, swipe left to delete tasks.

## How to Run

1.  **Clone or Download the Repository**:
    *   If using Git: `git clone <repository_url>`
    *   Alternatively, download the source code ZIP from the repository page and extract it.

2.  **Open in Xcode**:
    *   **Method 1 (Recommended - Open Folder):**
        1.  Open Xcode.
        2.  Choose "Open a project or file..." (or File > Open...).
        3.  Navigate to the root folder of the cloned/extracted repository.
        4.  Select this root folder and click "Open". Xcode should detect it as a Swift Package.
    *   **Method 2 (Create New Project & Add Files):**
        1.  Open Xcode and create a new iOS App project (SwiftUI interface, SwiftUI App lifecycle, Swift language, Storage: None).
        2.  Delete the default `ContentView.swift` and `YourProjectNameApp.swift` files from the new project.
        3.  Drag all the `.swift` files from the `TodoApp/TodoApp/` directory (from the downloaded/cloned code) into your new Xcode project's navigator. Ensure "Copy items if needed" is checked.

3.  **Build and Run**:
    *   Select an iPhone simulator or a connected iOS device from the scheme menu at the top of Xcode.
    *   Click the "Play" button (or press Command+R) to build and run the application.

## Future Enhancements (Optional)

*   Customizable categories with colors.
*   Task reminders and notifications.
*   iCloud synchronization across devices.
*   More advanced sorting and filtering options.
*   Widget support.
