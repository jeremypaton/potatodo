import SwiftUI
import Foundation
import Combine

enum TaskColor: String, Codable {
    case green
    case blue
    case yellow
    case purple
    case red
    case gray
}


class Task: Identifiable, Equatable, Codable, ObservableObject {
    let id: UUID
    @Published private(set) var title: String
    @Published private(set) var isCompleted: Bool
    @Published private(set) var color: TaskColor
    @Published private(set) var date: Date?
    @Published private(set) var position: Int
    
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
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, color: TaskColor = .green, date: Date? = nil, position: Int = 0) {
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
    
    func isToday() -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        objectWillChange.send()
        DEBUGPRINT("[Task] \(id) completion toggled to: \(isCompleted)")  // Debug print
    }
    
    func setTitle(_ newTitle: String) {
        title = newTitle
        objectWillChange.send()
        DEBUGPRINT("[Task] \(id) title set to: \(title)") // Debug print
    }
    
    func setDate(_ newDate: Date?) {
        date = newDate
        objectWillChange.send()
        DEBUGPRINT("[Task] \(id) date set to: \(String(describing: date))") // Debug print
    }
    
    func setPosition(_ newPosition: Int) {
        position = newPosition
        objectWillChange.send()
    }
    
    func setColor(_ newColor: TaskColor) {
        color = newColor
        objectWillChange.send()
        DEBUGPRINT("[Task] \(id) color set to: \(color)") // Debug print
    }
    
    func setUnscheduled() {
        date = nil
        objectWillChange.send()
        DEBUGPRINT("[Task] \(id) set to unscheduled") // Debug print
    }
    
    func cycleColor() {
        switch self.color {
            case .green: self.setColor(.blue)
            case .blue: self.setColor(.yellow)
            case .yellow: self.setColor(.purple)
            case .purple: self.setColor(.red)
            case .red: self.setColor(.gray)
            case .gray: self.setColor(.green)
        }
    }
    
    static func swapTasks(_ task1: Task, _ task2: Task) {
        // Swap positions
        let tempPosition = task1.position
        task1.setPosition(task2.position)
        task2.setPosition(tempPosition)
        
        // Swap dates
        let tempDate = task1.date
        task1.setDate(task2.date)
        task2.setDate(tempDate)
        
        // Notify observers for both tasks
        task1.objectWillChange.send()
        task2.objectWillChange.send()
    }
}
