//
//  SwiftUIView.swift
//  b2
//
//  Created by Jose julian Lopez on 06/04/25.
//

import SwiftUI

struct CirclesView: View {

//MARK: - Variables y cosos del state
    
    @Environment(LevelManager.self) private var levelManager
    
    var ilustration: Image
    
    private let  ilustrationWidth: CGFloat = 320
    
    private let  ilustrationHeight: CGFloat = 598
    
    @State private var circleTapped : Array = [false,false,false,false]

    @State private var gameDone: Bool = false
    
    private var areAllCirclesTapped: Bool {
        !circleTapped.contains(false)
    }
    
    private func handleTap(at index: Int) {
        guard !circleTapped[index] else { return }

        circleTapped[index] = true

        if areAllCirclesTapped {
            levelManager.completeLevel()
        }
    }
//MARK: - View
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(edges: .all)
            VStack (spacing: -90){
                ilustration
                    .resizable()
                    .scaledToFill()
                    .frame(width: ilustrationWidth, height: ilustrationHeight)
                    .clipped()
                
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .frame(width: 50, height: 50)
                        
                        
                            .animation(.spring (response: 0.3, dampingFraction: 0.4)){
                                $0.scaleEffect(circleTapped[index] ? 1.5 : 1.0)
                            }
                        
                        
                            .animation(.easeOut.delay(0.3)){
                                $0.opacity(circleTapped[index] ? 0 : 1)
                            }
                        
                            .onTapGesture {
                                handleTap(at: index)
                            }
                    }
                }
                
                .frame(width: 300, height: 220 )
                .background()
                .cornerRadius(20)
                .overlay{
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}


#Preview {
    CirclesView( ilustration: Image("rectangle33"))
        .environment(LevelManager())
}
