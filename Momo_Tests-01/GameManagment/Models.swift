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
    case cameraPanF
    
    var duration: TimeInterval {
        switch self {
        case .fade: return 0.8  // Increased from 0.5
        case .cameraPan: return 2  // Increased from 0.8
        case .cameraPanF: return 2
        }
    }
}


struct Level: Identifiable {
    let id: UUID
    let name: String
    let content: AnyView
    let transition: LevelTransition
    var isCompleted: Bool = false
}

struct Chapter: Identifiable {
    let id: UUID
    let title: String
    var levels: [Level]
    var isUnlocked: Bool
}

enum NavigationTarget: Hashable {
    case chapterMenu
    case game
}