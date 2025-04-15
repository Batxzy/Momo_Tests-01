//
//  ChapterMenu.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct ChapterMenu: View {
    
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 32) {

            
            // for loop para cada capitulo
            ForEach(levelManager.chapters.indices, id: \.self) { index in
                let chapter = levelManager.chapters[index]
               
                
                Button {
                    //le mueve al level manager
                    levelManager.startGame(chapterIndex: index)
                    path.append(NavigationTarget.game)
                    
                } label: {
                    Text(chapter.title)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(chapter.isUnlocked ? .primary : .gray)
                }
                .disabled(!chapter.isUnlocked)
            }
            
        }
        .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        path = NavigationPath()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Menú Principal")
                        }
                    }
                }
            }
    }
}
#Preview {
    struct ChapterMenuPreviewContainer: View {
            @State var previewPath = NavigationPath()
            @State var previewLevelManager = LevelManager()

            var body: some View {
                NavigationStack(path: $previewPath) {
                    ChapterMenu(path: $previewPath)
                }
                .environment(previewLevelManager)
            }
        }

        // Changed: Return an instance of the container struct
        return ChapterMenuPreviewContainer()
}
