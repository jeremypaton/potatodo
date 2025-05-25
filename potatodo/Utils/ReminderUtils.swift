//
//  ReminderUtils.swift
//  potatodo
//
//  Created by Jeremy Paton on 25/5/2025.
//

import Foundation
import UserNotifications
import UIKit

struct ReminderUtils {
    
    static func requestPermissions() -> Bool {
        return true
    }
    
    static func removeAllReminders() {
        
    }
    
    static func recalcReminders(appManager: AppManager) {
        
    }
    
    static func setBadgeCount(_ count: Int) {
        print("Setting badge count to: \(count)") // Debug print
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
}

