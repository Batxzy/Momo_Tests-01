//
//  Test Transition.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import SwiftUI


struct GreenRectangleView: View {
    var body: some View {
            ZStack {
                // Full screen background
                Color.blue
                    .ignoresSafeArea()
                
                // Green rectangle
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 200, height: 100)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
}

struct BlueRectangleView: View {
    var body: some View {
        ZStack {
            // Full screen background
            Color.indigo.opacity(0.5)
                .ignoresSafeArea()
            
            // Blue rectangle
            Rectangle()
                .fill(Color.blue)
                .frame(width: 200, height: 100)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }
}

struct RedRectangleView: View {
    var body: some View {
        ZStack {
            // Full screen background
            Color.pink
                .ignoresSafeArea()
            
            // Blue rectangle
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 100)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }
}

struct Test_Transition: View {
        @State private var showGreenView = true
        
        var body: some View {
            ZStack {
                if showGreenView {
                    GreenRectangleView()
                        .transition(.move(edge: .leading))
                } else {
                    BlueRectangleView()
                        .transition(.move(edge: .trailing))
                }
            }
            .overlay(alignment: .bottom) {
                Button("Switch") {
                    withAnimation(.spring()) {
                        showGreenView.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 50)
            }
        }
    }

struct ViewPagerContainer<Content: View>: View {
    // Array of your existing views
    let views: [Content]
    @State private var currentIndex = 0

    
    var body: some View {
        ZStack {
            // Display the current view from your array
            views[currentIndex]
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .id(currentIndex) // Important for transition to work properly
            
            // Simple button at the bottom
            VStack {
                Spacer()
                
                Button {
                    withAnimation(.spring(.smooth)) {
                        currentIndex = (currentIndex + 1) % views.count
                    }
                } label: {
                    Text("Next Screen")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 40)
            }
        }
    }
}


struct Test_ContentView: View {
    // Your existing views that you've already coded
    var body: some View {
        // Put your existing views in an array
        let yourExistingViews: [AnyView] = [AnyView(DustRemoverView2(
            backgroundImage: Image("rectangle33"),
            foregroundImage: Image("rectangle36"),
            completionThreshold: 90.0,
            backgroundWidth: 347,
            backgroundHeight: 700,
            foregroundWidth: 347,
            foregroundHeight: 700)),AnyView(DragProgressView(swipeSensitivity: 2.0))
        ]
        
        // Use the container with your views
        ViewPagerContainer(views: yourExistingViews)
    }
}
#Preview {
    Test_ContentView()
}
