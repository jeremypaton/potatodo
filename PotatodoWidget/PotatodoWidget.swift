import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), tasks: [])
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
        // Load tasks from the same file as the main app
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let profileDirectory = documentsDirectory.appendingPathComponent("tasks_defaultUser")
        let tasksFile = profileDirectory.appendingPathComponent("tasks.json")
        
        guard let data = try? Data(contentsOf: tasksFile) else {
            return []
        }
        
        do {
            let tasks = try JSONDecoder().decode([WidgetTask].self, from: data)
            return tasks.filter { task in
                guard let taskDate = task.date else { return false }
                return Calendar.current.isDateInToday(taskDate)
            }
        } catch {
            print("Error loading tasks for widget: \(error)")
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
            Circle()
                .fill(task.isCompleted ? WidgetTaskStyle.fullColor(for: task) : Color.clear)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(WidgetTaskStyle.fullColor(for: task), lineWidth: 2)
                )
            
            Text(task.title)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

struct PotatodoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Tasks")
                .font(.headline)
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