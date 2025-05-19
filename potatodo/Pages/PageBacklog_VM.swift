import SwiftUI

struct PageBacklog_VM: View {
    @ObservedObject var taskManager: TaskManager
    @EnvironmentObject var overlayManager: OverlayManager
    @State private var filterOption: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case incomplete = "Incomplete"
        case complete = "Complete"
    }
    
    private var filteredTasks: [Task] {
        let unscheduled = taskManager.unscheduledTasks
        switch filterOption {
        case .all:
            return unscheduled
        case .incomplete:
            return unscheduled.filter { !$0.isCompleted }
        case .complete:
            return unscheduled.filter { $0.isCompleted }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title and Subtitle
            VStack(spacing: 4) {
                Text("BACKLOG")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("unscheduled tasks")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.vertical)
            
            // Filter Picker
            Picker("Filter", selection: $filterOption) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Task List
            ScrollView {
                VStack(spacing: 55) {
                    ForEach(filteredTasks) { task in
                        Task_V(taskManager: taskManager, taskId: task.id, isCompact: false)

                    }
                }
                .padding()
            }
            
            // Add Task Button (outside ScrollView)
            AddTaskButton_V(taskManager: taskManager, isCompact: false, date: nil)
                .padding()
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    
    return ZStack {
        PageBacklog_VM(taskManager: taskManager)
        Overlay_V()
    }
    .environmentObject(overlayManager)
} 
