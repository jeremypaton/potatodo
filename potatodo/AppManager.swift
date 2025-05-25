//
//  ContentView.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI
import UserNotifications
import Combine

enum Profile: String, Codable {
    case debug
    case test
    case prod
}

//enum PageType: String, Codable {
//    case backlog
//    case day
//    case week
//    case month
//    case settings
//}

class UserSettings: ObservableObject {
    @Published fileprivate(set) var profile: Profile = .test
    @Published fileprivate(set) var notificationsEnabled: Bool = false
    @Published fileprivate(set) var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    
    // init()
    // load()
    // save()
}

class UIState: ObservableObject {
    @Published fileprivate(set) var level: Int = 0
    @Published fileprivate(set) var isCelebrating: Bool = false
    @Published fileprivate(set) var showSplash = true
    @Published fileprivate(set) var showDebugView = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Connect all @Published properties to objectWillChange
        $level
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        $isCelebrating
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        $showSplash
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        $showDebugView
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
}

class ModelData: ObservableObject {
    @Published var tasks: [Task] = []
    
    // init()
    // load()
    // save()
}

class AppDataStore: ObservableObject {
    @Published var userSettings = UserSettings()
    @Published var uiState = UIState()
    @Published var modelData = ModelData()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Connect child object changes to parent's objectWillChange
        userSettings.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        uiState.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        modelData.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    // save()
}

@MainActor
class AppManager: ObservableObject {
    private var taskManager: TaskManager!
    private var navManager: NavManager
    private var notificationsManager: NotificationsManager
    private var overlayManager: OverlayManager
    private var potatoManager: PotatoManager
    private var messageManager: MessageManager
    
    @Published var appDataStore: AppDataStore
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let appDataStore = AppDataStore()
        self.appDataStore = appDataStore
//        
//        let taskManager = TaskManager(appManager: self)
//        self.taskManager = taskManager
        
        let navManager = NavManager()
        self.navManager = navManager
        
        let notificationsManager = NotificationsManager()
        self.notificationsManager = notificationsManager
        
        let overlayManager = OverlayManager()
        self.overlayManager = overlayManager
        
        let potatoManager = PotatoManager()
        self.potatoManager = potatoManager
        
        self.messageManager = potatoManager.messageManager
        
        let taskManager = TaskManager(appManager: self)
        self.taskManager = taskManager
        
        // Observe all manager changes
        observeManagerChanges()
    }
    
    private func observeManagerChanges() {
        observe(taskManager)
        observe(navManager)
        observe(notificationsManager)
        observe(overlayManager)
        observe(potatoManager)
        observe(appDataStore)
        observe(messageManager)
    }
    
    private func observe<T: ObservableObject>(_ object: T) {
        object.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func setLevel(_ newLevel: Int) {
        appDataStore.uiState.level = newLevel
    }
    
    func celebrateLevel(_ newLevel: Int) {
        messageManager.showMessageForCompletionLevel(newLevel)
        
        if newLevel == 3 {
            appDataStore.uiState.isCelebrating = true
            DispatchQueue.main.async {
                self.overlayManager.showPotatoRain(isSinglePotato: false)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.appDataStore.uiState.isCelebrating = false
                self?.setLevel(newLevel)
            }
        } else {
            setLevel(newLevel)
        }
    }
    
    func showRandomMessage() {
        messageManager.showMessageForCompletionLevel(appDataStore.uiState.level)
    }
    
    func getTaskManagerForTaskView() -> TaskManager { return taskManager }
    func getNavManagerForNavView() -> NavManager { return navManager }
    func getNotificationsManagerForNotificationsView() -> NotificationsManager { return notificationsManager}
    func getOverlayManagerForOverlayView() -> OverlayManager { return overlayManager }
    func getMessageManagerForMessageView() -> MessageManager { return messageManager }
    
    func getTasks() -> [Task] {
        return taskManager.tasks
    }
    
    func getUnscheduledTasks() -> [Task] {
        return taskManager.tasks
    }

    func setProfile(_ profile: Profile) {
        self.appDataStore.userSettings.profile = profile
        taskManager.loadTasks()
    }
    
    func setNotificationsEnabled(_ enabled: Bool) {
        self.appDataStore.userSettings.notificationsEnabled = enabled
    }
    
    func setNotificationTime(_ time: Date) {
        self.appDataStore.userSettings.notificationTime = time
    }
    
    func saveTaskEditOverlay(){
        guard let taskId = overlayManager.taskEditOverlay.taskId,
              let task = taskManager.tasks.first(where: { $0.id == taskId }) else {
            return
        }
  
        var updatedTask = task
        updatedTask.title = overlayManager.taskEditOverlay.editedTitle
        updatedTask.color = overlayManager.taskEditOverlay.selectedColor
        taskManager.updateTask(updatedTask)
        hideTaskEditOverlay()
    }
    
    func deleteTaskEditOverlay(){
        guard let taskId = overlayManager.taskEditOverlay.taskId,
              let task = taskManager.tasks.first(where: { $0.id == taskId }) else {
            return
        }
        
        taskManager.deleteTask(task)
        hideTaskEditOverlay()
    }
    
    func hideTaskEditOverlay(){
        overlayManager.taskEditOverlay.hide()
        overlayManager.objectWillChange.send()
    }
    
    func setDate(_ date : Date){
        navManager.setDate(date)
    }
    
    func getCurrentDate() -> Date {
        return navManager.currentDate
    }
    
    func setInterval(_ interval: DateInterval){
        navManager.setInterval(interval)
    }
    
    func getWeekStart() -> Date {
        return navManager.weekStart
    }
    
    func isToday() -> Bool {
        return navManager.isToday
    }
    
    func getCurrentPage() -> PageType {
        return navManager.currentPage
    }
    
    func requestPermissions() {
        notificationsManager.requestPermissions()
    }
    
    func showTaskEdit(taskID: UUID, title: String){
        overlayManager.showTaskEdit(for: taskID, title: title)
    }
    
    func celebrateTaskComplete(){
        overlayManager.showPotatoRain(isSinglePotato: true)
    }
    
    func endSplash(){
        appDataStore.uiState.showSplash = false
    }
    
    func toggleDebugView(){
        appDataStore.uiState.showDebugView.toggle()
    }
    
    func hideDebugView(){
        appDataStore.uiState.showDebugView = false
    }
    
    func updateDailyReminders(){
        //move this into reminder manager
        
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
            let tasksForDate = getTasks().filter { task in
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
} 
