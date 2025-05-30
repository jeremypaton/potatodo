import SwiftUI

struct PotatoCounterWeek_V: View {
    let completedTasks: Int
    let appManager: AppManager
    @State private var sortedTasks: [Task] = []
    
    private func loadTasks() async {
        let weekDays = await CounterUtils.getWeekDays(appManager: appManager)
        sortedTasks = await CounterUtils.getSortedCompletedTasks(appManager: appManager, dateRange: weekDays)
    }
    
    private var colorGroups: [(TaskColor, [Task])] {
        CounterUtils.getColorGroups(tasks: sortedTasks)
            .sorted { $0.1.count > $1.1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
//            HStack {
//                Spacer()
//                Text("TASKS COMPLETED: \(completedTasks)")
//                    .font(.subheadline)
//                Spacer()
//            }
//             Color count circles row
            // Color count circles row
//            HStack(spacing: 8) {
//                Spacer()
//                ForEach(colorGroups, id: \.0) { color, tasks in
//                    ZStack {
//                        Circle()
//                            .fill(Color.white)
//                            .overlay(
//                                Circle()
//                                    .stroke(TaskStyle.fullColor(for: tasks[0]), lineWidth: 2)
//                            )
//                            .frame(width: 19, height: 19) // 24 * 0.8 = 19.2
//                        Text("\(tasks.count)")
//                            .font(.system(size: 19, weight: .heavy)) // 24 * 0.8 = 19.2
//                            .foregroundColor(TaskStyle.fullColor(for: tasks[0]))
//                    }
//                }
//                Spacer()
//            }
//            .padding(.horizontal, 4)
//            .padding(.bottom, 8)
            
            
            // Potato grids
            HStack(spacing: 5) {
                Spacer()
                ForEach(colorGroups, id: \.0) { color, tasks in
                    HStack(spacing: -7) { // Overlap columns of same color (30 * 0.5 = 15)
                        ForEach(0..<(tasks.count + 6) / 7, id: \.self) { columnIndex in
                            VStack(spacing: -10) { // 35% overlap
                                Spacer() // Push content to bottom
                                ForEach(tasks.reversed().dropFirst(columnIndex * 7).prefix(7)) { task in
                                    ZStack {
                                        Circle()
                                            .fill(TaskStyle.partialColor(for: task))
                                            .stroke(Color.black, lineWidth: 1)
                                        Text("🥔")
                                            .font(.system(size: 20))
                                    }
                                    .frame(width: 23, height: 23)
                                    .shadow(radius: 2.0)
                                }
                            }
                        }
                    }
//                    .padding(.vertical, 10)
                }
                Spacer()
            }
            
            HStack {
                 Spacer()
                 Text("COMPLETED: \(completedTasks)")
                     .font(.subheadline)
                 Spacer()
             }
                
            HStack(spacing: 8) {
                Spacer()
                ForEach(colorGroups, id: \.0) { color, tasks in
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .stroke(TaskStyle.fullColor(for: tasks[0]), lineWidth: 2)
                            )
                            .frame(width: 25, height: 25) // 24 * 0.8 = 19.2
                        Text("\(tasks.count)")
                            .font(.system(size: 19, weight: .heavy)) // 24 * 0.8 = 19.2
                            .foregroundColor(TaskStyle.fullColor(for: tasks[0]))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.gray, lineWidth: 1)
        )
        .task {
            await loadTasks()
        }
        .onChange(of: completedTasks) { _, _ in
            _Concurrency.Task {
                await loadTasks()
            }
        }
    }
}

struct PageWeek_VM: View {
//    @ObservedObject var taskManager: TaskManager
//    @ObservedObject var navManager: NavManager
    @ObservedObject var appManager: AppManager

    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: appManager.getWeekStart())
        let daysToSubtract = (weekday + 5) % 7
        
        return (0..<7).map { day in
            calendar.date(byAdding: .day, value: day - daysToSubtract, to: appManager.getWeekStart()) ?? Date()
        }
    }
    
    private var completedTasksThisWeek: Int {
        appManager.getTasks().filter { task in
            if let taskDate = task.date {
                return task.isCompleted && weekDays.contains { day in
                    Calendar.current.isDate(taskDate, inSameDayAs: day)
                }
            }
            return false
        }.count
    }
    
    private func formatDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date).uppercased()
    }
    
    private func tasksForDay(_ date: Date) -> [Task] {
        appManager.getTasks().filter { task in
            if let taskDate = task.date {
                return Calendar.current.isDate(taskDate, inSameDayAs: date)
            }
            return false
        }.sorted { $0.position < $1.position }
    }
    
    private func dayView(for date: Date) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        
        return VStack(alignment: .center, spacing: 0) {
            // Header
            HStack {
                if isToday {
//                    Text("★")
//                        .font(.headline)
                    Text("TODAY")
                        .font(.headline)
//                    Text(formatDateHeader(date))
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    Text("★")
//                        .font(.headline)
                } else {
                    Text(formatDayHeader(date))
                        .font(.headline)
                    Text(formatDateHeader(date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
//            .padding(.bottom, 2)
//            .size(.horizontal, .infinity)
            
            // Task List of day in compact mode
            VStack(spacing: 4) {
                ForEach(tasksForDay(date)) { task in
                    Task_V(appManager: appManager, task: task, isCompact: true)
                }
                
                if tasksForDay(date).count < 3 {
                    AddTaskButton_V(appManager: appManager, isCompact: true, date: date)
                }
                
                Spacer(minLength: 0)
            }
        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    var body: some View {
        TopNav_V(appManager: appManager)

        GeometryReader { geometry in
            ZStack {
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 0),
                        GridItem(.flexible(), spacing: 0)
                    ], spacing: 0) {
                        ForEach(0..<7) { index in
                            dayView(for: weekDays[index])
//                                .frame(height: .infinity) // 32 for padding, 4 rows

                                .frame(height: (geometry.size.height - 0) / 4) // 32 for padding, 4 rows
                        }
                        
                        // Potato Counter as 8th box
                        PotatoCounterWeek_V(completedTasks: completedTasksThisWeek, appManager: appManager)
                            .frame(height: (geometry.size.height) / 4)
                    }
                }
//                .padding(8)
            }
        }
    }
}

#Preview {
//    let taskManager = TaskManager()
//    let navManager = NavManager()
//    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    let appManager = AppManager()
    appManager.setInterval(.week)
    
    return ZStack {
        VStack {
            PageWeek_VM(appManager: appManager)
//                .background(.red)

            BottomNav_V(appManager: appManager)

        }
        .background(Color(.systemGroupedBackground))
        
        Overlay_V(appManager: appManager)
    }
//    .environmentObject(overlayManager)
}

