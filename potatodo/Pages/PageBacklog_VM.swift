import SwiftUI

struct PageBacklog_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var filterOption: FilterOption = .incomplete
    @State private var selectedColors: Set<TaskColor> = []
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case incomplete = "Incomplete"
        case complete = "Complete"
    }
    
    private var filteredTasks: [Task] {
        let unscheduled = appManager.getUnscheduledTasks()
        let statusFiltered = switch filterOption {
        case .all:
            unscheduled
        case .incomplete:
            unscheduled.filter { !$0.isCompleted }
        case .complete:
            unscheduled.filter { $0.isCompleted }
        }
        
        // If no colors are selected, show all colors
        let colorFiltered = if selectedColors.isEmpty {
            statusFiltered
        } else {
            // Otherwise filter by selected colors
            statusFiltered.filter { selectedColors.contains($0.color) }
        }
        
        // Sort by position without modifying the tasks
        return colorFiltered.sorted { $0.position < $1.position }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title and Subtitle
//            VStack(spacing: 4) {
//                Text("BACKLOG")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                Text("unscheduled tasks")
//                    .font(.headline)
//                    .foregroundColor(.gray)
//            }
//            .padding(.vertical)
//            
            VStack(spacing: 4) {
                Text("BACKLOG")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .background(Color.clear)
                Text("unscheduled tasks")
                    .font(.headline)
                    .foregroundColor(.gray)
            }.padding(10)
            
            // Color Filter
            HStack(spacing: 0) {
                ForEach([TaskColor.green, .blue, .yellow, .purple, .red, .gray], id: \.self) { color in
                    Button {
                        if selectedColors.contains(color) {
                            selectedColors.remove(color)
                        } else {
                            selectedColors.insert(color)
                        }
                    } label: {
                        Image(systemName: "star.fill")
                            .foregroundColor(TaskStyle.fullColor(for: Task(title: "", color: color)))
                            .font(.system(size: 32))
                            .opacity(selectedColors.contains(color) ? 1.0 : 0.3)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
            
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
                        Task_V(appManager: appManager, task: task, isCompact: false)
                    }
                }
                .padding()
            }
            
            // Add Task Button (outside ScrollView)
            AddTaskButton_V(appManager: appManager, isCompact: false, date: nil)
                .padding()
        }
    }
}

#Preview {
    let appManager = AppManager()
//    let navManager = NavManager()
//    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    
    return ZStack {
        PageBacklog_VM(appManager: appManager)
        Overlay_V(appManager: appManager)
    }
}
