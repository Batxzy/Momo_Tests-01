//
//  ModelTasks.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 15/04/25.
//

import SwiftUI

struct ImageChangeView: View {

//MARK: - variables funciones y init
    let initialImage: Image
    let onComplete: () -> Void

    @State private var wasClicked: Bool = false

    init(initialImage: Image, onComplete: @escaping () -> Void) {
        self.initialImage = initialImage
        self.onComplete = onComplete
    }

    private func handleTap() {
        guard !wasClicked else { return }

        //** indica la curva entre cambiar imagenes y la duracion **//
        withAnimation(.easeInOut(duration: 0.8)) {
            wasClicked = true
        }
        
            onComplete()
        
    }

//MARK: - view
    var body: some View {
        ZStack {
            
            // !! color temporal en lo que hay un fondo, sirve para que la transcion funcione y respete los bordes!! 
            Color.white
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    initialImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 343, height: 673)
                        .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                        .opacity(wasClicked ? 0 : 1)
                    
                }
                
                CustomButtonView(title: "siguiente", action: {
                    handleTap()
                })
                .disabled(wasClicked)
                .opacity(wasClicked ? 0 : 1)
            }
            
            
        }
    }
}

#Preview {
    ImageChangeView(
        initialImage: Image("rectangle33"),
        onComplete: {
            print("Preview ImageChangeView completed!")
        }
    )
}
