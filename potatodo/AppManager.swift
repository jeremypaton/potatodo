//
//  AppManager.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI
import UserNotifications
import Combine
import WidgetKit

@MainActor
class AppManager: ObservableObject {
    static let shared = AppManager()
    
    // MARK: - Properties
    
    @Published var appDataStore: AppDataStore
    
    private var navManager: NavManager
    private var overlayManager: OverlayManager
    private var potatoManager: PotatoManager
    private var messageManager: MessageManager
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        let appDataStore = AppDataStore()
        self.appDataStore = appDataStore
        
        let navManager = NavManager()
        self.navManager = navManager
        
        let overlayManager = OverlayManager()
        self.overlayManager = overlayManager
        
        let potatoManager = PotatoManager()
        self.potatoManager = potatoManager
        
        self.messageManager = potatoManager.messageManager
        
        // Initialize Firebase
        _ = FirebaseManager.shared
        
        // Observe all manager changes
        observeManagerChanges()
        
        // Load initial data
        self.loadTasks()
    }
    
    private func observeManagerChanges() {
        observe(navManager)
        observe(overlayManager)
        observe(potatoManager)
        observe(appDataStore)
        observe(messageManager)
    }
    
    private func observe<T: ObservableObject>(_ object: T) {
        object.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
    }
    
    // MARK: - Potato Actions
    
    func getLevel() -> Int {
        return appDataStore.uiState.level
    }
    
    func setLevel(_ newLevel: Int) {
        appDataStore.uiState.level = newLevel
    }
    
    func celebrateLevel(_ newLevel: Int) {
        messageManager.showMessageForCompletionLevel(newLevel)
        appDataStore.uiState.isCelebrating = true
        
        if newLevel == 3 {
            DispatchQueue.main.async {
                self.overlayManager.showPotatoRain(isSinglePotato: false)
            }
        }
        let duration = newLevel == 3 ? 2.5 : 1.2
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.appDataStore.uiState.isCelebrating = false
        }
    }
    
    func potatoWave() {
        appDataStore.uiState.isWaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.appDataStore.uiState.isWaving = false
        }
    }
    
    func potatoTalk() {
        appDataStore.uiState.isTalking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.appDataStore.uiState.isTalking = false
        }
    }
    
    func showRandomMessage() {
        messageManager.showMessageForCompletionLevel(appDataStore.uiState.level)
    }
    
    func potatoReset() {
        appDataStore.uiState.isCelebrating = false
        appDataStore.uiState.isWaving = false
        appDataStore.uiState.isTalking = false
        messageManager.clear()
    }
    
    // MARK: - Task Management
    func setTasks(_ tasks: [Task]) {
        self.appDataStore.taskData.setTasks(tasks)
    }
    
    private func loadTasks() {
        self.setTasks(PersistenceUtils.getTaskArrayForProfile(self.appDataStore.userSettings.profile))
        
        if self.appDataStore.userSettings.profile.name == "defaultUser" {
            FirebaseManager.shared.trackTaskCount(self.appDataStore.taskData.tasks.count)
        }
    }
    
    func addTask(_ task: Task) {
        self.appDataStore.taskData.tasks.append(task)
        FirebaseManager.shared.trackAddTask()
        // Observe the new task
        task.objectWillChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Force a task array update to trigger auto-save
                self.appDataStore.taskData.tasks = self.appDataStore.taskData.tasks
            }
            .store(in: &cancellables)
    }
    
    func deleteTaskByID(_ id: UUID) {
        // Get the task being deleted to know its date
        guard let deletedTask = getTaskByID(id) else { return }
        let deletedDate = deletedTask.date
        
        // Remove the task
        self.appDataStore.taskData.tasks.removeAll { $0.id == id }
        FirebaseManager.shared.trackDeleteTask()
        
        // If the task had a date, reorder remaining tasks for that day
        if let date = deletedDate {
            // Get all tasks for the same day
            let sameDayTasks = self.appDataStore.taskData.tasks.filter { task in
                if let taskDate = task.date {
                    return Calendar.current.isDate(taskDate, inSameDayAs: date)
                }
                return false
            }
            
            // Update positions to be sequential
            for (index, task) in sameDayTasks.enumerated() {
                task.setPosition(index)
            }
        }
    }

    func getTasks() -> [Task] {
        return self.appDataStore.taskData.tasks
    }
    
    func getTaskByID(_ id: UUID) -> Task? {
        return self.appDataStore.taskData.tasks.first(where: { $0.id == id })
    }
    
    func getTasksForToday() -> [Task] {
        return self.appDataStore.taskData.tasks.filter { $0.date == Date() }
    }
    
    func getUnscheduledTasks() -> [Task] {
        return self.appDataStore.taskData.tasks.filter { $0.date == nil }
    }
    
    // MARK: - Profile Management
    
    func setProfileByName(_ name: String) {
        self.appDataStore.userSettings.profile = Profile(name: name)
        self.loadTasks()
    }
    
    // MARK: - Settings Management
    
    func setNotificationsEnabled(_ enabled: Bool) {
        self.appDataStore.userSettings.notificationsEnabled = enabled
        FirebaseManager.shared.trackNotificationsEnabled(enabled)
    }
    
    func toggleNotificationsEnabled() {
        self.appDataStore.userSettings.notificationsEnabled.toggle()
    }
    
    func setNotificationTime(_ time: Date) {
        self.appDataStore.userSettings.notificationTime = time
        FirebaseManager.shared.trackNotificationTimeChange(time)
    }
    
    // MARK: - Task Edit Overlay
    
    func saveTaskEditOverlay() {
        guard let taskId = overlayManager.taskEditOverlay.taskId,
              let task = self.getTaskByID(taskId) else {
            return
        }
        
        task.setTitle(overlayManager.taskEditOverlay.editedTitle)
        task.setColor(overlayManager.taskEditOverlay.selectedColor)
        FirebaseManager.shared.trackEditTask()
        hideTaskEditOverlay()
    }
    
    func deleteTaskEditOverlay() {
        guard let taskId = overlayManager.taskEditOverlay.taskId,
              let task = self.getTaskByID(taskId) else {
            return
        }
        
        self.deleteTaskByID(task.id)
        hideTaskEditOverlay()
    }
    
    func hideTaskEditOverlay() {
        overlayManager.taskEditOverlay.hide()
        overlayManager.objectWillChange.send()
    }
    
    // MARK: - Navigation
    
    func setDate(_ date: Date) {
        navManager.setDate(date)
        potatoReset()
    }
    
    func getCurrentDate() -> Date {
        return navManager.currentDate
    }
    
    func setInterval(_ interval: DateInterval) {
        navManager.setInterval(interval)
        potatoReset()
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
    
    func setPage(_ page: PageType) {
        navManager.setPage(page)
        potatoReset()
    }
    
    // MARK: - UI State
    
    func endSplash() {
        appDataStore.uiState.showSplash = false
    }
    
    func toggleDebugView() {
        appDataStore.uiState.showDebugView.toggle()
    }
    
    func hideDebugView() {
        appDataStore.uiState.showDebugView = false
    }
    
    func setShowIntro(_ show: Bool) {
        self.appDataStore.userSettings.showIntro = show
    }
    
    func setNewUser(_ isNew: Bool) {
        self.appDataStore.userSettings.newUser = isNew
    }
    
    func shouldShowIntro() -> Bool {
        return appDataStore.userSettings.newUser || appDataStore.userSettings.showIntro
    }
    
    func endIntro() {
        setNewUser(false)
        setShowIntro(false)
        setPage(PageType.day)
        endSplash()
    }
    
    // MARK: - Manager Access
    
    func getNavManagerForNavView() -> NavManager {
        return navManager
    }
    
    func getOverlayManagerForOverlayView() -> OverlayManager {
        return overlayManager
    }
    
    func getMessageManagerForMessageView() -> MessageManager {
        return messageManager
    }
    
    // MARK: - Actions
    
    func showTaskEdit(task: Task) {
        overlayManager.showTaskEdit(task: task)
    }
    
    func celebrateTaskComplete() {
        overlayManager.showPotatoRain(isSinglePotato: true)
    }
    
    func requestPermissions() async {
        _ = await ReminderUtils.requestPermissions()
    }
} 
