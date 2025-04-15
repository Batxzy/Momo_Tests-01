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
            // Added: Title
            Text("Seleccionar Capítulo")
                 .font(.largeTitle)
                 .padding(.bottom)

            // Changed: Use ForEach to iterate over chapters from LevelManager
            ForEach(levelManager.chapters.indices, id: \.self) { index in
                let chapter = levelManager.chapters[index]
                // Changed: Wrap Text in a Button
                Button {
                    // Added: Action to start selected chapter and navigate
                    levelManager.startGame(chapterIndex: index)
                    path.append(NavigationTarget.game)
                } label: {
                    Text(chapter.title)
                        .font(.system(size: 32, weight: .medium))
                        // Added: Conditional foreground color based on unlock status
                        .foregroundColor(chapter.isUnlocked ? .primary : .gray)
                }
                // Added: Disable button if chapter is locked
                .disabled(!chapter.isUnlocked)
            }
        }
    }
}

#Preview {
    @State var previewPath = NavigationPath()
    @State var previewLevelManager = LevelManager()

    return NavigationStack {
        ChapterMenu(path: $previewPath)
    }
    .environment(previewLevelManager)
}
