//
//  transitions.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import SwiftUI

// 1. Convert to proper SwiftUI transitions
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
}

// 2. Create demonstration views for your transitions
struct TransitionDemo: View {
    @State private var showView = false
    @State private var useEdgeTransition = false
    @State private var selectedEdge: Edge = .leading
    
    var body: some View {
        VStack {
            Spacer()
            
            if showView {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue)
                    .frame(width: 200, height: 200)
                    .transition(useEdgeTransition ?
                                .cameraPan(edge: selectedEdge) :
                                .fade)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                Toggle("Show View", isOn: $showView.animation(.easeInOut(duration: 0.5)))
                
                Toggle("Use Edge Transition", isOn: $useEdgeTransition)
                
                if useEdgeTransition {
                    Picker("Edge", selection: $selectedEdge) {
                        Text("Leading").tag(Edge.leading)
                        Text("Trailing").tag(Edge.trailing)
                        Text("Top").tag(Edge.top)
                        Text("Bottom").tag(Edge.bottom)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.3))
    }
}

// Original implementations (refactored)
struct FadeTransition: View {
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .ignoresSafeArea()
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5), value: isActive)
    }
}

struct CameraPanTransition: View {
    let isActive: Bool
    let direction: Edge
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.black.opacity(0.8))
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .offset(
                    x: offsetX(for: geometry.size.width),
                    y: offsetY(for: geometry.size.height)
                )
                .animation(.easeInOut(duration: 0.8), value: isActive)
        }
        .ignoresSafeArea()
    }
    
    private func offsetX(for width: CGFloat) -> CGFloat {
        if isActive {
            return 0
        } else {
            switch direction {
            case .leading: return -width
            case .trailing: return width
            default: return 0
            }
        }
    }
    
    private func offsetY(for height: CGFloat) -> CGFloat {
        if isActive {
            return 0
        } else {
            switch direction {
            case .top: return -height
            case .bottom: return height
            default: return 0
            }
        }
    }
}

#Preview {
    TransitionDemo()
}
