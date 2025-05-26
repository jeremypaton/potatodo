import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    init() {
    }
    
    func placeholder(in context: Context) -> TaskEntry {
        return TaskEntry(date: Date(), tasks: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(date: Date(), tasks: loadTodayTasks())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = TaskEntry(date: Date(), tasks: loadTodayTasks())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadTodayTasks() -> [WidgetTask] {
        // Load tasks from the shared App Group container
        let fileManager = FileManager.default
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.wombleman.potatodo") else {
            return []
        }
        let profileDirectory = containerURL.appendingPathComponent("tasks_defaultUser")
        let tasksFile = profileDirectory.appendingPathComponent("tasks.json")
        
        guard let data = try? Data(contentsOf: tasksFile) else {
            return []
        }
        
        do {
            // First try to decode as Task (main app type)
            if let tasks = try? JSONDecoder().decode([Task].self, from: data) {
                let todayTasks = tasks.filter { task in
                    guard let taskDate = task.date else {
                        return false
                    }
                    return Calendar.current.isDateInToday(taskDate)
                }.map { task in
                    // Convert Task to WidgetTask
                    WidgetTask(
                        id: task.id,
                        title: task.title,
                        isCompleted: task.isCompleted,
                        color: WidgetTaskColor(rawValue: task.color.rawValue) ?? .green,
                        date: task.date
                    )
                }
                return todayTasks
            }
            
            // If that fails, try to decode as WidgetTask
            let tasks = try JSONDecoder().decode([WidgetTask].self, from: data)
            return tasks.filter { task in
                guard let taskDate = task.date else {
                    return false
                }
                return Calendar.current.isDateInToday(taskDate)
            }
        } catch {
            return []
        }
    }
}

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
}

struct WidgetTaskView: View {
    let task: WidgetTask
    
    var body: some View {
        HStack {
            Text(task.title.uppercased())
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            Spacer()
            Circle()
                .fill(task.isCompleted ? WidgetTaskStyle.fullColor(for: task) : Color.clear)
                .frame(width: 18, height: 18)
                .overlay(
                    Circle()
                        .stroke(WidgetTaskStyle.fullColor(for: task), lineWidth: 2)
                )
            
        }
    }
}

struct PotatodoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("pota.TODO")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            if entry.tasks.isEmpty {
                Text("No tasks for today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(entry.tasks.prefix(3)) { task in
                    WidgetTaskView(task: task)
                }
                
                if entry.tasks.count > 3 {
                    Text("+ \(entry.tasks.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct PotatodoWidget: Widget {
    let kind: String = "PotatodoWidget"
    
    init() {
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PotatodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("Shows your tasks for today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PotatodoWidget_Previews: PreviewProvider {
    static var previews: some View {
        PotatodoWidgetEntryView(entry: TaskEntry(date: Date(), tasks: [
            WidgetTask(title: "Buy groceries", isCompleted: true, color: .green, date: Date()),
            WidgetTask(title: "Call mom", isCompleted: false, color: .blue, date: Date()),
            WidgetTask(title: "Finish project", isCompleted: false, color: .red, date: Date())
        ]))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
} 
