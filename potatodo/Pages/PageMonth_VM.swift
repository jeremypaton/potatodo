import SwiftUI

struct PageMonth_VM: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    
    private var currentMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: navManager.currentDate)
        return calendar.date(from: components) ?? Date()
    }
    
    private var completedDates: Set<Date> {
        let completedTasks = taskManager.tasks.filter { $0.isCompleted }
        return Set(completedTasks.map { Calendar.current.startOfDay(for: $0.date) })
    }
    
    private func completionPercentage(for date: Date) -> Double {
        let dayTasks = taskManager.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
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
        
        let monthTasks = taskManager.tasks.filter { task in
            task.date >= startOfMonth && task.date <= endOfMonth
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
        Button(action: {
            navManager.setDate(date)
            navManager.setInterval(.day)
        }) {
            ZStack {
                // Task bars
                VStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        let tasksForDate = taskManager.tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
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
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
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
        TopNav_V(navManager: navManager)

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
                    VStack {
//                        PotatoCounter_V(
//                            completedCount: completedTasksThisMonth,
//                            totalCount: 93
//                        )
                    }
                    .frame(height: geometry.size.height * 0.5)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3)),
                        alignment: .top
                    )
                }
            }
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    let overlayManager = OverlayManager(taskManager: taskManager)
    navManager.setInterval(.month)
    
    return ZStack {
        VStack {
            PageMonth_VM(taskManager: taskManager, navManager: navManager)
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        
        Overlay_V()
    }
    .environmentObject(overlayManager)
}

