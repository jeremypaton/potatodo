import Foundation

enum WidgetTaskColor: String, Codable {
    case green
    case blue
    case yellow
    case purple
    case red
    case gray
}

struct WidgetTask: Identifiable, Codable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let color: WidgetTaskColor
    let date: Date?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, color: WidgetTaskColor = .green, date: Date? = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.color = color
        self.date = date
    }
} 