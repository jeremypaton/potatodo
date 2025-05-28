import SwiftUI

struct PotatoCounterMonth_V: View {
    let completedTasks: Int
    let appManager: AppManager
    @State private var sortedTasks: [Task] = []
    
    private func loadTasks() async {
        let monthDays = await CounterUtils.getMonthDays(appManager: appManager)
        sortedTasks = await CounterUtils.getSortedCompletedTasks(appManager: appManager, dateRange: monthDays)
    }
    
    private var colorGroups: [(TaskColor, [Task])] {
        CounterUtils.getColorGroups(tasks: sortedTasks)
            .sorted { $0.1.count > $1.1.count }

    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Text("TASKS COMPLETED: \(completedTasks)")
                    .font(.subheadline)
                Spacer()
            }
            .padding(.bottom, 4)

            // Color count circles row
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
                            .frame(width: 32, height: 32)
                        Text("\(tasks.count)")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(TaskStyle.fullColor(for: tasks[0]))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
            
            // Potato grids
            ForEach(colorGroups, id: \.0) { color, tasks in
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1),
                    GridItem(.flexible(), spacing: 1)
                ], spacing: 0) {
                    ForEach(tasks) { task in
                        ZStack {
                            Circle()
                                .fill(TaskStyle.partialColor(for: task))
                            Text("🥔")
                                .font(.system(size: 24))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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

struct PageMonth_VM: View {
//    @ObservedObject var taskManager: TaskManager
//    @ObservedObject var navManager: NavManager
    @ObservedObject var appManager: AppManager
    
    private var currentMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: appManager.getCurrentDate())
        return calendar.date(from: components) ?? Date()
    }
    
    private var completedDates: Set<Date> {
        let completedTasks = appManager.getTasks().filter { $0.isCompleted }
        return Set(completedTasks.compactMap { task in
            if let date = task.date {
                return Calendar.current.startOfDay(for: date)
            }
            return nil
        })
    }
    
    private func completionPercentage(for date: Date) -> Double {
        let dayTasks = appManager.getTasks().filter { task in
            if let taskDate = task.date {
                return Calendar.current.isDate(taskDate, inSameDayAs: date)
            }
            return false
        }
        guard !dayTasks.isEmpty else { return 0 }
        let completedCount = dayTasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(dayTasks.count)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: currentMonth).uppercased()
    }
    
    private var completedTasksThisMonth: Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let monthTasks = appManager.getTasks().filter { task in
            if let taskDate = task.date {
                return taskDate >= startOfMonth && taskDate <= endOfMonth
            }
            return false
        }
        return monthTasks.filter { $0.isCompleted }.count
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        // Get the first day of the month
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = 1
        guard let firstDay = calendar.date(from: components) else { return [] }
        
        // Get the weekday of the first day (1 = Sunday, 7 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        // Add empty slots for days before the first of the month
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        // Add all days of the month
        for day in range {
            var components = calendar.dateComponents([.year, .month], from: currentMonth)
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(date)
            }
        }
        
        // Calculate number of weeks needed
        let totalDays = days.count
        let weeksNeeded = Int(ceil(Double(totalDays) / 7.0))
        
        // Add empty slots at the end if needed to complete the last week
        let remainingSlots = weeksNeeded * 7 - totalDays
        if remainingSlots > 0 {
            days.append(contentsOf: Array(repeating: nil, count: remainingSlots))
        }
        
        return days
    }
    
    private var weeksInMonth: Int {
        let days = daysInMonth()
        return Int(ceil(Double(days.count) / 7.0))
    }
    
    private let weekDays = ["Su", "M", "Tu", "W", "Th", "F", "Sa"]
    
    private func dayView(for date: Date) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        
        return Button(action: {
            appManager.setDate(date)
            appManager.setInterval(.day)
            appManager.getNavManagerForNavView().setPage(.day)
        }) {
            ZStack {
                // Task bars
                VStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        let tasksForDate = appManager.getTasks().filter { task in
                            if let taskDate = task.date {
                                return Calendar.current.isDate(taskDate, inSameDayAs: date)
                            }
                            return false
                        }.sorted { $0.position < $1.position }
                        if index < tasksForDate.count {
                            let task = tasksForDate[index]
                            Rectangle()
                                .fill(task.isCompleted ? TaskStyle.fullColor(for: task) :
                                        Color.white)//TaskStyle.hintColor(for: task))
                                .strokeBorder(task.isCompleted ? TaskStyle.fullColor(for: task) : TaskStyle.hintColor(for: task), lineWidth: 6)
                                .frame(maxHeight: .infinity)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(maxHeight: .infinity)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Day number
                if isToday {
                    Text("★")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(Color.clear)
                        .cornerRadius(4)
                        .fontWeight(.bold)
                } else {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(Color.clear)
                        .cornerRadius(4)
                }
//                Text("\(Calendar.current.component(.day, from: date))")
//                    .font(.system(size: 14))
//                    .foregroundColor(.black)
//                    .padding(4)
//                    .background(isToday ? Color.yellow.opacity(0.8) : Color.clear)
//                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .trailing
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
    
    private func emptyDayView() -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .trailing
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .bottom
            )
    }
    
    var body: some View {
        TopNav_V(appManager: appManager)

        VStack(spacing: 0) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Calendar Container
                    VStack(spacing: 0) {
                        // Day headers
                        HStack(spacing: 0) {
                            ForEach(weekDays, id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                        .padding(.bottom, 2)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                            .frame(height: 1)
                        
                        // Calendar Grid
                        VStack(spacing: 0) {
                            ForEach(0..<weeksInMonth, id: \.self) { weekIndex in
                                HStack(spacing: 0) {
                                    ForEach(0..<7) { dayIndex in
                                        let dateIndex = weekIndex * 7 + dayIndex
                                        if dateIndex < daysInMonth().count, let date = daysInMonth()[dateIndex] {
                                            dayView(for: date)
                                        } else {
                                            emptyDayView()
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.vertical, 4)
                    .frame(height: geometry.size.height * 0.5)
                    
                    // Month completion counter
                    PotatoCounterMonth_V(completedTasks: completedTasksThisMonth, appManager: appManager)
                        .frame(height: geometry.size.height * 0.5)
                }
            }
        }
    }
}

#Preview {
//    let taskManager = TaskManager()
//    let navManager = NavManager()
//    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    let appManager = AppManager()
    appManager.setInterval(.month)
    
    return ZStack {
        VStack {
            PageMonth_VM(appManager: appManager)
            BottomNav_V(appManager: appManager)
        }
        .background(Color(.systemGroupedBackground))
        
        Overlay_V(appManager: appManager)
    }
//    .environmentObject(overlayManager)
}

