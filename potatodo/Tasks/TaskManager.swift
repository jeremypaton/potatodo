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
    @Published private(set) var tasks: [Task] = []
    @Published var errorMessage: String?
    
    private let saveKey = "savedTasks"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTasks()
        setupAutoSave()
    }
    
    // MARK: - Task Management
    
    func addNewTask(title: String, color: TaskColor = .green) -> Bool {
        let task = Task(title: title, color: color)
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
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        
        do {
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Test Data
    
    func loadTestTasks() {
        let testTasks = [
            Task(title: "Buy groceries", isCompleted: true, color: .green),
            Task(title: "Call mom", isCompleted: true, color: .blue),
            Task(title: "Finish project", isCompleted: false, color: .red),
        ]
        
        tasks = testTasks
    }
}

#Preview {
    let taskManager = TaskManager()
    taskManager.loadTestTasks()
    return VStack {
        ForEach(taskManager.tasks) { task in
            Task_V(taskManager: taskManager, taskId: task.id, isCompact: false)
        }
        
        AddTaskButton_V(taskManager: taskManager, isCompact: false)
        
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
}
