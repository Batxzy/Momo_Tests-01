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
        Rectangle()
            .fill(Color.black)
            .opacity(isActive ? 1.0 : 0.0)
            .edgesIgnoringSafeArea(.all)
    }
}

struct CameraPanTransition: View {
    var isActive: Bool
    var direction: Edge
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.black)
                .edgesIgnoringSafeArea(.all)
                .opacity(isActive ? 1.0 : 0.0)
        }
    }
}
