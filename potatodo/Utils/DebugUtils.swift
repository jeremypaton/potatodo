//
//  DebugUtils.swift
//  potatodo
//
//  Created by Jeremy Paton on 25/5/2025.
//

func DEBUGPRINT(_ message: String) {
#if DEBUG
    print("DEBUG: " + message)
#endif
}
