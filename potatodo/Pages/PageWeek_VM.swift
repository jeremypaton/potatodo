import SwiftUI

struct PotatoCounterWeek_V: View {
    let completedTasks: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 1),
                GridItem(.flexible(), spacing: 1),
                GridItem(.flexible(), spacing: 1),
                GridItem(.flexible(), spacing: 1),
                GridItem(.flexible(), spacing: 1),
                GridItem(.flexible(), spacing: 1),
                GridItem(.flexible(), spacing: 1)
            ], spacing: 1) {
                ForEach(0..<completedTasks, id: \.self) { _ in
                    Text("🥔")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(2)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
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
                Text(formatDayHeader(date))
                    .font(.headline)
                Text(formatDateHeader(date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isToday ? Color.yellow.opacity(0.8) : Color.clear)
            .cornerRadius(4)
            
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
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 8) {
                        ForEach(0..<7) { index in
                            dayView(for: weekDays[index])
                                .frame(height: (geometry.size.height - 32) / 4) // 32 for padding, 4 rows
                        }
                        
                        // Potato Counter as 8th box
                        PotatoCounterWeek_V(completedTasks: completedTasksThisWeek)
                            .frame(height: (geometry.size.height - 32) / 4)
                    }
                }
                .padding(8)
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
        }
        .background(Color(.systemGroupedBackground))
        
        Overlay_V(appManager: appManager)
    }
//    .environmentObject(overlayManager)
}

