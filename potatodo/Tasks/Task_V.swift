import SwiftUI
import Combine

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
    static func blendColor(_ color1: Color, with color2: Color, by amount: Double) -> Color {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        uiColor1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        uiColor2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        let blendedRed = red1 + (red2 - red1) * amount
        let blendedGreen = green1 + (green2 - green1) * amount
        let blendedBlue = blue1 + (blue2 - blue1) * amount
        let blendedAlpha = alpha1 + (alpha2 - alpha1) * amount
        
        return Color(UIColor(red: blendedRed, green: blendedGreen, blue: blendedBlue, alpha: blendedAlpha))
    }
    
    static func partialColor(for task: Task) -> Color {
        return blendColor(TaskStyle.fullColor(for: task), with: .white, by: 0.4)
    }
    
    static func hintColor(for task: Task) -> Color {
        return blendColor(TaskStyle.fullColor(for: task), with: .white, by: 0.7)
    }
    
    static func fullColor(for task: Task) -> Color {
        switch task.color {
        case .green: return Color.green
        case .blue: return Color.blue
        case .yellow: return Color.yellow
        case .purple: return Color.purple
        case .red: return Color.red
        case .gray: return Color.gray
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
    @ObservedObject var appManager: AppManager
//    @ObservedObject var taskManager: TaskManager
    @ObservedObject var task: Task
    let isCompact: Bool
    @State private var isTargeted = false
    
    init(appManager: AppManager, task: Task, isCompact: Bool, isTargeted: Bool = false) {
        self.appManager = appManager
//        self.taskManager = appManager.getTaskManagerForTaskView()
        self.task = task
        self.isCompact = isCompact
        self.isTargeted = isTargeted
    }
    
    private var style: BaseTaskRowStyle {
        isCompact ? CompactTaskRowStyle() : DefaultTaskRowStyle()
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                // Color cycle button
                Button {
                    task.cycleColor()
                } label: {
                    Image(systemName: "star.fill")
                        .foregroundColor(TaskStyle.fullColor(for: task))
                        .font(.system(size: style.fontSize * 1.2))
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in })
                .frame(width: style.circleSize)
                
                // Task text
                Button {
                    appManager.showTaskEdit(taskID: task.id, title: task.title)
                } label: {
                    Text(task.title.uppercased())
                        .font(.system(size: style.fontSize, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in })
                
                // Completion circle
                Button {
                    task.toggleCompletion()
                    if task.isCompleted {
                        appManager.celebrateTaskComplete()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(TaskStyle.toggleColor(for: task))
                            .frame(width: style.circleSize, height: style.circleSize)
                            .shadow(color: Color.black.opacity(0.2), radius: style.shadowRadius, x: 0, y: 1)
                        if task.isCompleted {
                            Text("🥔")
                                .font(.system(size: style.fontSize*1.1, weight: .medium))
                                .shadow(color: Color.black.opacity(0.3), radius: style.shadowRadius*2, x: 0, y: 1)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in })
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
            .scaleEffect(isTargeted ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isTargeted)
            .onDrag {
                NSItemProvider(object: task.id.uuidString as NSString)
            }
            .onDrop(of: [.text], delegate: TaskDropDelegate(taskId: task.id,isTargeted: $isTargeted))
        }
    }
}

struct TaskDropDelegate: DropDelegate {
    let taskId: UUID
//    let taskManager: TaskManager
    @Binding var isTargeted: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        isTargeted = false
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { string, _ in
            guard let draggedIdString = string as? String,
                  let draggedId = UUID(uuidString: draggedIdString) else { return }
            
            DispatchQueue.main.async {
//                self.taskManager.swapTaskIDs(self.taskId, draggedId)
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        isTargeted = true
    }
    
    func dropExited(info: DropInfo) {
        isTargeted = false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

// MARK: - Add Task Button View
struct AddTaskButton_V: View {
    @ObservedObject var appManager: AppManager
//    @ObservedObject var taskManager: TaskManager
//    @EnvironmentObject var overlayManager: OverlayManager
    let isCompact: Bool
    let date: Date?
    @State private var isTargeted = false
    
    init(appManager: AppManager, isCompact: Bool, date: Date? = nil) {
        self.appManager = appManager
//        self.taskManager = appManager.getTaskManagerForTaskView()
//        self.taskId = taskId
        self.isCompact = isCompact
        self.date = date
    }
    
    var body: some View {
        Button {
            let templateTask = Task(title: "TODO", date: date)
            appManager.addTask(templateTask)
            appManager.showTaskEdit(taskID: templateTask.id, title: templateTask.title)
        } label: {
            Text("➕")
                .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity)
        .frame(height: isCompact ? CompactTaskRowStyle().height : DefaultTaskRowStyle().height)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(isCompact ? 8 : 12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .scaleEffect(isTargeted ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
//        .onDrop(of: [.text], delegate: AddTaskDropDelegate(taskManager: taskManager, date: date, isTargeted: $isTargeted))
    }
}

//struct AddTaskDropDelegate: DropDelegate {
//    let taskManager: TaskManager
//    let date: Date?
//    @Binding var isTargeted: Bool
//    
//    func performDrop(info: DropInfo) -> Bool {
//        isTargeted = false
//        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
//        
//        itemProvider.loadObject(ofClass: NSString.self) { string, _ in
//            guard let draggedIdString = string as? String,
//                  let draggedId = UUID(uuidString: draggedIdString) else { return }
//            
//            DispatchQueue.main.async {
//                if let date = self.date {
//                    self.taskManager.updateTaskDate(draggedId, newDate: date)
//                }
//            }
//        }
//        
//        return true
//    }
//    
//    func dropEntered(info: DropInfo) {
//        isTargeted = true
//    }
//    
//    func dropExited(info: DropInfo) {
//        isTargeted = false
//    }
//    
//    func dropUpdated(info: DropInfo) -> DropProposal? {
//        return DropProposal(operation: .move)
//    }
//}

#Preview {
    let appManager = AppManager()
//    let taskManager = TaskManager()
//    let navManager = NavManager()
//    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
     ZStack {
        VStack() {
            ForEach(appManager.getTasks().prefix(3)) { task in
                Task_V(appManager: appManager, task: task, isCompact: false)
            }
            
            AddTaskButton_V(appManager: appManager, isCompact: false, date: Date())
            
            HStack {
                VStack() {
                    ForEach(appManager.getTasks().prefix(3)) { task in
                        Task_V(appManager: appManager, task: task, isCompact: true)
                    }
                    
                    AddTaskButton_V(appManager: appManager, isCompact: true, date: Date())
                }
                .frame(width: UIScreen.main.bounds.width / 2)
                
                Spacer()
            }
        }
        
        Overlay_V(appManager: appManager)
    }
//    .environmentObject(overlayManager)
}
