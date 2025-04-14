//
//  DialogueView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI


struct DialogueView: View {

    @Environment(\.levelManager) var levelManager
    
    var dialogueImage: Image
    var ilustration: Image
    
    
    private let ilustrationHeight: CGFloat = 530
    private let ilustrationWidth: CGFloat =  334
    
    private let dialogueHeight: CGFloat = 170
    private let dialogueWidth: CGFloat = 334
    
    
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment:.center, spacing: 30){
                ilustration
                    .resizable()
                    .scaledToFill()
                    .frame(width: ilustrationWidth, height: ilustrationHeight)
                    .cornerRadius(20)
                    .clipped()
                
                dialogueImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: dialogueWidth, height: dialogueHeight)
                    .cornerRadius(20)
                    .clipped()
                    .onTapGesture {
                        levelManager.completeLevel()
                    }
            }
        }
        
     
        
    }
}

#Preview {
    DialogueView(dialogueImage: Image("Reason"), ilustration: Image("rectangle33"))
}
