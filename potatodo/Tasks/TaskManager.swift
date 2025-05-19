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
    @ObservedObject var settings: Settings
    let notificationsManager = NotificationsManager()

    @Published private(set) var tasks: [Task] = []
    @Published var errorMessage: String?
    
    var unscheduledTasks: [Task] {
        tasks.filter { $0.date == nil }
    }
    
    private var tasksDirectory: URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let profileDirectory = documentsDirectory.appendingPathComponent("tasks_\(settings.profile.rawValue)")
        
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
    
    init(settings: Settings = Settings()) {
        self.settings = settings
        loadTasks()
        if settings.profile == .prod {
            setupAutoSave()
        }
    }
    
    // MARK: - Task Management
    
    func addNewTask(title: String, color: TaskColor = .green, date: Date? = Date()) -> Task {
        var task = Task(title: title, color: color, date: date)
        if task.isValid == false {
            task.title = "?"
        }
        tasks.append(task)
        saveTasks()  // Explicitly save after adding
        return task
    }
    
    func updateTask(_ task: Task) {
        guard task.isValid else {
            errorMessage = "Task text cannot be empty"
            return
        }
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            errorMessage = nil
            saveTasks()  // Explicitly save after updating
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()  // Explicitly save after deleting
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)  // This will trigger saveTasks
    }
    
    func cycleTaskColorFromID(_ id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            var tc : TaskColor = tasks[index].color
            
            switch tc {
                case .green: tc = .blue
                case .blue: tc = .yellow
                case .yellow: tc = .purple
                case .purple: tc = .red
                case .red: tc = .gray
                case .gray: tc = .green
            }
            
            tasks[index].color = tc
            saveTasks()  // Explicitly save after color change
        }
    }
    
    func swapTaskIDs(_ id1: UUID, _ id2: UUID) {
        guard let index1 = tasks.firstIndex(where: { $0.id == id1 }),
              let index2 = tasks.firstIndex(where: { $0.id == id2 }) else {
            return
        }
        
        // Swap the tasks
        let temp = tasks[index1]
        tasks[index1] = tasks[index2]
        tasks[index2] = temp
        saveTasks()  // Explicitly save after swapping
    }
    
    func updateTaskDate(_ taskId: UUID, newDate: Date) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[index].date = newDate
        saveTasks()  // Explicitly save after date change
    }
    
    // MARK: - Persistence
    
    private func setupAutoSave() {
        $tasks
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveTasks()
            }
            .store(in: &cancellables)
    }
    
    private func saveTasks() {
        // Only save if we're in production mode
        guard settings.profile == .prod else { return }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tasks)
            try data.write(to: tasksFile)
        } catch {
            errorMessage = "Failed to save tasks: \(error.localizedDescription)"
        }
    }
    
    private func updateDailyReminders() {
        // First, remove all existing reminders to ensure clean state
        notificationsManager.removeAllReminders()
        
        // Get today and next 7 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let nextWeek = (0...7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: today)
        }
        
        // For each date in the next week
        for date in nextWeek {
            let tasksForDate = tasks.filter { task in
                if let taskDate = task.date {
                    return calendar.isDate(taskDate, inSameDayAs: date)
                }
                return false
            }
            if !tasksForDate.isEmpty {
                // If there are tasks for this date, create task-specific reminder
                notificationsManager.updateRemindersForDay(date, tasks: tasksForDate)
            } else {
                // If no tasks, create default reminder
                notificationsManager.setReminderText(for: date, text: notificationsManager.defaultReminderText)
            }
        }
    }
    
    func loadTasks() {
        // Clear current tasks before loading new ones
        tasks = []
        
        switch settings.profile {
        case .debug:
            loadDebugTasks()
        case .test:
            loadCSVTestTasks()
        case .prod:
            loadRealTasks()
        }
        updateDailyReminders()
    }
    
    private func loadRealTasks() {
        guard let data = try? Data(contentsOf: tasksFile) else {
            return
        }
        
        do {
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Test Data
    
    private func loadDebugTasks() {
        let testTasks = [
            Task(title: "Buy groceries", isCompleted: true, color: .green, date: Date()),
            Task(title: "Call mom", isCompleted: true, color: .blue, date: Date()),
            Task(title: "Finish project", isCompleted: false, color: .red, date: Date()),
        ]
        
        tasks = testTasks
    }
    
    private func loadCSVTestTasks() {
        guard let csvURL = Bundle.main.url(forResource: "test_tasks", withExtension: "csv") else {
            errorMessage = "Could not find test_tasks.csv"
            return
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
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load CSV tasks: \(error.localizedDescription)"
        }
    }
}

#Preview {
    let settings = Settings()
    settings.profile = .debug
    
    let taskManager = TaskManager()
    let navManager = NavManager()
    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    
    return ZStack {
        VStack {
            ForEach(taskManager.tasks) { task in
                Task_V(taskManager: taskManager, taskId: task.id, isCompact: false)
            }
            
            AddTaskButton_V(taskManager: taskManager, isCompact: false, date: Date())
            
            HStack {
                VStack {
                    ForEach(taskManager.tasks) { task in
                        Task_V(taskManager: taskManager, taskId: task.id, isCompact: true)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 2)
                
                Spacer()
            }
        }
        Overlay_V()

    }
    .environmentObject(settings)
    .environmentObject(overlayManager)

}
