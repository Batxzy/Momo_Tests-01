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
    let finalImage: Image
    let onComplete: () -> Void

    @State private var wasClicked: Bool = false

    init(initialImage: Image, finalImage: Image, onComplete: @escaping () -> Void) {
        self.initialImage = initialImage
        self.finalImage = finalImage
        self.onComplete = onComplete
    }

    private func handleTap() {
        guard !wasClicked else { return }

        //** indica la curva entre cambiar imagenes y la duracion **//
        withAnimation(.easeInOut(duration: 0.8)) {
            wasClicked = true
        }
        
        //** delay antes de que se vuelva a la pantalla de tasks **//
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            onComplete()
        }
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
                        .clipped()
                        .opacity(wasClicked ? 0 : 1)
                    
                    finalImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 343, height: 673)
                        .clipped()
                        .opacity(wasClicked ? 1 : 0)
                }
                
                Button {
                    handleTap()
                } label: {
                    Text("Siguiente")
                        .padding(15)
                        .background(.regularMaterial, in: Capsule())
                        
                }
                .disabled(wasClicked)
                .opacity(wasClicked ? 0 : 1)
            }
            
            
        }
    }
}

#Preview {
    ImageChangeView(
        initialImage: Image("rectangle33"),
        finalImage: Image("rectangle35"),
        onComplete: {
            print("Preview ImageChangeView completed!")
        }
    )
}
