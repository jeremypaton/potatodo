//
//  Task_VM.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TaskManager: ObservableObject {
    @ObservedObject var appManager: AppManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appManager: AppManager) {
        self.appManager = appManager
    }
    
    func swapTaskIDs(_ id1: UUID, _ id2: UUID) {
        return
    }
}

#Preview {
    let appManager = AppManager()
    
     ZStack {
        VStack {
            ForEach(appManager.getTasks()) { task in
                Task_V(appManager: appManager, task: task, isCompact: false)
            }
            
            AddTaskButton_V(appManager: appManager, isCompact: false, date: Date())
            
            HStack {
                VStack {
                    ForEach(appManager.getTasks()) { task in
                        Task_V(appManager: appManager, task: task, isCompact: true)
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 2)
                
                Spacer()
            }
        }
        Overlay_V(appManager: appManager)

    }
}
