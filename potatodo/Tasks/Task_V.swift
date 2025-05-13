import SwiftUI

// MARK: - Task Row Style Protocol
protocol BaseTaskRowStyle {
    var height: CGFloat { get }
    var fontSize: CGFloat { get }
    var padding: EdgeInsets { get }
    var backgroundColor: Color { get }
    var cornerRadius: CGFloat { get }
    var circleSize: CGFloat { get }
    var strokeWidth: CGFloat { get }
    var shadowRadius: CGFloat { get }
}

// MARK: - Task Row Styles
struct DefaultTaskRowStyle: BaseTaskRowStyle {
    var height: CGFloat = 60
    var fontSize: CGFloat = 34
    var padding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    var backgroundColor: Color = .white
    var cornerRadius: CGFloat = 12
    var circleSize: CGFloat = 40
    var strokeWidth: CGFloat = 3
    var shadowRadius: CGFloat = 4
}

struct CompactTaskRowStyle: BaseTaskRowStyle {
    var height: CGFloat = 35
    var fontSize: CGFloat = 20
    var padding = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
    var backgroundColor: Color = .white
    var cornerRadius: CGFloat = 8
    var circleSize: CGFloat = 24
    var strokeWidth: CGFloat = 2.25
    var shadowRadius: CGFloat = 2
}

// MARK: - Task Style
struct TaskStyle {
    static func partialColor(for task: Task) -> Color {
        return TaskStyle.fullColor(for: task).mix(with: Color.white, by: 0.4)
    }
    
    static func hintColor(for task: Task) -> Color {
        return TaskStyle.fullColor(for: task).mix(with: Color.white, by: 0.7)
    }
    
    static func fullColor(for task: Task) -> Color {
        switch task.color {
        case .green: return Color.green
        case .blue: return Color.blue
        case .yellow: return Color.yellow
        case .purple: return Color.purple
        case .red: return Color.red
        }
    }
    
    static func bgColor(for task: Task) -> Color {
        if task.isCompleted {
            return TaskStyle.partialColor(for: task)
        } else {
            return Color.white
        }
    }
    
    static func toggleColor(for task: Task) -> Color {
        if task.isCompleted {
            return TaskStyle.fullColor(for: task)
        } else {
            return Color.white
        }
    }
    
}


struct Task_V: View {
    @ObservedObject var taskManager: TaskManager
    let taskId: UUID
    let isCompact: Bool
    
    private var task: Task {
        taskManager.tasks.first(where: { $0.id == taskId }) ?? Task(title: "ERROR", color: .red)
    }
    
    private var style: BaseTaskRowStyle {
        isCompact ? CompactTaskRowStyle() : DefaultTaskRowStyle()
    }
    
    var body: some View {
        guard let _ = taskManager.tasks.first(where: { $0.id == taskId }) else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            HStack {
                // Delete button
                Button {
                    taskManager.deleteTask(task)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                        .font(.system(size: style.fontSize * 0.8))
                }
                .frame(width: style.circleSize)
                
                // Task text
                Text(task.title.uppercased())
                    .font(.system(size: style.fontSize, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity)
                
                // Completion circle
                Button {
                    taskManager.toggleTaskCompletion(task)
                } label: {
                    ZStack {
                        Circle()
                            .fill(TaskStyle.toggleColor(for: task))
                            .frame(width: style.circleSize, height: style.circleSize)
                            .shadow(color: Color.black.opacity(0.2), radius: style.shadowRadius, x: 0, y: 1)
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: style.fontSize * 0.7, weight: .semibold))
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: style.circleSize)
            }
            .padding(style.padding)
            .frame(height: style.height)
            .background(TaskStyle.bgColor(for: task))
            .cornerRadius(style.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(TaskStyle.fullColor(for: task), lineWidth: style.strokeWidth)
            )
            .shadow(color: Color.black.opacity(0.1), radius: style.shadowRadius, x: 0, y: 2)
        )
    }
}


// MARK: - Add Task Button View
struct AddTaskButton_V: View {
    @ObservedObject var taskManager: TaskManager
    let isCompact: Bool
    let date: Date
    @State private var showingAddTask = false
    @State private var newTaskText = ""
    
    var body: some View {
        Button(action: { showingAddTask = true }) {
            HStack {
                Text("➕")
                    .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
            }
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: isCompact ? CompactTaskRowStyle().height : DefaultTaskRowStyle().height)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(isCompact ? 8 : 12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .alert("Add New Task", isPresented: $showingAddTask) {
            TextField("Task description", text: $newTaskText)
            Button("Cancel", role: .cancel){
                newTaskText = ""
            }
            Button("Add") {
                if taskManager.addNewTask(title: newTaskText, date: date) {
                    newTaskText = ""
                }
            }
        }
    }
}

#Preview {
    let taskManager = TaskManager()

    return VStack {
        ForEach(taskManager.tasks) { task in
            Task_V(taskManager: taskManager, taskId: task.id, isCompact: false)
        }
        
        AddTaskButton_V(taskManager: taskManager, isCompact: false, date: Date())
        
        HStack {
            VStack {
                ForEach(taskManager.tasks) { task in
                    Task_V(taskManager: taskManager, taskId: task.id, isCompact: true)
                }
                
                AddTaskButton_V(taskManager: taskManager, isCompact: true, date: Date())

            }
            .frame(width: UIScreen.main.bounds.width / 2)
            
            
            Spacer()
        }
    }
}
