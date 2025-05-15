//// MARK: - Add Task Button View
//
//import SwiftUI
//
//struct AddTaskButton_V: View {
//    @ObservedObject var taskManager: TaskManager
//    let isCompact: Bool
//    let date: Date
//    @State private var showingAddTask = false
//    @State private var newTaskText = ""
//    
//    var body: some View {
//        Button(action: { showingAddTask = true }) {
//            HStack {
//                Text("➕")
//                    .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
//            }
//            .foregroundColor(.blue)
//            .frame(maxWidth: .infinity)
//            .frame(height: isCompact ? CompactTaskRowStyle().height : DefaultTaskRowStyle().height)
//            .background(Color.gray.opacity(0.2))
//            .cornerRadius(isCompact ? 8 : 12)
//            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//        }
//        .alert("Add New Task", isPresented: $showingAddTask) {
//            TextField("Task description", text: $newTaskText)
//            Button("Cancel", role: .cancel){
//                newTaskText = ""
//            }
//            Button("Add") {
//                if taskManager.addNewTask(title: newTaskText, date: date) {
//                    newTaskText = ""
//                }
//            }
//        }
//    }
//}
