//
//  TapOverlayView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 02/05/25.
//

import SwiftUI

// MARK: - Tap overlay
import SwiftUI

import SwiftUI

struct TapOverlayView: View {
    var stateManager: StoryStateManager
    
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                stateManager.handleBackgroundTap()
            }
    }
}
