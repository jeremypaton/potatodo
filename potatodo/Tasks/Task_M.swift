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


class Task: Identifiable, Equatable, Codable {
    let id: UUID
    private(set) var title: String
    private(set) var isCompleted: Bool
    private(set) var color: TaskColor
    private(set) var date: Date?
    private(set) var position: Int
    
//    private var cancellables = Set<AnyCancellable>()


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
    }
    
    func setTitle(_ newTitle: String) {
        title = newTitle
    }
    
    func setDate(_ newDate: Date?) {
        date = newDate
    }
    
    func setPosition(_ newPosition: Int) {
        position = newPosition
    }
    
    func setColor(_ newColor: TaskColor) {
        color = newColor
    }
    
    func setUnscheduled() {
        date = nil
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
    
//    private var cancellables = Set<AnyCancellable>()
}
