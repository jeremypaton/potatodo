import SwiftUI

struct CounterUtils {
    static func getSortedCompletedTasks(appManager: AppManager, dateRange: [Date]) async -> [Task] {
        let completedTasks = await appManager.getTasks().filter { task in
            if let taskDate = task.date {
                return task.isCompleted && dateRange.contains { day in
                    Calendar.current.isDate(taskDate, inSameDayAs: day)
                }
            }
            return false
        }
        
        // Group tasks by color and count occurrences
        let colorCounts = Dictionary(grouping: completedTasks, by: { $0.color })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        // Sort tasks by color frequency
        return completedTasks.sorted { task1, task2 in
            let count1 = colorCounts.first { $0.key == task1.color }?.value ?? 0
            let count2 = colorCounts.first { $0.key == task2.color }?.value ?? 0
            if count1 == count2 {
                return task1.color.rawValue < task2.color.rawValue
            }
            return count1 > count2
        }
    }
    
    static func getColorGroups(tasks: [Task]) -> [(TaskColor, [Task])] {
        Dictionary(grouping: tasks) { $0.color }
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    static func getWeekDays(appManager: AppManager) async -> [Date] {
        let calendar = Calendar.current
        let weekStart = await appManager.getWeekStart()
        let weekday = calendar.component(.weekday, from: weekStart)
        let daysToSubtract = (weekday + 5) % 7
        
        return (0..<7).map { day in
            calendar.date(byAdding: .day, value: day - daysToSubtract, to: weekStart) ?? Date()
        }
    }
    
    static func getMonthDays(appManager: AppManager) async -> [Date] {
        let calendar = Calendar.current
        let currentMonth = await appManager.getCurrentDate()
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        // Get the first day of the month
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = 1
        guard let firstDay = calendar.date(from: components) else { return [] }
        
        return range.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay) ?? Date()
        }
    }
} 