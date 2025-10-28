//
//  ContentView.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//
//womble
import SwiftUI
import UserNotifications
import Combine
import WidgetKit

class Profile : Hashable, ObservableObject, Codable {
    var name: String
    
    #if DEBUG
    init(name: String = "DEBUG") {
        self.name = name
    }
    #elseif TEST
    init(name: String = "TEST") {
        self.name = name
    }
    #else
    init(name: String = "defaultUser") {
        self.name = name
    }
    #endif
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class UserSettings: ObservableObject, Codable {
    @Published fileprivate(set) var profile: Profile = Profile()
    @Published fileprivate(set) var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    @Published fileprivate(set) var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        }
    }
    @Published fileprivate(set) var newUser: Bool {
        didSet {
            UserDefaults.standard.set(newUser, forKey: "newUser")
        }
    }
    @Published fileprivate(set) var showIntro: Bool {
        didSet {
            UserDefaults.standard.set(showIntro, forKey: "showIntro")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case profile, notificationsEnabled, notificationTime, newUser, showIntro
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profile = try container.decode(Profile.self, forKey: .profile)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        notificationTime = try container.decode(Date.self, forKey: .notificationTime)
        newUser = try container.decode(Bool.self, forKey: .newUser)
        showIntro = try container.decode(Bool.self, forKey: .showIntro)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(profile, forKey: .profile)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(notificationTime, forKey: .notificationTime)
        try container.encode(newUser, forKey: .newUser)
        try container.encode(showIntro, forKey: .showIntro)
    }
    
    init() {
        // Load saved settings from UserDefaults
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.newUser = UserDefaults.standard.bool(forKey: "newUser", defaultValue: true)
        self.showIntro = UserDefaults.standard.bool(forKey: "showIntro", defaultValue: false)
    }
}

extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            set(defaultValue, forKey: key)
            return defaultValue
        }
        return bool(forKey: key)
    }
}

class UIState: ObservableObject {
    @Published fileprivate(set) var level: Int = 0
    @Published fileprivate(set) var isCelebrating: Bool = false
    @Published fileprivate(set) var isWaving: Bool = false
    @Published fileprivate(set) var isTalking: Bool = false
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
        $isWaving
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        $isTalking
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

class TaskData: ObservableObject {
    @Published fileprivate(set) var tasks: [Task] = []
    private var arrayCancellables = Set<AnyCancellable>()
    private var taskCancellables = Set<AnyCancellable>()
    
    init() {
        // Observe the tasks array itself
        updateArrayObservations()
        updateTaskObservations()
    }
    
    private func updateArrayObservations() {
        arrayCancellables.removeAll()
        $tasks
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.updateTaskObservations()
            }
            .store(in: &arrayCancellables)
    }
    
    private func updateTaskObservations() {
        // Only clear taskCancellables, not arrayCancellables!
        taskCancellables.removeAll()
        // Observe each task
        for task in tasks {
            task.objectWillChange
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    // Force a task array update to trigger auto-save
                    self.tasks = self.tasks
                }
                .store(in: &taskCancellables)
        }
    }
    
    fileprivate func setTasks(_ tasks: [Task]) {
        self.tasks = tasks
        updateArrayObservations()
        updateTaskObservations()
    }
}

class AppDataStore: ObservableObject {
    @Published var userSettings = UserSettings()
    @Published var uiState = UIState()
    @Published var taskData = TaskData()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Connect child object changes to parent's objectWillChange
        userSettings.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        uiState.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        taskData.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        // Auto-save tasks when they change
        taskData.$tasks
            .dropFirst() // Ignore initial value
            .sink { [weak self] tasks in
//                print("[AppDataStore] taskData.$tasks sink called, tasks count: \(tasks.count)") // Debug print
                guard let self = self else { return }
                PersistenceUtils.saveTasksForProfile(tasks, profile: self.userSettings.profile)
                
                let numberTasksLeftToday = tasks.filter { task in
                    !task.isCompleted && task.isToday()
                }.count
                ReminderUtils.setBadgeCount(numberTasksLeftToday)
                
                // Recalculate reminders when tasks change
                DispatchQueue.main.async {
                    _Concurrency.Task {
                        await ReminderUtils.recalcReminders(userSettings: self.userSettings,
                            tasks: tasks
                        )
                    }
                }
            }
            .store(in: &cancellables)
    }
}

@MainActor
class AppManager: ObservableObject {
    static let shared = AppManager()
    
    private var navManager: NavManager
    private var overlayManager: OverlayManager
    private var potatoManager: PotatoManager
    private var messageManager: MessageManager
    
    @Published var appDataStore: AppDataStore
    
    private var cancellables = Set<AnyCancellable>()
    
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
        object.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    
    func getLevel() -> Int{
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
    
    func getNavManagerForNavView() -> NavManager { return navManager }
    func getOverlayManagerForOverlayView() -> OverlayManager { return overlayManager }
    func getMessageManagerForMessageView() -> MessageManager { return messageManager }
    
    
    // BASIC TASK MANAGEMENT
    func setTasks(_ tasks: [Task]) { self.appDataStore.taskData.setTasks(tasks) }
    private func loadTasks(){ 
        self.setTasks(PersistenceUtils.getTaskArrayForProfile(self.appDataStore.userSettings.profile))
        
        // Track task count for defaultUser only
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

    func getTasks() -> [Task] { return self.appDataStore.taskData.tasks}
    func getTaskByID(_ id: UUID) -> Task? { return self.appDataStore.taskData.tasks.first(where: { $0.id == id }) }
    func getTaskForDate(date: Date) -> [Task] { return self.appDataStore.taskData.tasks.filter {$0.date == date } }
    func getTasksForToday() -> [Task] { return self.appDataStore.taskData.tasks.filter {$0.date == Date()} }
    func getUnscheduledTasks() -> [Task] { return self.appDataStore.taskData.tasks.filter { $0.date == nil } }
    
    func createDefaultTask(_ task: Task) { self.appDataStore.taskData.tasks.append(task) }

    
    func setProfileByName(_ name: String) {
        self.appDataStore.userSettings.profile = Profile(name: name)
        self.loadTasks()
    }
    
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
    
    func saveTaskEditOverlay(){
        guard let taskId = overlayManager.taskEditOverlay.taskId,
              let task = self.getTaskByID(taskId) else {
            return
        }
  
        let updatedTask = task
        updatedTask.setTitle(overlayManager.taskEditOverlay.editedTitle)
        updatedTask.setColor(overlayManager.taskEditOverlay.selectedColor)
        FirebaseManager.shared.trackEditTask()
        hideTaskEditOverlay()
    }
    
    func deleteTaskEditOverlay(){
        guard let taskId = overlayManager.taskEditOverlay.taskId,
              let task = self.getTaskByID(taskId) else {
            return
        }
        
        self.deleteTaskByID(task.id)
        hideTaskEditOverlay()
    }
    
    func hideTaskEditOverlay(){
        overlayManager.taskEditOverlay.hide()
        overlayManager.objectWillChange.send()
    }
    
    func setDate(_ date : Date){
        navManager.setDate(date)
        potatoReset()
    }
    
    func getCurrentDate() -> Date {
        return navManager.currentDate
    }
    
    func setInterval(_ interval: DateInterval){
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
    
    func potatoReset() {
        appDataStore.uiState.isCelebrating = false
        appDataStore.uiState.isWaving = false
        appDataStore.uiState.isTalking = false
        messageManager.clear()
    }
    
    func requestPermissions() async {
        _ = await ReminderUtils.requestPermissions()
    }
    
    func showTaskEdit(task: Task){
        overlayManager.showTaskEdit(task: task)
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
} 
