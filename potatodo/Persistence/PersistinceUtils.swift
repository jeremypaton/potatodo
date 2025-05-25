//
//  PersistinceUtils.swift
//  potatodo
//
//  Created by Jeremy Paton on 25/5/2025.
//

import Foundation
import SwiftUI
import Combine

struct PersistinceUtils {
    
    static private func tasksDirectoryForProfile(_ profile: Profile) -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let profileDirectory = documentsDirectory.appendingPathComponent("tasks_\(profile.name)")
        
        print("Documents Directory: \(documentsDirectory.path)")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: profileDirectory.path) {
            try? fileManager.createDirectory(at: profileDirectory, withIntermediateDirectories: true)
        }
        
        return profileDirectory
    }
    
    static private func tasksFileForProfile(_ profile : Profile) -> URL {
        return tasksDirectoryForProfile(profile).appendingPathComponent("tasks.json")
    }
    
    static func getTaskArrayForProfile(_ profile: Profile) -> [Task] {
        if profile.name == "DEBUG" {
            return loadDebugTasks()
        } else if profile.name == "TEST" {
            return loadCSVTestTasks()
        } else {
            return loadRealTasksForProfile(profile)
        }
    }
    
    static private func loadRealTasksForProfile(_ profile: Profile) -> [Task] {
        var tasks : [Task] = []
        guard let data = try? Data(contentsOf: tasksFileForProfile(profile)) else {
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
    
    static private func loadDebugTasks() -> [Task]  {
        let testTasks = [
            Task(title: "Buy groceries", isCompleted: true, color: .green, date: Date()),
            Task(title: "Call mom", isCompleted: true, color: .blue, date: Date()),
            Task(title: "Finish project", isCompleted: false, color: .red, date: Date()),
        ]
        
        return testTasks
    }
    
    static private func loadCSVTestTasks() -> [Task]  {
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
