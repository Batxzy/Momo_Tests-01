import SwiftUI

// Extend SwiftUI transitions to match our LevelTransition enum
extension AnyTransition {
    static var fade: AnyTransition {
        .opacity
    }
    
    static func cameraPan(edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge),
            removal: .move(edge: edge)
        ).combined(with: .opacity)
    }
    
    // Convert our enum to SwiftUI's native transitions
    static func fromLevelTransition(_ transition: LevelTransition, edge: Edge = .trailing) -> AnyTransition {
        switch transition {
        case .fade:
            return .fade
        case .cameraPan:
            return .cameraPan(edge: edge)
        }
    }
}

// Helper to convert our enum to animation duration
extension Animation {
    static func fromLevelTransition(_ transition: LevelTransition) -> Animation {
        let duration = transition.duration
        return .easeInOut(duration: duration)
    }
}
