//
//  ChapterIntroView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 30/04/25.
//

import SwiftUI

struct ChapterIntroView: View {
    
    @Environment(LevelManager.self) private var levelManager
    var body: some View {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
               
                VStack {
                    VStack(spacing: 24) {
                        Text("Capitulo \(levelManager.currentChapterIndex + 1)")
                            .font(.Patrick32)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                        
                        Rectangle()
                            .frame(width: 178, height: 2)
                            .foregroundStyle(.white)
                        
                        Text(levelManager.currentChapter.title)
                            .font(.Patrick48)
                            .foregroundStyle(.white)
                            .frame(height: 32)
                    }
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                     
                    
                    HStack() {
                        Spacer()
                        CustomButtonView(title: "siguiente") {
                            levelManager.completeLevel()
                        }
                    }
                    .frame( maxHeight: 56)
                    .padding(16)
                }
            }
    
        }
    }

#Preview {
    ChapterIntroView()
        .environment(LevelManager())
}

