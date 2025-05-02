//
//  TapOverlayView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 02/05/25.
//

import SwiftUI

struct TapOverlayView: View {
    let stateManager: StoryStateManager
    
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                stateManager.handleBackgroundTap()
            }
    }
}
