import SwiftUI

struct PageBacklog_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var filterOption: FilterOption = .incomplete
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case incomplete = "Incomplete"
        case complete = "Complete"
    }
    
    private var filteredTasks: [Task] {
        let unscheduled = appManager.getUnscheduledTasks()
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
