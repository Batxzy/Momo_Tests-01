//
//  blankview.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI


struct blankview: View {
    @Environment(LevelManager.self) private var levelManager
    
    var body: some View {
        
        Color.white
            .onAppear() {
                levelManager.completeLevel()
            }
        
    }
}

#Preview {
    blankview()
}
