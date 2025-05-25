class Task: Identifiable, Equatable, Codable, ObservableObject {
    let id: UUID
    @Published private(set) var title: String
    @Published private(set) var isCompleted: Bool
    @Published private(set) var color: TaskColor
    @Published private(set) var date: Date?
    @Published private(set) var position: Int
    
    let objectWillChange = ObservableObjectPublisher()
    
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, color, date, position
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        color = try container.decode(TaskColor.self, forKey: .color)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        position = try container.decode(Int.self, forKey: .position)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(color, forKey: .color)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encode(position, forKey: .position)
    }
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, color: TaskColor = .green, date: Date? = Date(), position: Int = 0) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.color = color
        self.date = date
        self.position = position
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        objectWillChange.send()
    }
    
    func setTitle(_ newTitle: String) {
        title = newTitle
        objectWillChange.send()
    }
    
    func setDate(_ newDate: Date?) {
        date = newDate
        objectWillChange.send()
    }
    
    func setPosition(_ newPosition: Int) {
        position = newPosition
        objectWillChange.send()
    }
    
    func setColor(_ newColor: TaskColor) {
        color = newColor
        objectWillChange.send()
    }
    
    func setUnscheduled() {
        date = nil
        objectWillChange.send()
    }
} 