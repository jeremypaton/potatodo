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
    let settings: Settings = Settings()

    @Published private(set) var tasks: [Task] = []
    @Published var errorMessage: String?
    
    private let saveKey = "savedTasks"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTasks()
        if settings.mode == .prod {
            setupAutoSave()
        }
    }
    
    // MARK: - Task Management
    
    func addNewTask(title: String, color: TaskColor = .green, date: Date = Date()) -> Bool {
        let task = Task(title: title, color: color, date: date)
        guard task.isValid else {
            errorMessage = "Task text cannot be empty"
            return false
        }
        
        tasks.append(task)
        errorMessage = nil
        return true
    }
    
    func updateTask(_ task: Task) {
        guard task.isValid else {
            errorMessage = "Task text cannot be empty"
            return
        }
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            errorMessage = nil
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
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
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            errorMessage = "Failed to save tasks: \(error.localizedDescription)"
        }
    }
    
    private func loadTasks() {
        switch settings.mode {
        case .debug:
            loadDebugTasks()
        case .test:
            loadCSVTestTasks()
        case .prod:
            loadRealTasks()
        }
    }
    
    private func loadRealTasks() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        
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
    settings.mode = .debug
    
    let taskManager = TaskManager()
    
    return VStack {
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
    .environmentObject(settings)
}
