import SwiftUI
import Foundation

enum TaskColor: String, Codable {
    case green
    case blue
    case yellow
    case purple
    case red
}

struct Task: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var color: TaskColor
    var date: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, color: TaskColor = .green, date: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.color = color
        self.date = date
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
