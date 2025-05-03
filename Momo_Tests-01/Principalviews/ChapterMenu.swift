//
//  ChapterMenu.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

// MARK: - Chapter Menu
struct IndividualChapterMenu: View {
    @Environment(LevelManager.self) private var levelManager

    let part: Part
    @Binding var path: NavigationPath

    var body: some View {
        
        //-- contenedor titulo y botones --//
        VStack(spacing: 27) {
            
            // Título y línea
            VStack(alignment: .leading, spacing: 11) {
                Text(part.title)
                    .font(.Patrick32)

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 290, height: 2)
                    .background(.black)
            }

            // Botones
            ForEach(part.chapters) { chapter in
                if let globalChapterIndex = levelManager.chapters.firstIndex(where: { $0.id == chapter.id }) {
                    ChapterButtonView(path: $path, chapterIndex: globalChapterIndex)
                } else {
                    Text("Error: Chapter '\(chapter.title)' missing from LevelManager")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - Botón individual
struct ChapterButtonView: View {
    
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath

    let chapterIndex: Int

    var body: some View {
        if levelManager.chapters.indices.contains(chapterIndex) {
            let chapter = levelManager.chapters[chapterIndex]
            
            // Inicia el juego y navega a la pantalla del juego
            Button {
                levelManager.startGame(chapterIndex: chapterIndex)
                path.append(NavigationTarget.game)
            } label: {
                Text(chapter.title)
                    .font(.Patric29)
                    .foregroundColor(chapter.isUnlocked ? .primary : .gray)
                    .frame(maxHeight: 27)
            }
            .disabled(!chapter.isUnlocked)
        } else {
            // Muestra un error si el índice es inválido
            Text("Error: Invalid Chapter Index \(chapterIndex)")
                .foregroundColor(.red)
                .font(.caption)
        }
    }
}

// MARK: - Main Chapter View
struct ChapterMenu: View {
    
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath

// MARK: - body
    var body: some View {
        VStack {
            
        //-- contenedor titulo y capitulos --//
            VStack(spacing: 66) {
                
                // Título
                Text("Capítulos")
                    .font(.Patrick60)
                    .frame(maxHeight: 50)

                // partes y sus capítulos
                VStack(spacing: 27) {
                    ForEach(levelManager.Parts) { part in
                        IndividualChapterMenu(part: part, path: $path)
                    }
                }
            }

            Spacer()

            CustomButtonView(title: "back (temporal)") {
                path = NavigationPath()
            }
        }
        .padding(20)
    }
}

// MARK: - Preview
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
    return ChapterMenuPreviewContainer()
}
