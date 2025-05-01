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
    case cameraPanV
    case cameraPanNormalV
    
    //** aqui se controla el tiempo entre transciones **//
    var duration: TimeInterval {
        switch self {
        case .fade: return 0.8
        case .cameraPan: return 2
        case .cameraPanF: return 2
        case .cameraPanV: return 2
        case .cameraPanNormalV : return 2
        }
    }
}

enum AnimationStyle {
    case spring
    case smooth
    case bouncy
    case easeInOut
    case easeIn
    case easeOut
    case linear
    
    // Convert to SwiftUI Animation with given duration
    func toAnimation(duration: Double) -> Animation {
        switch self {
        case .spring:
            return .spring(duration: duration)
        case .smooth:
            return .smooth(duration: duration)
        case .bouncy:
            return .bouncy(duration: duration)
        case .easeInOut:
            return .easeInOut(duration: duration)
        case .easeIn:
            return .easeIn(duration: duration)
        case .easeOut:
            return .easeOut(duration: duration)
        case .linear:
            return .linear(duration: duration)
        }
    }
}

enum NavigationTarget: Hashable {
    case chapterMenu
    case game
    case gallery
    case imageDetail(allNames: [String], selectedName: String, namespace: Namespace.ID)
}

struct Level: Identifiable {
    let id: UUID
    let name: String
    let content: AnyView
    let transition: LevelTransition
    var isCompleted: Bool = false
    
    // Animation parameters
    var animationDuration: Double
    var animationStyle: AnimationStyle
    
    // Get the SwiftUI animation for this level
    var animation: Animation {
        animationStyle.toAnimation(duration: animationDuration)
    }
    
    // Default initializer with spring animation as default
    init(
        id: UUID,
        name: String,
        content: AnyView,
        transition: LevelTransition,
        isCompleted: Bool = false,
        animationDuration: Double? = nil, // Optional - falls back to transition duration if nil
        animationStyle: AnimationStyle = .spring // Spring is the default
    ) {
        self.id = id
        self.name = name
        self.content = content
        self.transition = transition
        self.isCompleted = isCompleted
        // Use custom duration or fall back to transition's duration
        self.animationDuration = animationDuration ?? transition.duration
        self.animationStyle = animationStyle
    }
}

struct Chapter: Identifiable {
    let id: UUID
    let title: String
    var levels: [Level]
    var isUnlocked: Bool
}

struct Part : Identifiable {
    let id: UUID
    let title: String
    var chapters: [Chapter]
}

enum NavigationTarget: Hashable {
    case chapterMenu
    case game
}

