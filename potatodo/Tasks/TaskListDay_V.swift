//
//  TaskListDay_V.swift
//  potatodo
//
//  Created by Jeremy Paton on 13/5/2025.
//

import SwiftUI

struct TaskListDay_V: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    
    private var tasksForCurrentDay: [Task] {
        taskManager.tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: navManager.currentDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                if index < tasksForCurrentDay.count {
                    Task_V(taskManager: taskManager, taskId: tasksForCurrentDay[index].id, isCompact: false)
                } else if index == 2 {
                    AddTaskButton_V(taskManager: taskManager, isCompact: false, date: navManager.currentDate)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    
    // Add some test tasks
    taskManager.loadTestTasks()
    
    return VStack {
        // Top navigation bar
        TopNav_V(navManager: navManager)
        
        TaskListDay_V(taskManager: taskManager, navManager: navManager)
        
        Spacer()

        BottomNav_V(navManager: navManager)
    }
    .background(Color(.systemGroupedBackground))
}

