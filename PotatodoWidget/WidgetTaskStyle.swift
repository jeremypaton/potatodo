import SwiftUI

struct WidgetTaskStyle {
    static func fullColor(for task: WidgetTask) -> Color {
        switch task.color {
        case .green: return Color.green
        case .blue: return Color.blue
        case .yellow: return Color.yellow
        case .purple: return Color.purple
        case .red: return Color.red
        case .gray: return Color.gray
        }
    }
} 