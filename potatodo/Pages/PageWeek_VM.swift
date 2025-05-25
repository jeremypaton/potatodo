//
//  TaskWeekList_V.swift
//  potatodo
//
//  Created by Jeremy Paton on 13/5/2025.
//

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
    @ObservedObject var appManager: AppManager
    
    private var currentWeek: [Date] {
        let calendar = Calendar.current
        let today = appManager.getCurrentDate()
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - calendar.firstWeekday
        
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        
        return (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)!
        }
    }
    
    private var weekYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: currentWeek[0])
        let end = formatter.string(from: currentWeek[6])
        return "\(start) - \(end)".uppercased()
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
    
    private var completedTasksThisWeek: Int {
        let weekTasks = appManager.getTasks().filter { task in
            if let taskDate = task.date {
                return currentWeek.contains { Calendar.current.isDate($0, inSameDayAs: taskDate) }
            }
            return false
        }
        return weekTasks.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Week header
            Text(weekYearString)
                .font(.title)
                .bold()
            
            // Week grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Day headers
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Calendar days
                ForEach(currentWeek, id: \.self) { date in
                    DayCell(date: date,
                           isCompleted: appManager.getTasks().filter { $0.isCompleted && Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date) }.count > 0,
                           completionPercentage: completionPercentage(for: date))
                        .onTapGesture {
                            appManager.setDate(date)
                            appManager.setInterval(.day)
                        }
                }
            }
            .padding()
            
            // Week summary
            Text("Completed: \(completedTasksThisWeek)")
                .font(.headline)
        }
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let completionPercentage: Double
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green : Color.clear)
                .opacity(completionPercentage)
            
            Text(dayNumber)
                .font(.system(size: 14))
        }
        .frame(height: 40)
        .overlay(
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    let appManager = AppManager()
    return PageWeek_VM(appManager: appManager)
}

