//
//  SwiftUIView.swift
//  b2
//
//  Created by Jose julian Lopez on 06/04/25.
//

import SwiftUI

struct CirclesView: View {

//MARK: - Variables y cosos del state
    
    var ilustration: Image
    
    private let  ilustrationWidth: CGFloat = 320
    
    private let  ilustrationHeight: CGFloat = 598
    
    @Environment(LevelManager.self) private var levelManager
    
    
//MARK: - View
    var body: some View {
        
        ZStack {
            // !! color temporal en lo que hay un fondo, sirve para que la transcion funcione y respete los bordes!!
            Color.white
                .ignoresSafeArea(edges: .all)
            
            //-- contenedor ilustracion y circulos --//
            VStack (spacing: -120){
                ilustration
                    .resizable()
                    .scaledToFill()
                    .frame(width: ilustrationWidth, height: ilustrationHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                
                    
                    ImageSequenceGame()
                    .frame(width: 293, height: 232 )
                    .cornerRadius(20)
                    .overlay{
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(style: StrokeStyle(lineWidth: 4))
                                .foregroundColor(.black)
                        }
            }
        }
    }
}
struct ImageSequenceGame: View {
    let imageNames = ["Food_1(1)", "Food_1(2)", "Food_1(3)", "Food_1(4)"]
    
    @State private var currentImageIndex = 0
    
    @State private var isLevelComplete = false
    
    @Environment(LevelManager.self) private var levelManager

    var body: some View {
        VStack {
            Image(imageNames[currentImageIndex])
                .resizable()
                .scaledToFit()
                
                .contentTransition(.symbolEffect(.automatic))
            
            .onTapGesture {
                if !isLevelComplete {
                    handleTap()
                }
            }
        }
    }
    private func handleTap() {
        withAnimation(.easeInOut(duration: 0.3)) {
            // Check if we need to advance to the next image
            if currentImageIndex < imageNames.count - 1 {
                // Move to next image
                currentImageIndex += 1
            } else {
                isLevelComplete = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                levelManager.completeLevel()
                            }
            }
        }
    }
}

#Preview {
    CirclesView( ilustration: Image("Eating_1(1)"))
        .environment(LevelManager())
}
