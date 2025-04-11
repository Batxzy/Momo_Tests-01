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
            .animation(.easeInOut(duration: 0.5), value: isActive)
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
                .offset(
                    x: offsetX(for: direction, in: geometry, isActive: isActive),
                    y: offsetY(for: direction, in: geometry, isActive: isActive)
                )
                .animation(.easeInOut(duration: 0.8), value: isActive)
        }
    }
    
    private func offsetX(for direction: Edge, in geometry: GeometryProxy, isActive: Bool) -> CGFloat {
        if isActive { return 0 }
        
        switch direction {
        case .leading: return -geometry.size.width
        case .trailing: return geometry.size.width
        default: return 0
        }
    }
    
    private func offsetY(for direction: Edge, in geometry: GeometryProxy, isActive: Bool) -> CGFloat {
        if isActive { return 0 }
        
        switch direction {
        case .top: return -geometry.size.height
        case .bottom: return geometry.size.height
        default: return 0
        }
    }
}
