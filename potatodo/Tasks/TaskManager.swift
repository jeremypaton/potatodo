//
//  Task_VM.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TaskManager: ObservableObject {
    @ObservedObject var appManager: AppManager
    //    let notificationsManager = NotificationsManager()
    
    //    @Published private(set) var tasks: [Task] = []
//    @Published var errorMessage: String?
    
    //    var unscheduledTasks: [Task] {
    //        tasks.filter { $0.date == nil }
    //    }
    
    private var tasksDirectory: URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let profileDirectory = documentsDirectory.appendingPathComponent("tasks_\(appManager.appDataStore.userSettings.profile.rawValue)")
        
        print("Documents Directory: \(documentsDirectory.path)")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: profileDirectory.path) {
            try? fileManager.createDirectory(at: profileDirectory, withIntermediateDirectories: true)
        }
        
        return profileDirectory
    }
    
    private var tasksFile: URL {
        tasksDirectory.appendingPathComponent("tasks.json")
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appManager: AppManager) {
        self.appManager = appManager
    }
    
    func swapTaskIDs(_ id1: UUID, _ id2: UUID) {
        return
    }
    
    func getTasksForProfile() -> [Task] {
        switch appManager.appDataStore.userSettings.profile {
        case .debug:
            return loadDebugTasks()
        case .test:
            return loadCSVTestTasks()
        case .prod:
            return loadRealTasks()
        }
    }
    
    private func loadRealTasks() -> [Task] {
        var tasks : [Task] = []
        guard let data = try? Data(contentsOf: tasksFile) else {
            return []
        }
        
        do {
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            // errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
        return tasks
    }
    
    // MARK: - Test Data
    
    private func loadDebugTasks() -> [Task]  {
        let testTasks = [
            Task(title: "Buy groceries", isCompleted: true, color: .green, date: Date()),
            Task(title: "Call mom", isCompleted: true, color: .blue, date: Date()),
            Task(title: "Finish project", isCompleted: false, color: .red, date: Date()),
        ]
        
        return testTasks
    }
    
    private func loadCSVTestTasks() -> [Task]  {
        var tasks : [Task] = []

        guard let csvURL = Bundle.main.url(forResource: "test_tasks", withExtension: "csv") else {
            return tasks
        }
        
        do {
            let csvString = try String(contentsOf: csvURL, encoding: .utf8)
            let rows = csvString.components(separatedBy: .newlines)
            
            var loadedTasks: [Task] = []
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            for row in rows where !row.isEmpty {
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 4 else { continue }
                
                let title = columns[0].trimmingCharacters(in: .whitespaces)
                let isCompletedString = columns[1].trimmingCharacters(in: .whitespaces).lowercased()
                let isCompleted = isCompletedString == "true" || isCompletedString == "1" || isCompletedString == "yes"
                let colorString = columns[2].trimmingCharacters(in: .whitespaces)
                let offsetString = columns[3].trimmingCharacters(in: .whitespaces)
                
                let color: TaskColor
                switch colorString.lowercased() {
                case "red": color = .red
                case "blue": color = .blue
                case "yellow": color = .yellow
                case "purple": color = .purple
                default: color = .green
                }
                
                guard let offset = Int(offsetString) else { continue }
                
                let date = calendar.date(byAdding: .day, value: offset, to: today) ?? today
                
                let task = Task(title: title, isCompleted: isCompleted, color: color, date: date)
                loadedTasks.append(task)
            }
            
            tasks = loadedTasks
        } catch {
            // errorMessage = "Failed to load CSV tasks: \(error.localizedDescription)"
        }
        return tasks
    }
}

#Preview {
//    let settings = Settings()
//    settings.profile = .debug
//    
//    let taskManager = TaskManager()
//    let navManager = NavManager()
//    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    let appManager = AppManager()
    
     ZStack {
        VStack {
            ForEach(appManager.getTasks()) { task in
                Task_V(appManager: appManager, task: task, isCompact: false)
            }
            
            AddTaskButton_V(appManager: appManager, isCompact: false, date: Date())
            
            HStack {
                VStack {
                    ForEach(appManager.getTasks()) { task in
                        Task_V(appManager: appManager, task: task, isCompact: true)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 2)
                
                Spacer()
            }
        }
        Overlay_V(appManager: appManager)

    }
}
