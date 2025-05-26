//
//  PersistinceUtils.swift
//  potatodo
//
//  Created by Jeremy Paton on 25/5/2025.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

struct PersistenceUtils {
    
    static private func tasksDirectoryForProfile(_ profile: Profile) -> URL {
        let fileManager = FileManager.default
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.wombleman.potatodo") else {
            print("Error: Could not access shared container")
            // Fallback to Documents directory if shared container is not available
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return documentsDirectory.appendingPathComponent("tasks_\(profile.name)")
        }
        let profileDirectory = containerURL.appendingPathComponent("tasks_\(profile.name)")
        
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
            Task(title: "Procrastinate", isCompleted: true, color: .green),
            Task(title: "Boring stuff", isCompleted: true, color: .blue),
            Task(title: "Eat broccoli", isCompleted: false, color: .red),
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
                
                var date: Date? = nil
                if offsetString != "X" {
                   if let offset = Int(offsetString) {
                       date = calendar.date(byAdding: .day, value: offset, to: today)
                   }
                }
                
                let task = Task(title: title, isCompleted: isCompleted, color: color, date: date)
                loadedTasks.append(task)
            }
            
            tasks = loadedTasks
        } catch {
            // errorMessage = "Failed to load CSV tasks: \(error.localizedDescription)"
        }
        return tasks
    }
    
    static func saveTasksForProfile(_ tasks: [Task], profile: Profile) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(tasks)
            let url = tasksFileForProfile(profile)
            try data.write(to: url)
            
            // Reload widget to show updated tasks
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error saving tasks: \(error)")
        }
    }
    
    static func saveUserSettings(_ settings: UserSettings, profile: Profile) {
        // No longer needed as we're using UserDefaults
    }
    
    static func getUserSettingsForProfile(_ profile: Profile) -> UserSettings {
        // No longer needed as we're using UserDefaults
        return UserSettings()
    }
    
    private static func getUserSettingsURLForProfile(_ profile: Profile) -> URL {
        // No longer needed as we're using UserDefaults
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("\(profile.name)_settings.json")
    }
    
    static func getMAY26TaskArray() -> [Task] {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        guard let jsonURL = Bundle.main.url(forResource: "MAY26tasks", withExtension: "json") else {
            return []
            
        }
        print("Attempting to read file at: \(jsonURL)")
        
        do {
            let data = try Data(contentsOf: jsonURL)
//            let data = try Data(contentsOf: URL(fileURLWithPath: csvURL))
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            return tasks
        } catch {
            print("Error loading MAY26 tasks: \(error)")
            return []
        }
    }
    
}
