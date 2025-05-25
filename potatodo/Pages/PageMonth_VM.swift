import SwiftUI

struct PageMonth_VM: View {
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
    
    var body: some View {
        VStack(spacing: 20) {
            // Month header
            Text(monthYearString)
                .font(.title)
                .bold()
            
            // Month grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Day headers
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Calendar days
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date,
                               isCompleted: completedDates.contains(Calendar.current.startOfDay(for: date)),
                               completionPercentage: completionPercentage(for: date))
                            .onTapGesture {
                                appManager.setDate(date)
                                appManager.setInterval(.day)
                            }
                    } else {
                        Color.clear
                    }
                }
            }
            .padding()
            
            // Month summary
            Text("Completed: \(completedTasksThisMonth)")
                .font(.headline)
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        // Get the first weekday of the month (0 = Sunday, 6 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Create array with empty cells for days before the first of the month
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        // Add all days in the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add empty cells to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
}

//struct DayCell: View {
//    let date: Date
//    let isCompleted: Bool
//    let completionPercentage: Double
//    
//    private var dayNumber: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d"
//        return formatter.string(from: date)
//    }
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(isCompleted ? Color.green : Color.clear)
//                .opacity(completionPercentage)
//            
//            Text(dayNumber)
//                .font(.system(size: 14))
//        }
//        .frame(height: 40)
//        .overlay(
//            Circle()
//                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//        )
//    }
//}

#Preview {
    let appManager = AppManager()
    return PageMonth_VM(appManager: appManager)
}

