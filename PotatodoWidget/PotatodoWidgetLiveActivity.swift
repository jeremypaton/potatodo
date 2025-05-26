//
//  PotatodoWidgetLiveActivity.swift
//  PotatodoWidget
//
//  Created by Jeremy Paton on 26/5/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PotatodoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PotatodoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PotatodoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PotatodoWidgetAttributes {
    fileprivate static var preview: PotatodoWidgetAttributes {
        PotatodoWidgetAttributes(name: "World")
    }
}

extension PotatodoWidgetAttributes.ContentState {
    fileprivate static var smiley: PotatodoWidgetAttributes.ContentState {
        PotatodoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PotatodoWidgetAttributes.ContentState {
         PotatodoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PotatodoWidgetAttributes.preview) {
   PotatodoWidgetLiveActivity()
} contentStates: {
    PotatodoWidgetAttributes.ContentState.smiley
    PotatodoWidgetAttributes.ContentState.starEyes
}
