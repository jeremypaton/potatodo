import SwiftUI
import Combine

// MARK: - Profile

class Profile: Hashable, ObservableObject, Codable {
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

// MARK: - UserSettings

class UserSettings: ObservableObject, Codable {
    @Published internal(set) var profile: Profile = Profile()
    @Published internal(set) var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    @Published internal(set) var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        }
    }
    @Published internal(set) var newUser: Bool {
        didSet {
            UserDefaults.standard.set(newUser, forKey: "newUser")
        }
    }
    @Published internal(set) var showIntro: Bool {
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

// MARK: - UIState

class UIState: ObservableObject {
    @Published internal(set) var level: Int = 0
    @Published internal(set) var isCelebrating: Bool = false
    @Published internal(set) var isWaving: Bool = false
    @Published internal(set) var isTalking: Bool = false
    @Published internal(set) var showSplash = true
    @Published internal(set) var showDebugView = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $level.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        $isCelebrating.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        $isWaving.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        $isTalking.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        $showSplash.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        $showDebugView.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
    }
}

// MARK: - TaskData

class TaskData: ObservableObject {
    @Published internal(set) var tasks: [Task] = []
    private var arrayCancellables = Set<AnyCancellable>()
    private var taskCancellables = Set<AnyCancellable>()
    
    init() {
        updateArrayObservations()
        updateTaskObservations()
    }
    
    private func updateArrayObservations() {
        arrayCancellables.removeAll()
        $tasks.sink { [weak self] _ in
            self?.objectWillChange.send()
            self?.updateTaskObservations()
        }.store(in: &arrayCancellables)
    }
    
    private func updateTaskObservations() {
        taskCancellables.removeAll()
        for task in tasks {
            task.objectWillChange.sink { [weak self] _ in
                guard let self = self else { return }
                self.tasks = self.tasks
            }.store(in: &taskCancellables)
        }
    }
    
    internal func setTasks(_ tasks: [Task]) {
        self.tasks = tasks
        updateArrayObservations()
        updateTaskObservations()
    }
}

// MARK: - AppDataStore

class AppDataStore: ObservableObject {
    @Published var userSettings = UserSettings()
    @Published var uiState = UIState()
    @Published var taskData = TaskData()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        userSettings.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        uiState.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        taskData.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        
        taskData.$tasks.dropFirst().sink { [weak self] tasks in
            guard let self = self else { return }
            PersistenceUtils.saveTasksForProfile(tasks, profile: self.userSettings.profile)
            
            let numberTasksLeftToday = tasks.filter { !$0.isCompleted && $0.isToday() }.count
            ReminderUtils.setBadgeCount(numberTasksLeftToday)
            
            DispatchQueue.main.async {
                _Concurrency.Task {
                    await ReminderUtils.recalcReminders(userSettings: self.userSettings, tasks: tasks)
                }
            }
        }.store(in: &cancellables)
    }
}

