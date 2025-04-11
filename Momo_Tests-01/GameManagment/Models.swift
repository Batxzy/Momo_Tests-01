//
//  Models.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import SwiftUI

enum LevelTransition {
    case fade
    case cameraPan
    
    var duration: TimeInterval {
        switch self {
        case .fade: return 0.5
        case .cameraPan: return 0.8
        }
    }
}

enum WinCondition {
    case completeMinigame(String)
    case custom(() -> Bool) // Custom condition with closure
}
struct Level: Identifiable {
    let id: UUID
    let name: String
    let content: AnyView
    let transition: LevelTransition
    let winCondition: WinCondition
    var isCompleted: Bool = false
}

struct Chapter: Identifiable {
    let id: UUID
    let title: String
    var levels: [Level]
    var isUnlocked: Bool
}
