//
//  PotatodoWidgetBundle.swift
//  PotatodoWidget
//
//  Created by Jeremy Paton on 26/5/2025.
//

import WidgetKit
import SwiftUI

@main
struct PotatodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        PotatodoWidget()
        PotatodoWidgetControl()
        PotatodoWidgetLiveActivity()
    }
}
