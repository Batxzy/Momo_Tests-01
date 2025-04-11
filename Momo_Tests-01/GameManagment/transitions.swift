//
//  transitions.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import SwiftUI

struct FadeTransition: View {
    var isActive: Bool
    
    var body: some View {
        Color.black
            .opacity(isActive ? 1.0 : 0.0)
            .ignoresSafeArea()
            .frame(width: UIScreen.main.bounds.width * 2, 
                   height: UIScreen.main.bounds.height * 2)
            .position(x: UIScreen.main.bounds.width/2, 
                      y: UIScreen.main.bounds.height/2)
            .transition(.opacity)
    }
}

struct CameraPanTransition: View {
    var isActive: Bool
    var direction: Edge
    
    var body: some View {
        Color.black
            .ignoresSafeArea()
            .frame(width: UIScreen.main.bounds.width * 2, 
                   height: UIScreen.main.bounds.height * 2)
            .position(x: UIScreen.main.bounds.width/2, 
                      y: UIScreen.main.bounds.height/2)
            .opacity(isActive ? 1.0 : 0.0)
            .transition(.move(edge: direction))
    }
}
